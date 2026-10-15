import SceneKit
import SwiftUI
import UIKit

/// Lightweight first-person 3D dream world built with native SceneKit.
final class Dream3DScene: SCNScene {
    private let tileSize: Float = 4
    private let renderRadius = 8
    private let cameraNode = SCNNode()
    private var tiles: [String: SCNNode] = [:]
    private var crystals: [String: SCNNode] = [:]
    private var playerX = 0
    private var playerZ = 0
    private var alternateReality = false
    private var flightEnabled = false
    private var timeBent = false
    private var gravityInverted = false
    private var phaseEnabled = false
    private var worldBent = false
    private var height: Float = 1.65
    private let seed = 481516
    var statusUpdater: ((String) -> Void)?
    var lastMoveToken = UUID()
    var lastActionToken = UUID()

    override init() {
        super.init()
        background.contents = UIColor(red: 0.018, green: 0.026, blue: 0.09, alpha: 1)
        setupWorld()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWorld()
    }

    private func setupWorld() {
        let camera = SCNCamera()
        camera.fieldOfView = 76
        camera.zFar = 220
        camera.wantsHDR = true
        camera.bloomIntensity = 0.8
        camera.bloomThreshold = 0.75
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, height, 0)
        rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.color = UIColor(red: 0.30, green: 0.36, blue: 0.62, alpha: 1)
        ambient.light?.intensity = 500
        rootNode.addChildNode(ambient)

        let moon = SCNNode()
        moon.light = SCNLight()
        moon.light?.type = .omni
        moon.light?.color = UIColor(red: 0.25, green: 0.75, blue: 1, alpha: 1)
        moon.light?.intensity = 900
        moon.position = SCNVector3(0, 9, -7)
        rootNode.addChildNode(moon)

        addSkyStars()
        refreshWorld()
        addLandmark(atX: 5, z: -9)
        addLandmark(atX: -12, z: -18)
    }

    private func addSkyStars() {
        for i in 0..<90 {
            let h = hash(i, i * 17)
            let star = SCNSphere(radius: CGFloat(0.025 + Double(h % 5) * 0.012))
            star.firstMaterial?.diffuse.contents = UIColor(red: 0.48, green: 0.84, blue: 1, alpha: 1)
            star.firstMaterial?.emission.contents = UIColor.cyan
            let node = SCNNode(geometry: star)
            let x = Float((h % 70) - 35)
            let y = Float(7 + (h % 22))
            let z = Float(-((h * 7) % 70))
            node.position = SCNVector3(x, y, z)
            rootNode.addChildNode(node)
        }
    }

    private func hash(_ x: Int, _ z: Int) -> Int {
        var n = x &* 374761393 &+ z &* 668265263 &+ seed
        n = (n ^ (n >> 13)) &* 1274126177
        return abs(n ^ (n >> 16)) % 1000
    }

    private func key(_ x: Int, _ z: Int) -> String { "\(x),\(z)" }

    private func tileMaterial(_ x: Int, _ z: Int) -> SCNMaterial {
        let h = hash(x, z)
        let color: UIColor
        if alternateReality {
            if h < 120 { color = UIColor(red: 0.30, green: 0.045, blue: 0.34, alpha: 1) }
            else if h < 330 { color = UIColor(red: 0.12, green: 0.06, blue: 0.27, alpha: 1) }
            else { color = UIColor(red: 0.045, green: 0.035, blue: 0.15, alpha: 1) }
        } else {
            if h < 100 { color = UIColor(red: 0.055, green: 0.24, blue: 0.30, alpha: 1) }
            else if h < 300 { color = UIColor(red: 0.075, green: 0.14, blue: 0.27, alpha: 1) }
            else { color = UIColor(red: 0.035, green: 0.065, blue: 0.16, alpha: 1) }
        }
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.roughness.contents = 0.72
        material.metalness.contents = 0.12
        material.emission.contents = color.withAlphaComponent(0.12)
        return material
    }

    private func refreshWorld() {
        var needed = Set<String>()
        for x in (playerX - renderRadius)...(playerX + renderRadius) {
            for z in (playerZ - renderRadius)...(playerZ + renderRadius) {
                let k = key(x, z)
                needed.insert(k)
                if tiles[k] == nil {
                    let geometry = SCNBox(width: CGFloat(tileSize - 0.10), height: 0.16,
                                          length: CGFloat(tileSize - 0.10), chamferRadius: 0.035)
                    geometry.materials = [tileMaterial(x, z)]
                    let node = SCNNode(geometry: geometry)
                    node.position = SCNVector3(Float(x) * tileSize, -0.12, Float(z) * tileSize)
                    rootNode.addChildNode(node)
                    tiles[k] = node

                    let h = hash(x, z)
                    if h < 18 {
                        let orb = SCNSphere(radius: 0.09 + CGFloat(h % 4) * 0.025)
                        orb.firstMaterial?.diffuse.contents = UIColor.cyan
                        orb.firstMaterial?.emission.contents = UIColor.cyan
                        let glimmer = SCNNode(geometry: orb)
                        glimmer.position = SCNVector3(0, 0.22, 0)
                        node.addChildNode(glimmer)
                    }
                    if h > 975 {
                        addLandmark(atX: x, z: z)
                    }
                }
            }
        }
        let staleTileKeys = tiles.keys.filter { !needed.contains($0) }
        for k in staleTileKeys {
            tiles[k]?.removeFromParentNode()
            tiles.removeValue(forKey: k)
        }
        let staleCrystalKeys = crystals.keys.filter { k in
            let parts = k.split(separator: ",").compactMap { Int($0) }
            return parts.count != 2 || abs(parts[0] - playerX) > renderRadius + 2 || abs(parts[1] - playerZ) > renderRadius + 2
        }
        for k in staleCrystalKeys {
            crystals[k]?.removeFromParentNode()
            crystals.removeValue(forKey: k)
        }
    }

    private func addLandmark(atX x: Int, z: Int) {
        let arch = SCNTorus(ringRadius: 0.95, pipeRadius: 0.075)
        arch.firstMaterial?.diffuse.contents = alternateReality ? UIColor.systemPink : UIColor.cyan
        arch.firstMaterial?.emission.contents = alternateReality ? UIColor.systemPink : UIColor.cyan
        let node = SCNNode(geometry: arch)
        node.position = SCNVector3(Float(x) * tileSize, 1.05, Float(z) * tileSize)
        node.eulerAngles.x = .pi / 2
        node.name = "dream-arch"
        rootNode.addChildNode(node)
        let pillarGeometry = SCNCylinder(radius: 0.09, height: 2.1)
        pillarGeometry.firstMaterial?.diffuse.contents = arch.firstMaterial?.diffuse.contents
        for side in [-1.0, 1.0] {
            let pillar = SCNNode(geometry: pillarGeometry)
            pillar.position = SCNVector3(Float(x) * tileSize + Float(side) * 0.95, 1.0, Float(z) * tileSize)
            rootNode.addChildNode(pillar)
        }
    }

    func movePlayer(direction: String) {
        switch direction {
        case "up": playerZ -= 1
        case "down": playerZ += 1
        case "left": playerX -= 1
        case "right": playerX += 1
        default: return
        }
        cameraNode.runAction(.move(to: SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize), duration: 0.12))
        refreshWorld()
    }

    func performDreamAction(_ action: String) {
        switch action {
        case "shift":
            alternateReality.toggle()
            background.contents = alternateReality
                ? UIColor(red: 0.12, green: 0.018, blue: 0.16, alpha: 1)
                : UIColor(red: 0.018, green: 0.026, blue: 0.09, alpha: 1)
            for (k, node) in tiles {
                let parts = k.split(separator: ",").compactMap { Int($0) }
                if parts.count == 2, let box = node.geometry as? SCNBox { box.materials = [tileMaterial(parts[0], parts[1])] }
            }
            for node in rootNode.childNodes where node.name == "dream-arch" {
                node.geometry?.firstMaterial?.diffuse.contents = alternateReality ? UIColor.systemPink : UIColor.cyan
                node.geometry?.firstMaterial?.emission.contents = alternateReality ? UIColor.systemPink : UIColor.cyan
            }
            statusUpdater?(alternateReality ? "REALITY SHIFTED" : "REALITY STABILIZED")
        case "manifest":
            let k = key(playerX, playerZ - 1)
            crystals[k]?.removeFromParentNode()
            let gem = SCNPyramid(width: 0.8, height: 1.15, length: 0.8)
            gem.firstMaterial?.diffuse.contents = alternateReality ? UIColor.systemPink : UIColor.cyan
            gem.firstMaterial?.emission.contents = alternateReality ? UIColor.systemPink : UIColor.cyan
            gem.firstMaterial?.metalness.contents = 0.6
            let node = SCNNode(geometry: gem)
            node.position = SCNVector3(Float(playerX) * tileSize, 0.7, Float(playerZ - 1) * tileSize)
            node.runAction(.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 3)))
            rootNode.addChildNode(node)
            crystals[k] = node
            statusUpdater?("THOUGHT MADE REAL")
        case "memory", "teleport":
            let destinations = tiles.keys.compactMap { k -> (Int, Int)? in
                let p = k.split(separator: ",").compactMap { Int($0) }
                guard p.count == 2, hash(p[0], p[1]) > 965 else { return nil }
                return (p[0], p[1])
            }.sorted { abs($0.0-playerX) + abs($0.1-playerZ) < abs($1.0-playerX) + abs($1.1-playerZ) }
            if let target = destinations.first {
                playerX = target.0
                playerZ = target.1
                cameraNode.position = SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize)
                refreshWorld()
                statusUpdater?("TELEPORTED TO A MEMORY")
            } else {
                statusUpdater?("NO MEMORY NEARBY")
            }
        case "flight":
            flightEnabled.toggle()
            height = flightEnabled ? 5.0 : 1.65
            cameraNode.runAction(.move(to: SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize), duration: 0.45))
            statusUpdater?(flightEnabled ? "FLIGHT ENABLED" : "FLIGHT DISABLED")
        case "ascend":
            height = min(height + 2.0, 22)
            cameraNode.runAction(.move(to: SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize), duration: 0.22))
            statusUpdater?("ASCENDING")
        case "descend":
            height = max(height - 2.0, 0.7)
            cameraNode.runAction(.move(to: SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize), duration: 0.22))
            statusUpdater?("DESCENDING")
        case "time":
            timeBent.toggle()
            cameraNode.camera?.fieldOfView = timeBent ? 94 : 76
            statusUpdater?(timeBent ? "TIME DISTORTION" : "TIME RESTORED")
        case "gravity":
            gravityInverted.toggle()
            height = gravityInverted ? max(height, 5.0) : 1.65
            cameraNode.runAction(.move(to: SCNVector3(Float(playerX) * tileSize, height, Float(playerZ) * tileSize), duration: 0.3))
            statusUpdater?(gravityInverted ? "GRAVITY REVERSED" : "GRAVITY RESTORED")
        case "phase":
            phaseEnabled.toggle()
            cameraNode.camera?.zFar = phaseEnabled ? 400 : 220
            statusUpdater?(phaseEnabled ? "PHASE WALK ENABLED" : "PHASE WALK DISABLED")
        case "bend":
            worldBent.toggle()
            for (k, node) in tiles {
                let parts = k.split(separator: ",").compactMap { Int($0) }
                guard parts.count == 2 else { continue }
                let wave = worldBent ? sin(Float(parts[0] * 2 + parts[1]) * 0.5) * 0.65 : 0
                node.position.y = -0.12 + wave
            }
            statusUpdater?(worldBent ? "WORLD BENT" : "WORLD NORMALIZED")
        case "dream":
            let names = ["THE HALLWAY HAS NO END", "YOU REMEMBER THIS PLACE", "THE SKY IS A CEILING", "SOMEONE MOVED THE MOON", "THIS IS NOT YOUR FIRST DREAM"]
            statusUpdater?(names[hash(playerX, playerZ) % names.count])
        default:
            break
        }
    }
}
