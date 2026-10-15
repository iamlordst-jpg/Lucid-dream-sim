import SpriteKit
import SwiftUI
import UIKit

final class DreamScene: SKScene {
    private let tile: CGFloat = 42
    private let viewRadius = 11
    private let cameraNode = SKCameraNode()
    private let player = SKShapeNode(circleOfRadius: 10)
    private var renderedTiles: [String: SKNode] = [:]
    private var manifestNodes: [String: SKNode] = [:]
    private var playerX = 0
    private var playerY = 0
    private var currentHUD = DreamHUD.load()
    private var lastMemoryAt = ""
    private let worldSeed: Int = 481516
    var hudUpdater: ((DreamHUD) -> Void)?
    var lastMoveToken = UUID()
    var lastActionToken = UUID()

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.025, green: 0.035, blue: 0.11, alpha: 1)
        if camera == nil {
            addChild(cameraNode)
            camera = cameraNode
        }
        configurePlayer()
        drawNearbyWorld()
        addDreamDust()
        updateCamera()
    }

    private func configurePlayer() {
        player.fillColor = .white
        player.strokeColor = SKColor(red: 0.30, green: 0.92, blue: 1, alpha: 1)
        player.lineWidth = 3
        player.glowWidth = 13
        player.zPosition = 100
        player.position = .zero
        if player.parent == nil { cameraNode.addChild(player) }
        let core = SKShapeNode(circleOfRadius: 3)
        core.fillColor = SKColor(red: 0.4, green: 0.95, blue: 1, alpha: 1)
        core.strokeColor = .clear
        core.position = CGPoint(x: 2, y: 2)
        core.zPosition = 1
        player.addChild(core)
        player.run(.repeatForever(.sequence([.scale(to: 1.15, duration: 0.8), .scale(to: 0.92, duration: 0.8)])), withKey: "pulse")
    }

    func movePlayer(direction: String) {
        switch direction {
        case "up": playerY += 1
        case "down": playerY -= 1
        case "left": playerX -= 1
        case "right": playerX += 1
        default: return
        }
        let target = CGPoint(x: CGFloat(playerX) * tile, y: CGFloat(playerY) * tile)
        cameraNode.run(.move(to: target, duration: 0.10))
        drawNearbyWorld()
        checkDiscovery()
    }

    func performDreamAction(_ action: String) {
        switch action {
        case "shift":
            currentHUD.alternateReality.toggle()
            backgroundColor = currentHUD.alternateReality
                ? SKColor(red: 0.13, green: 0.025, blue: 0.18, alpha: 1)
                : SKColor(red: 0.025, green: 0.035, blue: 0.11, alpha: 1)
            for (key, node) in renderedTiles {
                guard let coords = parse(key), let tileNode = node as? SKShapeNode else { continue }
                tileNode.fillColor = tileColor(atX: coords.0, y: coords.1)
                tileNode.run(.fadeAlpha(to: 0.72, duration: 0.15))
                tileNode.run(.fadeAlpha(to: 1.0, duration: 0.25))
            }
            showToast(currentHUD.alternateReality ? "REALITY SHIFTED" : "REALITY STABILIZED", tint: .systemPink)
            currentHUD.save()
            hudUpdater?(currentHUD)
        case "manifest":
            let x = playerX + 1
            let y = playerY
            let key = "\(x),\(y)"
            manifestNodes[key]?.removeFromParent()
            let crystal = SKShapeNode(path: diamondPath(size: 15))
            crystal.fillColor = currentHUD.alternateReality ? .systemPink : .cyan
            crystal.strokeColor = .white
            crystal.lineWidth = 1
            crystal.glowWidth = 12
            crystal.position = CGPoint(x: CGFloat(x) * tile, y: CGFloat(y) * tile)
            crystal.zPosition = 20
            addChild(crystal)
            crystal.run(.repeatForever(.sequence([.rotate(byAngle: .pi, duration: 2), .rotate(byAngle: .pi, duration: 2)])))
            manifestNodes[key] = crystal
            currentHUD.manifests += 1
            showToast("THOUGHT MADE REAL", tint: .cyan)
            currentHUD.save()
            hudUpdater?(currentHUD)
        case "memory":
            let candidates = nearbyMemoryPositions()
            guard let pos = candidates.first else { showToast("THE DREAM IS QUIET", tint: .purple); return }
            playerX = pos.0
            playerY = pos.1
            let target = CGPoint(x: CGFloat(playerX) * tile, y: CGFloat(playerY) * tile)
            cameraNode.run(.move(to: target, duration: 0.25))
            drawNearbyWorld()
            checkDiscovery(force: true)
        default:
            break
        }
    }

    private func tileKey(_ x: Int, _ y: Int) -> String { "\(x),\(y)" }

    private func hash(_ x: Int, _ y: Int) -> Int {
        var n = x &* 374761393 &+ y &* 668265263 &+ worldSeed
        n = (n ^ (n >> 13)) &* 1274126177
        return abs(n ^ (n >> 16)) % 1000
    }

    private func tileColor(atX x: Int, y: Int) -> SKColor {
        let h = hash(x, y)
        if currentHUD.alternateReality {
            if h < 65 { return SKColor(red: 0.58, green: 0.10, blue: 0.55, alpha: 1) }
            if h < 130 { return SKColor(red: 0.14, green: 0.10, blue: 0.36, alpha: 1) }
            return SKColor(red: 0.08, green: 0.06, blue: 0.22, alpha: 1)
        }
        if h < 60 { return SKColor(red: 0.08, green: 0.20, blue: 0.29, alpha: 1) }
        if h < 145 { return SKColor(red: 0.12, green: 0.16, blue: 0.31, alpha: 1) }
        if h < 220 { return SKColor(red: 0.10, green: 0.28, blue: 0.31, alpha: 1) }
        return SKColor(red: 0.08, green: 0.12, blue: 0.23, alpha: 1)
    }

    private func drawNearbyWorld() {
        let centerX = playerX
        let centerY = playerY
        var needed = Set<String>()
        for x in (centerX - viewRadius)...(centerX + viewRadius) {
            for y in (centerY - viewRadius)...(centerY + viewRadius) {
                let key = tileKey(x,y)
                needed.insert(key)
                if renderedTiles[key] == nil {
                    let h = hash(x,y)
                    let node: SKNode
                    let rect = SKShapeNode(rectOf: CGSize(width: tile - 2, height: tile - 2), cornerRadius: 5)
                    rect.fillColor = tileColor(atX: x, y: y)
                    rect.strokeColor = SKColor(white: 1, alpha: 0.045)
                    rect.lineWidth = 0.8
                    rect.position = CGPoint(x: CGFloat(x) * tile, y: CGFloat(y) * tile)
                    rect.zPosition = -10
                    node = rect
                    addChild(node)
                    renderedTiles[key] = node

                    if h < 42 {
                        let star = SKShapeNode(circleOfRadius: CGFloat(1 + h % 3))
                        star.fillColor = currentHUD.alternateReality ? .systemPink : .cyan
                        star.strokeColor = .clear
                        star.glowWidth = 4
                        star.position = CGPoint(x: CGFloat((h % 17) - 8),
                                                y: CGFloat((h % 13) - 6))
                        star.zPosition = -5
                        addChild(star)
                        node.userData = NSMutableDictionary()
                        node.userData?["starName"] = "dream"
                        node.addChild(star)
                    } else if h > 930 {
                        let arch = SKShapeNode(rectOf: CGSize(width: 19, height: 27), cornerRadius: 8)
                        arch.fillColor = .clear
                        arch.strokeColor = currentHUD.alternateReality ? .systemPink : .systemTeal
                        arch.lineWidth = 2
                        arch.glowWidth = 5
                        arch.position = CGPoint(x: 0, y: 5)
                        arch.zPosition = 2
                        addChild(arch)
                        node.addChild(arch)
                    }
                }
            }
        }
        let stale = renderedTiles.keys.filter { !needed.contains($0) }
        for key in stale { renderedTiles[key]?.removeFromParent(); renderedTiles.removeValue(forKey: key) }
        let distantManifestKeys = manifestNodes.keys.filter { key in
            guard let coords = parse(key) else { return true }
            return abs(coords.0 - playerX) > viewRadius + 3 || abs(coords.1 - playerY) > viewRadius + 3
        }
        for key in distantManifestKeys {
            manifestNodes[key]?.removeFromParent()
            manifestNodes.removeValue(forKey: key)
        }
    }

    private func updateCamera() {
        cameraNode.position = CGPoint(x: CGFloat(playerX) * tile, y: CGFloat(playerY) * tile)
        player.position = .zero
    }

    private func addDreamDust() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(image: particleImage())
        emitter.particleBirthRate = 7
        emitter.particleLifetime = 8
        emitter.particlePositionRange = CGVector(dx: size.width * 1.5, dy: size.height * 1.5)
        emitter.particleSpeed = 4
        emitter.particleSpeedRange = 7
        emitter.particleAlpha = 0.4
        emitter.particleAlphaRange = 0.3
        emitter.particleScale = 0.6
        emitter.particleScaleRange = 0.7
        emitter.particleColor = .cyan
        emitter.particleBlendMode = .add
        emitter.zPosition = 200
        cameraNode.addChild(emitter)
    }

    private func particleImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8))
        return renderer.image { context in
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 1, y: 1, width: 6, height: 6))
        }
    }

    private func diamondPath(size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: size * 0.65, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -size))
        path.addLine(to: CGPoint(x: -size * 0.65, y: 0))
        path.closeSubpath()
        return path
    }

    private func parse(_ key: String) -> (Int, Int)? {
        let parts = key.split(separator: ",")
        guard parts.count == 2, let x = Int(parts[0]), let y = Int(parts[1]) else { return nil }
        return (x,y)
    }

    private func nearbyMemoryPositions() -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        for radius in 3...viewRadius {
            for x in (playerX-radius)...(playerX+radius) {
                for y in (playerY-radius)...(playerY+radius) {
                    if hash(x,y) > 965 && (x != playerX || y != playerY) {
                        result.append((x,y))
                    }
                }
            }
            if !result.isEmpty { break }
        }
        return result.sorted { abs($0.0-playerX)+abs($0.1-playerY) < abs($1.0-playerX)+abs($1.1-playerY) }
    }

    private func checkDiscovery(force: Bool = false) {
        let h = hash(playerX, playerY)
        let key = tileKey(playerX, playerY)
        if force || (h > 965 && lastMemoryAt != key) {
            lastMemoryAt = key
            currentHUD.memories += 1
            showToast("MEMORY DISCOVERED  +1", tint: .purple)
            currentHUD.save()
            hudUpdater?(currentHUD)
        }
    }

    private func showToast(_ message: String, tint: SKColor) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = message
        label.fontSize = 12
        label.fontColor = tint
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -size.height * 0.20)
        label.zPosition = 500
        cameraNode.childNode(withName: "dream-toast")?.removeFromParent()
        label.name = "dream-toast"
        cameraNode.addChild(label)
        label.run(.sequence([.wait(forDuration: 1.15), .fadeOut(withDuration: 0.3), .removeFromParent()]))
    }
}
