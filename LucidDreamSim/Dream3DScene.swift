import SceneKit
import SwiftUI
import UIKit

/// Procedural, grounded first-person neighbourhood with lightweight dream NPCs.
final class Dream3DScene: SCNScene {
    private let tileSize: Float = 12
    private let renderRadius = 6
    private let cameraNode = SCNNode()
    private var tiles: [String: SCNNode] = [:]
    private var crystals: [String: SCNNode] = [:]
    private var playerX = 0
    private var playerZ = 0
    private var worldX: Float = 0
    private var worldZ: Float = 0
    private var height: Float = 1.65
    private var alternateReality = false
    private var flightEnabled = false
    private var timeBent = false
    private var gravityInverted = false
    private var phaseEnabled = false
    private var worldBent = false
    private let seed = 481516
    var statusUpdater: ((String) -> Void)?
    var soundUpdater: ((String) -> Void)?
    var lastMoveToken = UUID()
    var lastActionToken = UUID()

    override init() {
        super.init()
        background.contents = UIColor(red: 0.47, green: 0.62, blue: 0.75, alpha: 1)
        setupWorld()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWorld()
    }

    private func setupWorld() {
        let camera = SCNCamera()
        camera.fieldOfView = 72
        camera.zFar = 180
        camera.wantsHDR = true
        camera.bloomIntensity = 0.08
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, height, 0)
        rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(white: 0.85, alpha: 1)
        ambient.light?.intensity = 650
        rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.color = UIColor(red: 1, green: 0.91, blue: 0.78, alpha: 1)
        sun.light?.intensity = 850
        sun.eulerAngles = SCNVector3(-0.8, -0.45, 0)
        rootNode.addChildNode(sun)

        refreshWorld()
    }

    private func hash(_ x: Int, _ z: Int) -> Int {
        var n = x &* 374761393 &+ z &* 668265263 &+ seed
        n = (n ^ (n >> 13)) &* 1274126177
        return abs(n ^ (n >> 16)) % 1000
    }

    private func key(_ x: Int, _ z: Int) -> String { "\(x),\(z)" }

    private func material(_ color: UIColor, roughness: CGFloat = 0.9) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = color
        m.roughness.contents = roughness
        return m
    }

    private func makeBox(_ size: SCNVector3, color: UIColor, position: SCNVector3, into parent: SCNNode) -> SCNNode {
        let geo = SCNBox(width: CGFloat(size.x), height: CGFloat(size.y), length: CGFloat(size.z), chamferRadius: 0)
        geo.materials = [material(color)]
        let node = SCNNode(geometry: geo)
        node.position = position
        parent.addChildNode(node)
        return node
    }

    private func refreshWorld() {
        var needed = Set<String>()
        for x in (playerX - renderRadius)...(playerX + renderRadius) {
            for z in (playerZ - renderRadius)...(playerZ + renderRadius) {
                let k = key(x, z)
                needed.insert(k)
                if tiles[k] == nil {
                    let container = SCNNode()
                    container.position = SCNVector3(Float(x) * tileSize, 0, Float(z) * tileSize)
                    container.name = "city-tile-\(k)"
                    rootNode.addChildNode(container)
                    buildTile(x: x, z: z, into: container)
                    tiles[k] = container
                }
            }
        }
        for k in tiles.keys.filter({ !needed.contains($0) }) {
            tiles[k]?.removeFromParentNode()
            tiles.removeValue(forKey: k)
        }
    }

    private func buildTile(x: Int, z: Int, into tile: SCNNode) {
        let h = hash(x, z)
        let asphalt = UIColor(red: 0.22, green: 0.24, blue: 0.25, alpha: 1)
        let concrete = UIColor(red: 0.53, green: 0.53, blue: 0.50, alpha: 1)
        let grass = UIColor(red: 0.24, green: 0.32, blue: 0.21, alpha: 1)

        // Broad road and pavement strips create a recognisable neighbourhood grid.
        makeBox(SCNVector3(12, 0.12, 12), color: asphalt, position: SCNVector3(0, -0.09, 0), into: tile)
        makeBox(SCNVector3(2.0, 0.14, 12), color: concrete, position: SCNVector3(-5.0, -0.015, 0), into: tile)
        makeBox(SCNVector3(2.0, 0.14, 12), color: concrete, position: SCNVector3(5.0, -0.015, 0), into: tile)

        // Dashed, faded road markings.
        if x % 2 == 0 {
            makeBox(SCNVector3(0.10, 0.012, 2.2), color: UIColor(white: 0.76, alpha: 1), position: SCNVector3(0, -0.015, -3.0), into: tile)
            makeBox(SCNVector3(0.10, 0.012, 2.2), color: UIColor(white: 0.76, alpha: 1), position: SCNVector3(0, -0.015, 3.0), into: tile)
        }

        // Buildings use restrained real-world materials rather than fantasy geometry.
        if h % 100 < 42 {
            let width = CGFloat(3.0 + Double(h % 20) * 0.12)
            let floors = 2 + h % 5
            let buildingHeight = Float(floors) * 2.15
            let colors: [UIColor] = [
                UIColor(red: 0.66, green: 0.62, blue: 0.54, alpha: 1),
                UIColor(red: 0.56, green: 0.57, blue: 0.55, alpha: 1),
                UIColor(red: 0.72, green: 0.69, blue: 0.61, alpha: 1),
                UIColor(red: 0.48, green: 0.50, blue: 0.51, alpha: 1),
                UIColor(red: 0.68, green: 0.57, blue: 0.48, alpha: 1)
            ]
            let bx: Float = h % 2 == 0 ? -3.1 : 3.1
            let bz: Float = h % 3 == 0 ? -2.0 : 2.0
            let building = makeBox(SCNVector3(Float(width), buildingHeight, 4.2),
                                   color: colors[h % colors.count],
                                   position: SCNVector3(bx, buildingHeight / 2, bz), into: tile)
            building.name = "building"
            // Recessed-looking windows on the visible facade.
            for floor in 0..<floors {
                for column in 0..<2 {
                    let windowColor = (h + floor + column) % 4 == 0
                        ? UIColor(red: 0.76, green: 0.70, blue: 0.48, alpha: 1)
                        : UIColor(red: 0.16, green: 0.23, blue: 0.27, alpha: 1)
                    let wx = bx + (column == 0 ? -0.72 : 0.72)
                    let wz = bz + (bz > 0 ? -2.115 : 2.115)
                    makeBox(SCNVector3(0.62, 0.85, 0.045), color: windowColor,
                            position: SCNVector3(wx, Float(floor) * 2.15 + 1.35, wz), into: tile)
                }
            }
            makeBox(SCNVector3(Float(width) + 0.08, 0.12, 4.28),
                    color: UIColor(red: 0.30, green: 0.29, blue: 0.27, alpha: 1),
                    position: SCNVector3(bx, buildingHeight + 0.06, bz), into: tile)
        } else if h % 100 < 62 {
            // Small pocket garden with a tree and a low wall.
            makeBox(SCNVector3(3.0, 0.08, 3.0), color: grass, position: SCNVector3(3.0, 0.02, 2.5), into: tile)
            let trunk = SCNCylinder(radius: 0.16, height: 1.6)
            trunk.firstMaterial = material(UIColor(red: 0.31, green: 0.23, blue: 0.16, alpha: 1))
            let trunkNode = SCNNode(geometry: trunk)
            trunkNode.position = SCNVector3(3.0, 0.85, 2.5)
            tile.addChildNode(trunkNode)
            let crown = SCNSphere(radius: 0.9)
            crown.firstMaterial = material(UIColor(red: 0.20, green: 0.34, blue: 0.20, alpha: 1))
            let crownNode = SCNNode(geometry: crown)
            crownNode.position = SCNVector3(3.0, 2.0, 2.5)
            tile.addChildNode(crownNode)
        }

        // A few pedestrians inhabit the streets. Their clothing and proportions stay subtle.
        if h % 9 == 0 {
            addNPC(at: SCNVector3(Float((h % 5) - 2) * 1.2, 0, Float((h % 7) - 3) * 1.0), seed: h, into: tile)
        }

        if h % 13 == 0 {
            let poleGeo = SCNCylinder(radius: 0.055, height: 3.4)
            poleGeo.firstMaterial = material(UIColor(white: 0.20, alpha: 1))
            let pole = SCNNode(geometry: poleGeo)
            pole.position = SCNVector3(-4.2, 1.7, -4.1)
            tile.addChildNode(pole)
            let lamp = SCNSphere(radius: 0.12)
            lamp.firstMaterial = material(UIColor(red: 0.92, green: 0.85, blue: 0.66, alpha: 1))
            lamp.firstMaterial?.emission.contents = UIColor(red: 0.65, green: 0.55, blue: 0.32, alpha: 1)
            let lampNode = SCNNode(geometry: lamp)
            lampNode.position = SCNVector3(-4.2, 3.35, -4.1)
            tile.addChildNode(lampNode)
        }
    }

    private func addNPC(at position: SCNVector3, seed: Int, into tile: SCNNode) {
        let npc = SCNNode()
        npc.name = "dream-npc"
        npc.position = position
        let skinColors: [UIColor] = [
            UIColor(red: 0.73, green: 0.53, blue: 0.39, alpha: 1),
            UIColor(red: 0.48, green: 0.32, blue: 0.23, alpha: 1),
            UIColor(red: 0.88, green: 0.70, blue: 0.55, alpha: 1)
        ]
        let shirtColors: [UIColor] = [
            UIColor(red: 0.30, green: 0.36, blue: 0.42, alpha: 1),
            UIColor(red: 0.42, green: 0.25, blue: 0.20, alpha: 1),
            UIColor(red: 0.30, green: 0.35, blue: 0.25, alpha: 1),
            UIColor(red: 0.58, green: 0.56, blue: 0.49, alpha: 1)
        ]
        let skin = skinColors[seed % skinColors.count]
        let shirt = shirtColors[seed % shirtColors.count]
        let torso = SCNCapsule(capRadius: 0.19, height: 0.72)
        torso.firstMaterial = material(shirt)
        let body = SCNNode(geometry: torso)
        body.position = SCNVector3(0, 0.98, 0)
        npc.addChildNode(body)
        let head = SCNSphere(radius: 0.19)
        head.firstMaterial = material(skin)
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 1.52, 0)
        npc.addChildNode(headNode)
        for side in [-1.0, 1.0] {
            let arm = SCNCylinder(radius: 0.065, height: 0.52)
            arm.firstMaterial = material(skin)
            let armNode = SCNNode(geometry: arm)
            armNode.position = SCNVector3(Float(side) * 0.25, 0.99, 0)
            armNode.eulerAngles.z = Float(side) * 0.18
            npc.addChildNode(armNode)
            let leg = SCNCylinder(radius: 0.085, height: 0.55)
            leg.firstMaterial = material(UIColor(red: 0.15, green: 0.17, blue: 0.19, alpha: 1))
            let legNode = SCNNode(geometry: leg)
            legNode.position = SCNVector3(Float(side) * 0.12, 0.38, 0)
            npc.addChildNode(legNode)
        }
        tile.addChildNode(npc)
        let distance = CGFloat(3.0 + Double(seed % 6))
        let duration = 4.0 + Double(seed % 5)
        let walk = SCNAction.sequence([
            .moveBy(x: distance, y: 0, z: 0, duration: duration),
            .rotateBy(x: 0, y: .pi, z: 0, duration: 0.35),
            .moveBy(x: -distance, y: 0, z: 0, duration: duration),
            .rotateBy(x: 0, y: .pi, z: 0, duration: 0.35)
        ])
        npc.runAction(.repeatForever(walk))
    }

    func look(deltaX: CGFloat, deltaY: CGFloat) {
        cameraNode.eulerAngles.y -= Float(deltaX) * 0.0035
        cameraNode.eulerAngles.x = min(max(cameraNode.eulerAngles.x - Float(deltaY) * 0.0025, -0.78), 0.78)
    }

    func movePlayer(direction: String) {
        let yaw = cameraNode.eulerAngles.y
        let forwardX = -sin(yaw)
        let forwardZ = -cos(yaw)
        let rightX = cos(yaw)
        let rightZ = -sin(yaw)
        var dx: Float = 0
        var dz: Float = 0
        switch direction {
        case "up": dx = forwardX; dz = forwardZ
        case "down": dx = -forwardX; dz = -forwardZ
        case "left": dx = -rightX; dz = -rightZ
        case "right": dx = rightX; dz = rightZ
        default: return
        }
        // Move a short, walkable distance per tap, relative to where the camera faces.
        let distance: Float = 2.4
        worldX += dx * distance
        worldZ += dz * distance
        playerX = Int((worldX / tileSize).rounded())
        playerZ = Int((worldZ / tileSize).rounded())
        cameraNode.runAction(.move(to: SCNVector3(worldX, height, worldZ), duration: 0.18))
        refreshWorld()
        soundUpdater?("step")
    }

    func performDreamAction(_ action: String) {
        switch action {
        case "shift":
            alternateReality.toggle()
            background.contents = alternateReality
                ? UIColor(red: 0.34, green: 0.36, blue: 0.40, alpha: 1)
                : UIColor(red: 0.47, green: 0.62, blue: 0.75, alpha: 1)
            statusUpdater?(alternateReality ? "DREAM SHIFT" : "REALITY NORMAL")
            soundUpdater?("shift")
        case "manifest":
            let k = key(playerX, playerZ - 1)
            crystals[k]?.removeFromParentNode()
            let geo = SCNSphere(radius: 0.18)
            geo.firstMaterial = material(UIColor(red: 0.78, green: 0.83, blue: 0.85, alpha: 1), roughness: 0.3)
            let node = SCNNode(geometry: geo)
            node.position = SCNVector3(worldX - sin(cameraNode.eulerAngles.y) * 2.2, 1.1, worldZ - cos(cameraNode.eulerAngles.y) * 2.2)
            node.runAction(.repeatForever(.sequence([.scale(to: 1.12, duration: 1.2), .scale(to: 0.88, duration: 1.2)])))
            rootNode.addChildNode(node)
            crystals[k] = node
            statusUpdater?("OBJECT MANIFESTED")
            soundUpdater?("manifest")
        case "memory", "teleport":
            let targets = tiles.keys.compactMap { k -> (Int, Int)? in
                let p = k.split(separator: ",").compactMap { Int($0) }
                guard p.count == 2, hash(p[0], p[1]) % 100 < 42 else { return nil }
                return (p[0], p[1])
            }.sorted { abs($0.0-playerX) + abs($0.1-playerZ) < abs($1.0-playerX) + abs($1.1-playerZ) }
            if let target = targets.last {
                playerX = target.0
                playerZ = target.1
                worldX = Float(playerX) * tileSize
                worldZ = Float(playerZ) * tileSize
                cameraNode.position = SCNVector3(worldX, height, worldZ)
                refreshWorld()
                statusUpdater?("MEMORY JUMP")
                soundUpdater?("teleport")
            }
        case "flight":
            flightEnabled.toggle()
            height = flightEnabled ? 5.0 : 1.65
            cameraNode.runAction(.move(to: SCNVector3(worldX, height, worldZ), duration: 0.45))
            statusUpdater?(flightEnabled ? "FLOATING" : "GROUNDED")
            soundUpdater?("flight")
        case "ascend":
            height = min(height + 1.5, 16)
            cameraNode.runAction(.move(to: SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize), duration: 0.3))
            statusUpdater?("ASCENDING")
            soundUpdater?("flight")
        case "descend":
            height = max(height - 1.5, 1.0)
            cameraNode.runAction(.move(to: SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize), duration: 0.3))
            statusUpdater?("DESCENDING")
            soundUpdater?("flight")
        case "time":
            timeBent.toggle()
            cameraNode.camera?.fieldOfView = timeBent ? 88 : 72
            statusUpdater?(timeBent ? "TIME DISTORTION" : "TIME NORMAL")
            soundUpdater?("shift")
        case "gravity":
            gravityInverted.toggle()
            height = gravityInverted ? max(height, 5.0) : 1.65
            cameraNode.runAction(.move(to: SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize), duration: 0.3))
            statusUpdater?(gravityInverted ? "LOW GRAVITY" : "GRAVITY NORMAL")
            soundUpdater?("flight")
        case "phase":
            phaseEnabled.toggle()
            cameraNode.camera?.zFar = phaseEnabled ? 260 : 180
            statusUpdater?(phaseEnabled ? "PERCEPTION EXPANDED" : "PERCEPTION NORMAL")
            soundUpdater?("shift")
        case "bend":
            worldBent.toggle()
            for node in tiles.values {
                node.runAction(.rotateTo(x: 0, y: worldBent ? 0.035 : 0, z: 0, duration: 0.5))
            }
            statusUpdater?(worldBent ? "SPACE FEELS WRONG" : "SPACE NORMAL")
            soundUpdater?("shift")
        case "dream":
            let lines = ["YOU KNOW THIS STREET.", "THE DREAM FEELS FAMILIAR.", "THAT PERSON LOOKED AT YOU.", "YOU HAVE BEEN HERE BEFORE.", "SOMETHING IS SLIGHTLY OFF."]
            statusUpdater?(lines[hash(playerX, playerZ) % lines.count])
            soundUpdater?("memory")
        default:
            break
        }
    }
}
