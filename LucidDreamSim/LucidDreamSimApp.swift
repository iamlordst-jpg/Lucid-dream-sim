import SwiftUI
import SceneKit
import UIKit

@main
struct LucidDreamSimApp: App {
    var body: some Scene {
        WindowGroup {
            DreamGameView()
                .preferredColorScheme(.dark)
        }
    }
}

struct DreamGameView: View {
    @State private var moveToken = UUID()
    @State private var moveDirection = "idle"
    @State private var actionToken = UUID()
    @State private var dreamAction = "none"
    @State private var status = "THE DREAM IS YOURS"
    @State private var hud = DreamHUD.load()

    var body: some View {
        ZStack {
            Dream3DView(moveDirection: moveDirection, moveToken: moveToken,
                        dreamAction: dreamAction, actionToken: actionToken,
                        status: $status)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("LUCID")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .tracking(4)
                        Text("DREAM SIM  •  3D PROTOTYPE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(1.2)
                            .foregroundStyle(.cyan.opacity(0.9))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("DREAM STATE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.55))
                        Text(status)
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(status.contains("FLUX") || status.contains("SHIFT") ? .pink : .cyan)
                            .lineLimit(2)
                            .frame(maxWidth: 155, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                HStack(spacing: 8) {
                    statPill("MODE", value: "FIRST PERSON", icon: "viewfinder")
                    statPill("POWERS", value: "UNLOCKED", icon: "sparkles")
                    statPill("WORLD", value: "ENDLESS", icon: "infinity")
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)

                Spacer()

                HStack(alignment: .bottom, spacing: 12) {
                    VStack(spacing: 5) {
                        moveButton("arrowtriangle.up.fill", direction: "up")
                        HStack(spacing: 5) {
                            moveButton("arrowtriangle.left.fill", direction: "left")
                            moveButton("circle.fill", direction: "idle")
                            moveButton("arrowtriangle.right.fill", direction: "right")
                        }
                        moveButton("arrowtriangle.down.fill", direction: "down")
                        Text("MOVE")
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.55))
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 6) {
                            powerButton("FLY", icon: "wind", action: "flight", tint: .cyan)
                            powerButton("UP", icon: "arrow.up", action: "ascend", tint: .cyan)
                            powerButton("DOWN", icon: "arrow.down", action: "descend", tint: .cyan)
                        }
                        HStack(spacing: 6) {
                            powerButton("SHIFT", icon: "waveform.path", action: "shift", tint: .pink)
                            powerButton("CREATE", icon: "sparkle", action: "manifest", tint: .cyan)
                            powerButton("TELEPORT", icon: "point.topleft.down.curvedto.point.bottomright.up", action: "teleport", tint: .purple)
                        }
                        HStack(spacing: 6) {
                            powerButton("SLOW TIME", icon: "hourglass", action: "time", tint: .orange)
                            powerButton("GRAVITY", icon: "arrow.up.arrow.down", action: "gravity", tint: .purple)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                powerButton("PHASE WALK", icon: "aqi.low", action: "phase", tint: .mint)
                                powerButton("BEND WORLD", icon: "water.waves", action: "bend", tint: .pink)
                                powerButton("DREAM LOGIC", icon: "eye", action: "dream", tint: .yellow)
                            }
                        }
                    }
                    .frame(maxWidth: 225)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
        }
        .statusBarHidden()
    }

    private func statPill(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(.cyan)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 7, weight: .bold, design: .monospaced)).foregroundStyle(.white.opacity(0.55))
                Text(value).font(.system(size: 9, weight: .black, design: .monospaced))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8).padding(.vertical, 9)
        .background(.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 11))
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(.white.opacity(0.10), lineWidth: 1))
    }

    private func moveButton(_ symbol: String, direction: String) -> some View {
        Button {
            moveDirection = direction
            moveToken = UUID()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: direction == "idle" ? 7 : 13, weight: .black))
                .foregroundStyle(.white.opacity(direction == "idle" ? 0.25 : 0.95))
                .frame(width: 38, height: 36)
                .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 11))
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(.white.opacity(0.16), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Move \(direction)")
    }

    private func powerButton(_ title: String, icon: String, action: String, tint: Color) -> some View {
        Button {
            dreamAction = action
            actionToken = UUID()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 13, weight: .bold)).foregroundStyle(tint)
                Text(title).font(.system(size: 7, weight: .black, design: .monospaced)).foregroundStyle(.white)
                    .lineLimit(1).minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, minHeight: 43)
            .padding(.horizontal, 5)
            .background(.black.opacity(0.72), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(tint.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct Dream3DView: UIViewRepresentable {
    let moveDirection: String
    let moveToken: UUID
    let dreamAction: String
    let actionToken: UUID
    @Binding var status: String

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = Dream3DScene()
        view.scene = scene
        context.coordinator.scene = scene
        view.backgroundColor = UIColor(red: 0.018, green: 0.026, blue: 0.09, alpha: 1)
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .none
        view.preferredFramesPerSecond = 30
        view.isPlaying = true
        scene.statusUpdater = { message in
            DispatchQueue.main.async { status = message }
        }
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard let scene = view.scene as? Dream3DScene else { return }
        context.coordinator.scene = scene
        scene.statusUpdater = { message in
            DispatchQueue.main.async { status = message }
        }
        if scene.lastMoveToken != moveToken {
            scene.lastMoveToken = moveToken
            scene.movePlayer(direction: moveDirection)
        }
        if scene.lastActionToken != actionToken {
            scene.lastActionToken = actionToken
            scene.performDreamAction(dreamAction)
        }
    }

    final class Coordinator: NSObject {
        weak var scene: Dream3DScene?
        private var previousTranslation = CGPoint.zero

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            let dx = translation.x - previousTranslation.x
            let dy = translation.y - previousTranslation.y
            scene?.look(deltaX: dx, deltaY: dy)
            previousTranslation = translation
            if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                previousTranslation = .zero
            }
        }
    }
}

struct DreamHUD: Codable {
    var memories = 0
    var manifests = 0
    var alternateReality = false

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "lucid.dreamsim.hud.v1")
    }

    static func load() -> DreamHUD {
        guard let data = UserDefaults.standard.data(forKey: "lucid.dreamsim.hud.v1"),
              let saved = try? JSONDecoder().decode(DreamHUD.self, from: data) else { return DreamHUD() }
        return saved
    }
}
