import SwiftUI

// MARK: - History View

struct HistoryView: View {
    @EnvironmentObject var vm: TimerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showClearConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            // Summary cards
            summaryCards
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            Divider()
                .opacity(0.2)

            // Session list
            if vm.sessions.isEmpty {
                emptyState
            } else {
                sessionList
            }
        }
        .background(Color(red: 0.06, green: 0.06, blue: 0.13))
        .frame(minWidth: 400, minHeight: 500)
        .alert("Clear all history?", isPresented: $showClearConfirm) {
            Button("Clear", role: .destructive) { vm.clearHistory() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all session records.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Focus History")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(vm.sessions.count) sessions recorded")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            if !vm.sessions.isEmpty {
                Button(action: { showClearConfirm = true }) {
                    Label("Clear", systemImage: "trash")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            SummaryCard(
                icon: "checkmark.seal.fill",
                iconColor: Color(hue: 0.38, saturation: 0.6, brightness: 0.8),
                value: "\(vm.completedSessionsCount)",
                label: "Completed"
            )
            SummaryCard(
                icon: "clock.fill",
                iconColor: Color(hue: 0.65, saturation: 0.6, brightness: 0.85),
                value: "\(vm.totalFocusMinutes)m",
                label: "Total Focused"
            )
            SummaryCard(
                icon: "calendar",
                iconColor: Color(hue: 0.12, saturation: 0.7, brightness: 0.9),
                value: "\(vm.weeklyFocusMinutes)m",
                label: "This Week"
            )
        }
    }

    // MARK: - Session List

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(vm.sessions) { session in
                    SessionRowView(session: session)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.15))
            Text("No sessions yet")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
            Text("Complete your first focus session\nto see it here.")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.white.opacity(0.2))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Session Row

struct SessionRowView: View {
    let session: TimerSession

    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            Image(systemName: session.completed ? "checkmark.circle.fill" : "arrow.counterclockwise.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(
                    session.completed
                        ? Color(hue: 0.38, saturation: 0.6, brightness: 0.8)
                        : Color(hue: 0.08, saturation: 0.7, brightness: 0.85)
                )

            // Session info
            VStack(alignment: .leading, spacing: 3) {
                Text(session.name.isEmpty ? "Focus Session" : session.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(session.formattedDate)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))

                    Text("·")
                        .foregroundColor(.white.opacity(0.2))

                    Text(session.formattedTotalDuration)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                }
            }

            Spacer()

            // Status badge
            Text(session.completed ? "Done ✓" : "Reset")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(session.completed ? Color(hue: 0.38, saturation: 0.5, brightness: 0.8) : Color(hue: 0.08, saturation: 0.5, brightness: 0.85))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(
                            session.completed
                                ? Color(hue: 0.38, saturation: 0.5, brightness: 0.4).opacity(0.25)
                                : Color(hue: 0.08, saturation: 0.5, brightness: 0.5).opacity(0.2)
                        )
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
        )
    }
}

