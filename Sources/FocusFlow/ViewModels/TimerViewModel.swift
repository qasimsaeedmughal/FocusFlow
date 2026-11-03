import SwiftUI
import AppKit
import Combine

// MARK: - Timer State

enum TimerState: Equatable {
    case setup
    case running
    case paused
    case completed
}

// MARK: - App Color Scheme Preference

enum AppTheme: String, CaseIterable, Identifiable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"
    var id: String { rawValue }
}

// MARK: - Quote Rotation Interval

enum QuoteRotationInterval: Double, CaseIterable, Identifiable {
    case thirtySeconds = 30
    case sixtySeconds = 60
    case ninetySeconds = 90
    case never = 0

    var id: Double { rawValue }
    var label: String {
        switch self {
        case .thirtySeconds: return "30 seconds"
        case .sixtySeconds: return "60 seconds"
        case .ninetySeconds: return "90 seconds"
        case .never: return "Never"
        }
    }
}

// MARK: - TimerViewModel

@MainActor
final class TimerViewModel: ObservableObject {

    // MARK: Timer State
    @Published var timerState: TimerState = .setup
    @Published var totalSeconds: Int = 25 * 60
    @Published var remainingSeconds: Int = 25 * 60
    @Published var sessionName: String = "Focus Session"

    // MARK: Quote State
    @Published var currentQuote: Quote = Quote.all.randomElement() ?? Quote.all[0]
    @Published var quoteOpacity: Double = 1.0

    // MARK: Session History
    @Published var sessions: [TimerSession] = []

    // MARK: Settings
    @Published var appTheme: AppTheme = .dark
    @Published var quoteRotationInterval: QuoteRotationInterval = .sixtySeconds
    @Published var showInMenuBar: Bool = false

    // MARK: Internal
    private var countdownTask: Task<Void, Never>?
    private var quoteRotationTask: Task<Void, Never>?
    private var sessionStartDate: Date?
    private var quoteIndex: Int = 0
    private var shuffledQuotes: [Quote] = Quote.all.shuffled()

    // MARK: Computed Properties

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    var timeString: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var ringColor: Color {
        let p = progress
        if p < 0.5 {
            // Blue → purple blend
            return Color(hue: 0.65 - p * 0.15, saturation: 0.8, brightness: 0.95)
        } else if p < 0.8 {
            // Purple → orange blend
            let t = (p - 0.5) / 0.3
            return Color(hue: 0.5 - t * 0.45, saturation: 0.85, brightness: 0.95)
        } else {
            // Orange → red
            let t = (p - 0.8) / 0.2
            return Color(hue: 0.05 - t * 0.05, saturation: 0.9, brightness: 0.95)
        }
    }

    var isPulsing: Bool {
        progress > 0.8 && timerState == .running
    }

    var completedSessionsCount: Int {
        sessions.filter { $0.completed }.count
    }

    var totalFocusMinutes: Int {
        sessions.filter { $0.completed }.reduce(0) { $0 + $1.elapsedDuration } / 60
    }

    var weeklyFocusMinutes: Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions
            .filter { $0.completed && $0.date >= oneWeekAgo }
            .reduce(0) { $0 + $1.elapsedDuration } / 60
    }

    init() {
        loadSessions()
        loadSettings()
        quoteIndex = Int.random(in: 0..<shuffledQuotes.count)
        currentQuote = shuffledQuotes[quoteIndex]
    }

    // MARK: - Timer Controls

    func startTimer() {
        remainingSeconds = totalSeconds
        sessionStartDate = Date()
        timerState = .running
        startCountdown()
        startQuoteRotation()
    }

    func pauseTimer() {
        timerState = .paused
        countdownTask?.cancel()
        quoteRotationTask?.cancel()
    }

    func resumeTimer() {
        timerState = .running
        startCountdown()
        startQuoteRotation()
    }

    func resetTimer() {
        countdownTask?.cancel()
        quoteRotationTask?.cancel()
        remainingSeconds = totalSeconds
        timerState = .setup
    }

    func adjustTime(by delta: Int) {
        let newRemaining = remainingSeconds + delta
        let newTotal = totalSeconds + delta
        remainingSeconds = max(60, newRemaining)
        totalSeconds = max(60, newTotal)
    }

    // MARK: - Completion Actions

    func markCompleted() {
        let elapsed = totalSeconds - remainingSeconds + 1
        let session = TimerSession(
            date: sessionStartDate ?? Date(),
            totalDuration: totalSeconds,
            elapsedDuration: elapsed,
            name: sessionName,
            completed: true
        )
        sessions.insert(session, at: 0)
        saveSessions()
        timerState = .setup
        remainingSeconds = totalSeconds
    }

    func resetAndTryAgain() {
        let elapsed = totalSeconds
        let session = TimerSession(
            date: sessionStartDate ?? Date(),
            totalDuration: totalSeconds,
            elapsedDuration: elapsed,
            name: sessionName,
            completed: false
        )
        sessions.insert(session, at: 0)
        saveSessions()
        // restart immediately
        remainingSeconds = totalSeconds
        sessionStartDate = Date()
        timerState = .running
        startCountdown()
        startQuoteRotation()
    }

    func startNewSession() {
        countdownTask?.cancel()
        quoteRotationTask?.cancel()
        timerState = .setup
        remainingSeconds = totalSeconds
    }

    func clearHistory() {
        sessions.removeAll()
        saveSessions()
    }

    // MARK: - Private: Countdown

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.timerState = .completed
                    self.playChime()
                    break
                }
            }
        }
    }

    // MARK: - Private: Quote Rotation

    private func startQuoteRotation() {
        quoteRotationTask?.cancel()
        guard quoteRotationInterval != .never else { return }
        let interval = quoteRotationInterval.rawValue
        quoteRotationTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                if Task.isCancelled { break }
                await self.animateQuoteTransition()
            }
        }
    }

    private func animateQuoteTransition() async {
        withAnimation(.easeOut(duration: 0.6)) {
            quoteOpacity = 0
        }
        try? await Task.sleep(for: .seconds(0.65))
        quoteIndex = (quoteIndex + 1) % shuffledQuotes.count
        currentQuote = shuffledQuotes[quoteIndex]
        withAnimation(.easeIn(duration: 0.6)) {
            quoteOpacity = 1
        }
    }

    // MARK: - Private: Sound

    private func playChime() {
        // Try Glass sound (macOS built-in), fall back to Ping
        if let sound = NSSound(named: "Glass") {
            sound.play()
        } else {
            NSSound(named: "Ping")?.play()
        }
        // Play twice with delay for emphasis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            NSSound(named: "Glass")?.play()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            NSSound(named: "Glass")?.play()
        }
    }

    // MARK: - Persistence

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "focusflow.sessions"),
           let decoded = try? JSONDecoder().decode([TimerSession].self, from: data) {
            sessions = decoded
        }
    }

    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "focusflow.sessions")
        }
    }

    private func loadSettings() {
        if let themeName = UserDefaults.standard.string(forKey: "focusflow.theme"),
           let theme = AppTheme(rawValue: themeName) {
            appTheme = theme
        }
        if let intervalValue = UserDefaults.standard.object(forKey: "focusflow.quoteInterval") as? Double,
           let interval = QuoteRotationInterval(rawValue: intervalValue) {
            quoteRotationInterval = interval
        }
        showInMenuBar = UserDefaults.standard.bool(forKey: "focusflow.menuBar")
    }

    func saveSettings() {
        UserDefaults.standard.set(appTheme.rawValue, forKey: "focusflow.theme")
        UserDefaults.standard.set(quoteRotationInterval.rawValue, forKey: "focusflow.quoteInterval")
        UserDefaults.standard.set(showInMenuBar, forKey: "focusflow.menuBar")
    }
}

