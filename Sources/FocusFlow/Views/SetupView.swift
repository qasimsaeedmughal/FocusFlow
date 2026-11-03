import SwiftUI

// MARK: - Setup View

struct SetupView: View {
    @EnvironmentObject var vm: TimerViewModel

    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 25
    @State private var selectedSeconds: Int = 0
    @State private var isHovering: Bool = false

    // MARK: Quick Presets
    private let presets: [(String, Int, Int, Int)] = [
        ("25m", 0, 25, 0),
        ("45m", 0, 45, 0),
        ("1hr", 1, 0, 0),
        ("2hr", 2, 0, 0),
    ]

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            VStack(spacing: 0) {
                Spacer()

                // MARK: App Header
                headerSection
                    .padding(.bottom, 40)

                // MARK: Session Name
                sessionNameField
                    .padding(.horizontal, 60)
                    .padding(.bottom, 32)

                // MARK: Time Picker
                timePickerSection
                    .padding(.bottom, 28)

                // MARK: Quick Presets
                presetButtonRow
                    .padding(.bottom, 48)

                // MARK: Start Button
                startButton
                    .padding(.bottom, 20)

                Spacer()

                // History hint
                historyHint
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Subviews

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.08, green: 0.05, blue: 0.20),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("⏱")
                .font(.system(size: 56))

            Text("FocusFlow")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hue: 0.65, saturation: 0.4, brightness: 0.95)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Set your intention. Own your time.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .tracking(1)
        }
    }

    private var sessionNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SESSION NAME")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)

            TextField("What will you focus on?", text: $vm.sessionName)
                .textFieldStyle(.plain)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
        }
    }

    private var timePickerSection: some View {
        VStack(spacing: 12) {
            Text("DURATION")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)

            HStack(spacing: 0) {
                pickerColumn(
                    value: $selectedHours,
                    range: 0...23,
                    label: "HRS",
                    onChanged: syncTime
                )
                separatorColon
                pickerColumn(
                    value: $selectedMinutes,
                    range: 0...59,
                    label: "MIN",
                    onChanged: syncTime
                )
                separatorColon
                pickerColumn(
                    value: $selectedSeconds,
                    range: 0...59,
                    label: "SEC",
                    onChanged: syncTime
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 60)
        }
    }

    private func pickerColumn(value: Binding<Int>, range: ClosedRange<Int>, label: String, onChanged: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            // Up button
            Button(action: {
                let next = value.wrappedValue + 1
                value.wrappedValue = next > range.upperBound ? range.lowerBound : next
                onChanged()
            }) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .buttonStyle(.plain)

            // Value display
            Text(String(format: "%02d", value.wrappedValue))
                .font(.system(size: 36, weight: .thin, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 72, height: 50)
                .contentShape(Rectangle())

            // Down button
            Button(action: {
                let prev = value.wrappedValue - 1
                value.wrappedValue = prev < range.lowerBound ? range.upperBound : prev
                onChanged()
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
                .tracking(1.5)
        }
    }

    private var separatorColon: some View {
        Text(":")
            .font(.system(size: 28, weight: .light, design: .monospaced))
            .foregroundColor(.white.opacity(0.3))
            .padding(.bottom, 20)
            .padding(.horizontal, 4)
    }

    private var presetButtonRow: some View {
        VStack(spacing: 10) {
            Text("QUICK PRESETS")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)

            HStack(spacing: 12) {
                ForEach(presets, id: \.0) { preset in
                    PresetButton(label: preset.0) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedHours = preset.1
                            selectedMinutes = preset.2
                            selectedSeconds = preset.3
                            syncTime()
                        }
                    }
                }
            }
        }
    }

    private var startButton: some View {
        Button(action: {
            guard vm.totalSeconds > 0 else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                vm.startTimer()
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Start Focus Session")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: 0.65, saturation: 0.7, brightness: 0.95),
                                Color(hue: 0.60, saturation: 0.8, brightness: 0.90),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color(hue: 0.65, saturation: 0.7, brightness: 0.8).opacity(0.4), radius: 20, y: 8)
            )
        }
        .buttonStyle(.plain)
        .disabled(vm.totalSeconds == 0)
        .scaleEffect(isHovering ? 1.03 : 1.0)
        .animation(.spring(response: 0.2), value: isHovering)
        .onHover { isHovering = $0 }
    }

    private var historyHint: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 12))
            Text("\(vm.completedSessionsCount) sessions completed · \(vm.totalFocusMinutes)m focused")
                .font(.system(size: 12, design: .rounded))
        }
        .foregroundColor(.white.opacity(0.25))
    }

    // MARK: - Helpers

    private func syncTime() {
        let total = selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds
        vm.totalSeconds = max(1, total)
        vm.remainingSeconds = vm.totalSeconds
    }
}

// MARK: - Preset Button Component

struct PresetButton: View {
    let label: String
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isHovering ? .white : .white.opacity(0.7))
                .frame(width: 60, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isHovering ? Color.white.opacity(0.15) : Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    Color.white.opacity(isHovering ? 0.25 : 0.10),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
    }
}
