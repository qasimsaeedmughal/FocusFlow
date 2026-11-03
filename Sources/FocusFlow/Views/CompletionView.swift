import SwiftUI

// MARK: - Confetti Particle

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var rotation: Double
    var vx: CGFloat
    var vy: CGFloat
    var angularVelocity: Double
    var opacity: Double
}

// MARK: - Confetti View

private struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animating = false

    private let colors: [Color] = [
        Color(hue: 0.65, saturation: 0.7, brightness: 0.95),
        Color(hue: 0.12, saturation: 0.8, brightness: 0.95),
        Color(hue: 0.55, saturation: 0.75, brightness: 0.90),
        Color(hue: 0.08, saturation: 0.9, brightness: 1.0),
        Color(hue: 0.35, saturation: 0.7, brightness: 0.85),
        .white,
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let elapsed = timeline.date.timeIntervalSince(Date())
                    let px = particle.x + particle.vx * CGFloat(elapsed * 60)
                    let py = particle.y + particle.vy * CGFloat(elapsed * 60) + 0.5 * CGFloat(elapsed * elapsed * 200)
                    let rot = particle.rotation + particle.angularVelocity * elapsed * 60
                    let fade = max(0, particle.opacity - elapsed * 0.5)

                    let path = Path(CGRect(x: -particle.size / 2, y: -particle.size / 4, width: particle.size, height: particle.size / 2))
                    context.opacity = fade
                    context.translateBy(x: px, y: py)
                    context.rotate(by: .degrees(rot))
                    context.fill(path, with: .color(particle.color))
                    context.rotate(by: .degrees(-rot))
                    context.translateBy(x: -px, y: -py)
                }
            }
        }
        .onAppear { spawnParticles() }
        .allowsHitTesting(false)
    }

    private func spawnParticles() {
        particles = (0..<80).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 100...700),
                y: CGFloat.random(in: -50...50),
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 6...14),
                rotation: Double.random(in: 0...360),
                vx: CGFloat.random(in: -3...3),
                vy: CGFloat.random(in: 2...8),
                angularVelocity: Double.random(in: -8...8),
                opacity: 1.0
            )
        }
    }
}

// MARK: - Completion View

struct CompletionView: View {
    @EnvironmentObject var vm: TimerViewModel

    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0
    @State private var showConfetti = true
    @State private var checkmarkScale: CGFloat = 0

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            // Confetti burst
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }

            // Completion Card
            completionCard
                .scaleEffect(cardScale)
                .opacity(cardOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        cardScale = 1.0
                        cardOpacity = 1.0
                    }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                        checkmarkScale = 1.0
                    }
                    // Stop confetti after 4s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.easeOut(duration: 1)) {
                            showConfetti = false
                        }
                    }
                }
        }
    }

    private var completionCard: some View {
        VStack(spacing: 0) {
            // Header area
            VStack(spacing: 16) {
                // Animated check ring
                ZStack {
                    Circle()
                        .fill(Color(hue: 0.38, saturation: 0.6, brightness: 0.35).opacity(0.4))
                        .frame(width: 90, height: 90)

                    Circle()
                        .strokeBorder(
                            Color(hue: 0.38, saturation: 0.7, brightness: 0.8),
                            lineWidth: 2.5
                        )
                        .frame(width: 90, height: 90)

                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(Color(hue: 0.38, saturation: 0.6, brightness: 0.9))
                        .scaleEffect(checkmarkScale)
                }

                Text("Time's Up!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 4) {
                    Text("You focused for")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))

                    Text(vm.timeString == "00:00" ? formatDuration(vm.totalSeconds) : formatDuration(vm.totalSeconds))
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.85))

                    if !vm.sessionName.isEmpty {
                        Text("on \"\(vm.sessionName)\"")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hue: 0.65, saturation: 0.5, brightness: 0.9))
                    }
                }
            }
            .padding(.top, 36)
            .padding(.horizontal, 32)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 24)
                .padding(.vertical, 28)

            // Action Buttons
            VStack(spacing: 12) {
                // ✅ Mark Complete
                completionButton(
                    icon: "checkmark.seal.fill",
                    title: "Yes, I completed it!",
                    subtitle: "Mark this session as done",
                    color: Color(hue: 0.38, saturation: 0.7, brightness: 0.8),
                    action: {
                        withAnimation(.spring()) {
                            vm.markCompleted()
                        }
                    }
                )

                // 🔄 Reset & Try Again
                completionButton(
                    icon: "arrow.counterclockwise.circle.fill",
                    title: "Not quite — try again",
                    subtitle: "Reset and restart the timer",
                    color: Color(hue: 0.12, saturation: 0.7, brightness: 0.9),
                    action: {
                        withAnimation(.spring()) {
                            vm.resetAndTryAgain()
                        }
                    }
                )

                // ⏭ New Session
                completionButton(
                    icon: "plus.circle.fill",
                    title: "Start a new session",
                    subtitle: "Return to setup screen",
                    color: Color(hue: 0.60, saturation: 0.6, brightness: 0.85),
                    action: {
                        withAnimation(.spring()) {
                            vm.startNewSession()
                        }
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.10, blue: 0.18),
                            Color(red: 0.07, green: 0.07, blue: 0.14),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 40, y: 20)
        )
        .frame(maxWidth: 400)
        .padding(.horizontal, 40)
    }

    private func completionButton(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(color)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%dh %02dm", h, m) }
        if m > 0 { return String(format: "%dm %02ds", m, s) }
        return String(format: "%ds", s)
    }
}
