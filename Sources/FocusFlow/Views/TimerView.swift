import SwiftUI

// MARK: - Timer View

struct TimerView: View {
    @EnvironmentObject var vm: TimerViewModel

    @State private var controlsVisible = false
    @State private var hoverTimer: Task<Void, Never>?

    var body: some View {
        ZStack {
            // Dynamic background
            timerBackground

            // Main content
            VStack(spacing: 0) {
                Spacer()

                // Clock ring + time display
                ClockRingView(
                    progress: vm.progress,
                    timeString: vm.timeString,
                    color: vm.ringColor,
                    isPulsing: vm.isPulsing,
                    sessionName: vm.sessionName
                )
                .padding(.bottom, 44)

                // Motivational quote
                QuoteView(
                    quote: vm.currentQuote,
                    opacity: vm.quoteOpacity
                )

                Spacer()
            }
            .padding(.bottom, 60) // space for control bar

            // Auto-hiding control bar
            VStack {
                Spacer()
                controlBar
                    .opacity(controlsVisible ? 1 : 0)
                    .offset(y: controlsVisible ? 0 : 20)
                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: controlsVisible)
            }

            // Completion overlay
            if vm.timerState == .completed {
                CompletionView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onHover { hovering in
            if hovering {
                showControls()
            }
        }
        .onMouseMove {
            showControls()
        }
        .background(
            // Space bar: pause/resume — using NSEvent monitor for macOS 13 compat
            SpaceKeyHandler {
                togglePause()
            }
        )
    }

    // MARK: - Background

    private var timerBackground: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.10)
                .ignoresSafeArea()

            // Ambient color orb based on ring color
            RadialGradient(
                colors: [vm.ringColor.opacity(0.12), .clear],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: vm.ringColor)
        }
    }

    // MARK: - Control Bar

    private var controlBar: some View {
        HStack(spacing: 20) {
            // Pause / Resume
            controlBarButton(
                icon: vm.timerState == .running ? "pause.fill" : "play.fill",
                label: vm.timerState == .running ? "Pause" : "Resume"
            ) {
                if vm.timerState == .running {
                    vm.pauseTimer()
                } else {
                    vm.resumeTimer()
                }
            }

            Divider()
                .frame(height: 24)
                .opacity(0.3)

            // -5 minutes
            controlBarButton(icon: "minus.circle", label: "-5m") {
                vm.adjustTime(by: -300)
            }

            // +5 minutes
            controlBarButton(icon: "plus.circle", label: "+5m") {
                vm.adjustTime(by: 300)
            }

            Divider()
                .frame(height: 24)
                .opacity(0.3)

            // Reset
            controlBarButton(icon: "arrow.counterclockwise", label: "Reset") {
                vm.resetTimer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
        )
        .padding(.bottom, 20)
    }

    private func controlBarButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white.opacity(0.8))
            .frame(width: 48)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func showControls() {
        controlsVisible = true
        hoverTimer?.cancel()
        hoverTimer = Task {
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                withAnimation {
                    controlsVisible = false
                }
            }
        }
    }

    private func togglePause() {
        if vm.timerState == .running {
            vm.pauseTimer()
        } else if vm.timerState == .paused {
            vm.resumeTimer()
        }
    }
}

// MARK: - Mouse Move Modifier

extension View {
    func onMouseMove(perform action: @escaping () -> Void) -> some View {
        self.background(MouseMoveDetector(onMove: action))
    }
}

private struct MouseMoveDetector: NSViewRepresentable {
    let onMove: () -> Void

    func makeNSView(context: Context) -> MouseTrackingView {
        let view = MouseTrackingView()
        view.onMove = onMove
        return view
    }

    func updateNSView(_ nsView: MouseTrackingView, context: Context) {
        nsView.onMove = onMove
    }
}

private class MouseTrackingView: NSView {
    var onMove: (() -> Void)?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect],
            owner: self
        )
        addTrackingArea(area)
    }

    override func mouseMoved(with event: NSEvent) {
        onMove?()
    }
}
