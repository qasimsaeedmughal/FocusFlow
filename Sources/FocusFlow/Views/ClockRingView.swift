import SwiftUI

// MARK: - Clock Ring View

struct ClockRingView: View {
    let progress: Double
    let timeString: String
    let color: Color
    let isPulsing: Bool
    let sessionName: String

    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5

    private let ringWidth: CGFloat = 18
    private let ringSize: CGFloat = 280

    var body: some View {
        ZStack {
            // Outer glow ring (ambient)
            Circle()
                .fill(color.opacity(0.06))
                .frame(width: ringSize + 60, height: ringSize + 60)
                .blur(radius: 20)

            // Track ring (background)
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: ringWidth)
                .frame(width: ringSize, height: ringSize)

            // Tick marks
            tickMarks

            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: ringWidth,
                        lineCap: .round
                    )
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: progress)
                // Glow effect on the arc
                .shadow(color: color.opacity(0.6), radius: 8, x: 0, y: 0)

            // Inner subtle ring
            Circle()
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
                .frame(width: ringSize - ringWidth - 12, height: ringSize - ringWidth - 12)

            // Center content
            centerContent

            // Pulse effect when time is running low
            if isPulsing {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: ringSize + 20, height: ringSize + 20)
                    .scaleEffect(pulseScale)
                    .opacity(glowOpacity)
                    .onAppear { startPulse() }
            }
        }
        .scaleEffect(isPulsing ? 1.01 : 1.0)
        .animation(
            isPulsing
                ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                : .default,
            value: isPulsing
        )
    }

    // MARK: - Center Content

    private var centerContent: some View {
        VStack(spacing: 6) {
            // Main time display
            Text(timeString)
                .font(.system(size: 54, weight: .thin, design: .monospaced))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.3), value: timeString)

            // Decorative separator
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 40, height: 0.5)

            // Session name
            Text(sessionName.isEmpty ? "Focus Session" : sessionName)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 200)
        }
    }

    // MARK: - Tick Marks

    private var tickMarks: some View {
        ZStack {
            ForEach(0..<60) { index in
                let isMajor = index % 5 == 0
                Rectangle()
                    .fill(Color.white.opacity(isMajor ? 0.20 : 0.08))
                    .frame(width: isMajor ? 2 : 1, height: isMajor ? 10 : 5)
                    .offset(y: -(ringSize / 2) + ringWidth + (isMajor ? 5 : 7))
                    .rotationEffect(.degrees(Double(index) * 6))
            }
        }
    }

    // MARK: - Pulse Animation

    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.08
            glowOpacity = 0.0
        }
    }
}

