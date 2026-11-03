import SwiftUI

// MARK: - Content View (Root Navigation)

struct ContentView: View {
    @EnvironmentObject var vm: TimerViewModel
    @State private var showHistory = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Main screen switching
            Group {
                switch vm.timerState {
                case .setup:
                    SetupView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.97)),
                            removal: .opacity.combined(with: .scale(scale: 1.03))
                        ))

                case .running, .paused:
                    TimerView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.03)),
                            removal: .opacity.combined(with: .scale(scale: 0.97))
                        ))

                case .completed:
                    // Timer view stays visible behind the completion overlay
                    TimerView()
                        .transition(.identity)
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: vm.timerState)

            // Top toolbar
            VStack {
                topToolbar
                Spacer()
            }
        }
        .frame(minWidth: 620, idealWidth: 680, minHeight: 720, idealHeight: 780)
        .sheet(isPresented: $showHistory) {
            HistoryView()
                .environmentObject(vm)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(vm)
        }
        // Global keyboard shortcuts
        .background(EscapeKeyHandler {
            if vm.timerState == .running || vm.timerState == .paused {
                vm.resetTimer()
            }
        })
    }

    // MARK: - Top Toolbar

    private var topToolbar: some View {
        HStack {
            Spacer()

            HStack(spacing: 4) {
                // History button
                toolbarButton(icon: "clock.arrow.circlepath", tooltip: "Focus History") {
                    showHistory = true
                }

                // Settings button
                toolbarButton(icon: "slider.horizontal.3", tooltip: "Settings") {
                    showSettings = true
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.top, 16)
            .padding(.trailing, 20)
        }
    }

    private func toolbarButton(icon: String, tooltip: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 30, height: 26)
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }
}
