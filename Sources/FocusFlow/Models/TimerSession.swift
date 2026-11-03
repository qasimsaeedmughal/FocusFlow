import Foundation

// MARK: - Timer Session Model

struct TimerSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let totalDuration: Int        // total seconds set
    let elapsedDuration: Int      // seconds actually elapsed
    let name: String
    let completed: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalDuration: Int,
        elapsedDuration: Int,
        name: String,
        completed: Bool
    ) {
        self.id = id
        self.date = date
        self.totalDuration = totalDuration
        self.elapsedDuration = elapsedDuration
        self.name = name
        self.completed = completed
    }

    // MARK: - Computed Helpers

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var formattedTotalDuration: String {
        formatSeconds(totalDuration)
    }

    var formattedElapsedDuration: String {
        formatSeconds(elapsedDuration)
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%dh %02dm %02ds", h, m, s)
        } else if m > 0 {
            return String(format: "%dm %02ds", m, s)
        } else {
            return String(format: "%ds", s)
        }
    }
}

