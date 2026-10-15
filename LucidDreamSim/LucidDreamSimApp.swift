import SwiftUI
import SpriteKit

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
    @State private var hud = DreamHUD.load()

    var body: some View {
        ZStack {
            DreamCanvas(moveDirection: moveDirection, moveToken: moveToken,
                        dreamAction: dreamAction, actionToken: actionToken,
                        hud: $hud)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("LUCID")
                            .font(.system(size: 25, weight: .black, design: .rounded))
                            .tracking(4)
                        Text("DREAM SIM  •  BUILD 001")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(1.5)
                            .foregroundStyle(.cyan.opacity(0.8))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("DREAM CONTROL")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.6))
                        Text(hud.alternateReality ? "REALITY: FLUX" : "REALITY: CALM")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(hud.alternateReality ? .pink : .cyan)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)

                HStack(spacing: 8) {
                    statPill("MEMORIES", value: "\(hud.memories)", icon: "sparkles")
                    statPill("MANIFESTS", value: "\(hud.manifests)", icon: "diamond")
                    statPill("DREAM", value: hud.alternateReality ? "UNSTABLE" : "LUCID", icon: "moon.stars")
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)

                Spacer()

                HStack(alignment: .bottom) {
                    VStack(spacing: 5) {
                        moveButton("arrowtriangle.up.fill", direction: "up")
                        HStack(spacing: 5) {
                            moveButton("arrowtriangle.left.fill", direction: "left")
                            moveButton("circle.fill", direction: "idle")
                            moveButton("arrowtriangle.right.fill", direction: "right")
                        }
                        moveButton("arrowtriangle.down.fill", direction: "down")
                    }

                    Spacer(minLength: 8)

                    VStack(spacing: 10) {
                        actionButton(title: "SHIFT REALITY", subtitle: "Change the dream", icon: "waveform.path", tint: .pink) {
                            trigger("shift")
                        }
                        actionButton(title: "MANIFEST", subtitle: "Create a dream object", icon: "sparkle", tint: .cyan) {
                            trigger("manifest")
                        }
                        actionButton(title: "MEMORY", subtitle: "Find what is hidden", icon: "eye", tint: .purple) {
                            trigger("memory")
                        }
                    }
                    .frame(maxWidth: 188)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 26)
            }
        }
        .statusBarHidden()
    }

    private func statPill(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(.cyan)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 8, weight: .bold, design: .monospaced)).foregroundStyle(.white.opacity(0.55))
                Text(value).font(.system(size: 11, weight: .bold, design: .monospaced))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10).padding(.vertical, 9)
        .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.08), lineWidth: 1))
    }

    private func moveButton(_ symbol: String, direction: String) -> some View {
        Button {
            moveDirection = direction
            moveToken = UUID()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: direction == "idle" ? 8 : 15, weight: .black))
                .foregroundStyle(.white.opacity(direction == "idle" ? 0.3 : 0.95))
                .frame(width: 43, height: 40)
                .background(.black.opacity(0.48), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.14), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Move \(direction)")
    }

    private func actionButton(title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 17, weight: .bold)).foregroundStyle(tint).frame(width: 25)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 11, weight: .black, design: .rounded))
                    Text(subtitle).font(.system(size: 9)).foregroundStyle(.white.opacity(0.6))
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12).padding(.vertical, 11)
            .background(.black.opacity(0.68), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.48), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func trigger(_ action: String) {
        dreamAction = action
        actionToken = UUID()
    }
}

struct DreamCanvas: UIViewRepresentable {
    let moveDirection: String
    let moveToken: UUID
    let dreamAction: String
    let actionToken: UUID
    @Binding var hud: DreamHUD

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.preferredFramesPerSecond = 60
        let scene = DreamScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        scene.hudUpdater = { newHUD in
            DispatchQueue.main.async { hud = newHUD; newHUD.save() }
        }
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        guard let scene = view.scene as? DreamScene else { return }
        scene.hudUpdater = { newHUD in
            DispatchQueue.main.async { hud = newHUD; newHUD.save() }
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
