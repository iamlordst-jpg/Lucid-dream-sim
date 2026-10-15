import SwiftUI
import SceneKit
import UIKit
import AVFoundation

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
    @State private var status = "TAKE A BREATH"
    @State private var soundEnabled = true
    @State private var showMorePowers = false

    var body: some View {
        ZStack {
            Dream3DView(moveDirection: moveDirection, moveToken: moveToken,
                        dreamAction: dreamAction, actionToken: actionToken,
                        status: $status, soundEnabled: soundEnabled)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.white.opacity(0.85)).frame(width: 6, height: 6)
                            Text("LUCID")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .tracking(2.5)
                        }
                        Text("DREAM JOURNAL  /  SESSION 01")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .tracking(0.7)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("DREAM STATE")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.6))
                            Text(status)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .lineLimit(2)
                                .multilineTextAlignment(.trailing)
                        }
                        Button {
                            soundEnabled.toggle()
                            DreamSoundscape.shared.setEnabled(soundEnabled)
                        } label: {
                            Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(width: 34, height: 34)
                                .background(.ultraThinMaterial, in: Circle())
                                .overlay(Circle().stroke(.white.opacity(0.16), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                Spacer()

                HStack(alignment: .bottom, spacing: 12) {
                    movementPad
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing, spacing: 8) {
                        if showMorePowers {
                            HStack(spacing: 7) {
                                powerButton("LOW GRAVITY", icon: "arrow.up.and.down", action: "gravity")
                                powerButton("TIME", icon: "clock", action: "time")
                            }
                            HStack(spacing: 7) {
                                powerButton("PHASE", icon: "circle.dotted", action: "phase")
                                powerButton("DREAM LOGIC", icon: "eye", action: "dream")
                            }
                            HStack(spacing: 7) {
                                powerButton("SPACE", icon: "move.3d", action: "bend")
                                powerButton("MEMORY", icon: "point.topleft.down.curvedto.point.bottomright.up", action: "teleport")
                            }
                        } else {
                            HStack(spacing: 7) {
                                powerButton("FLY", icon: "wind", action: "flight")
                                powerButton("CREATE", icon: "plus", action: "manifest")
                                powerButton("SHIFT", icon: "circle.lefthalf.filled", action: "shift")
                            }
                            HStack(spacing: 7) {
                                powerButton("RISE", icon: "arrow.up", action: "ascend")
                                powerButton("FALL", icon: "arrow.down", action: "descend")
                                Button {
                                    showMorePowers = true
                                } label: {
                                    VStack(spacing: 5) {
                                        Image(systemName: "ellipsis").font(.system(size: 15, weight: .bold))
                                        Text("MORE").font(.system(size: 8, weight: .bold, design: .monospaced))
                                    }
                                    .frame(width: 61, height: 52)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.18), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if showMorePowers {
                            Button {
                                showMorePowers = false
                            } label: {
                                Label("BACK TO POWERS", systemImage: "chevron.down")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.78))
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(.black.opacity(0.28), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 20)
            }
        }
        .statusBarHidden()
        .onAppear { DreamSoundscape.shared.setEnabled(soundEnabled) }
    }

    private var movementPad: some View {
        VStack(spacing: 5) {
            moveButton("chevron.up", direction: "up")
            HStack(spacing: 5) {
                moveButton("chevron.left", direction: "left")
                moveButton("circle.fill", direction: "idle", quiet: true)
                moveButton("chevron.right", direction: "right")
            }
            moveButton("chevron.down", direction: "down")
            Text("MOVE  •  DRAG TO LOOK")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .tracking(0.4)
                .foregroundStyle(.white.opacity(0.72))
                .padding(.top, 3)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 19))
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(.white.opacity(0.16), lineWidth: 1))
    }

    private func moveButton(_ symbol: String, direction: String, quiet: Bool = false) -> some View {
        Button {
            moveDirection = direction
            moveToken = UUID()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: quiet ? 6 : 13, weight: .bold))
                .foregroundStyle(.white.opacity(quiet ? 0.16 : 0.95))
                .frame(width: 32, height: 30)
                .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Move \(direction)")
    }

    private func powerButton(_ title: String, icon: String, action: String) -> some View {
        Button {
            dreamAction = action
            actionToken = UUID()
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 14, weight: .semibold))
                Text(title).font(.system(size: 8, weight: .bold, design: .monospaced)).lineLimit(1).minimumScaleFactor(0.7)
            }
            .frame(width: 61, height: 52)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.18), lineWidth: 1))
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
    let soundEnabled: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = Dream3DScene()
        view.scene = scene
        context.coordinator.scene = scene
        view.backgroundColor = UIColor(red: 0.47, green: 0.62, blue: 0.75, alpha: 1)
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .none
        view.preferredFramesPerSecond = 30
        view.isPlaying = true
        scene.statusUpdater = { message in DispatchQueue.main.async { status = message } }
        scene.soundUpdater = { sound in
            if soundEnabled { DreamSoundscape.shared.play(sound) }
        }
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard let scene = view.scene as? Dream3DScene else { return }
        context.coordinator.scene = scene
        scene.statusUpdater = { message in DispatchQueue.main.async { status = message } }
        scene.soundUpdater = { sound in
            if soundEnabled { DreamSoundscape.shared.play(sound) }
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
            scene?.look(deltaX: translation.x - previousTranslation.x, deltaY: translation.y - previousTranslation.y)
            previousTranslation = translation
            if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                previousTranslation = .zero
            }
        }
    }
}

/// Procedural synthesized ambience and action sounds: no downloaded audio assets required.
final class DreamSoundscape {
    static let shared = DreamSoundscape()
    private var ambience: AVAudioPlayer?
    private var effectPlayers: [AVAudioPlayer] = []
    private var enabled = true

    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
        let data = Self.makeWave(seconds: 5, frequency: 76, ambient: true)
        ambience = try? AVAudioPlayer(data: data)
        ambience?.numberOfLoops = -1
        ambience?.volume = 0.14
        ambience?.prepareToPlay()
    }

    func setEnabled(_ value: Bool) {
        enabled = value
        if value { ambience?.play() } else { ambience?.stop() }
    }

    func play(_ kind: String) {
        guard enabled else { return }
        let settings: (Double, Double, Double)
        switch kind {
        case "step": settings = (0.075, 105, 0.11)
        case "manifest": settings = (0.48, 540, 0.22)
        case "teleport": settings = (0.38, 290, 0.22)
        case "flight": settings = (0.30, 180, 0.16)
        case "memory": settings = (0.55, 390, 0.18)
        default: settings = (0.42, 235, 0.18)
        }
        guard let player = try? AVAudioPlayer(data: Self.makeWave(seconds: settings.0, frequency: settings.1, ambient: false)) else { return }
        effectPlayers.removeAll { !$0.isPlaying }
        effectPlayers.append(player)
        player.volume = Float(settings.2)
        player.prepareToPlay()
        player.play()
    }

    private static func makeWave(seconds: Double, frequency: Double, ambient: Bool) -> Data {
        let sampleRate = 22050
        let count = Int(Double(sampleRate) * seconds)
        var pcm = Data(capacity: count * 2)
        var noiseState: UInt32 = 0x12345678
        for i in 0..<count {
            let t = Double(i) / Double(sampleRate)
            let envelope: Double
            if ambient {
                envelope = 0.45 + 0.10 * sin(t * 0.7) + 0.05 * sin(t * 1.3)
            } else {
                let fadeIn = min(1.0, t / 0.025)
                let fadeOut = min(1.0, (seconds - t) / max(0.08, seconds * 0.38))
                envelope = max(0, fadeIn * fadeOut) * exp(-t * 1.7)
            }
            noiseState = 1664525 &* noiseState &+ 1013904223
            let noise = (Double(noiseState & 0xffff) / 32767.5 - 1.0)
            let base = sin(2 * Double.pi * frequency * t)
            let harmonic = sin(2 * Double.pi * frequency * 1.51 * t) * 0.28
            let sample: Double
            if ambient {
                sample = (base * 0.25 + harmonic * 0.12 + noise * 0.20) * envelope
            } else {
                let glide = sin(2 * Double.pi * (frequency * t + 120 * t * t))
                sample = (base * 0.48 + harmonic * 0.18 + glide * 0.20) * envelope
            }
            var value = Int16(max(-1, min(1, sample)) * 25000).littleEndian
            withUnsafeBytes(of: &value) { pcm.append(contentsOf: $0) }
        }
        var header = Data()
        func appendASCII(_ value: String) { header.append(contentsOf: value.utf8) }
        func append32(_ value: UInt32) {
            var v = value.littleEndian
            withUnsafeBytes(of: &v) { header.append(contentsOf: $0) }
        }
        func append16(_ value: UInt16) {
            var v = value.littleEndian
            withUnsafeBytes(of: &v) { header.append(contentsOf: $0) }
        }
        appendASCII("RIFF")
        append32(UInt32(36 + pcm.count))
        appendASCII("WAVEfmt ")
        append32(16)
        append16(1)
        append16(1)
        append32(UInt32(sampleRate))
        append32(UInt32(sampleRate * 2))
        append16(2)
        append16(16)
        appendASCII("data")
        append32(UInt32(pcm.count))
        header.append(pcm)
        return header
    }
}
