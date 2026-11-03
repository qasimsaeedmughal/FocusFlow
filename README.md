# FocusFlow ⏱

> A beautiful, distraction-free focus timer for macOS — with an animated clock ring, motivational quotes, and a smart completion screen.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange) ![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple)

---

## ✨ Features

| Feature | Details |
|---|---|
| ⏱ Clock Ring | Animated circular progress ring with smooth color shifts |
| 🎨 Dynamic Colors | Blue → Amber → Red as time runs low, with pulse effect |
| 💬 Motivational Quotes | 52 curated quotes rotating with fade transitions |
| 🎯 Session Names | Name what you're working on |
| ⚡ Quick Presets | 25m / 45m / 1hr / 2hr one-click presets |
| 🏁 Completion Screen | Confetti burst + 3-option dialog (Done / Reset / New) |
| 🔔 Chime Sound | Triple glass chime when timer ends |
| 📜 History | Full session log with weekly summary |
| ⌨️ Keyboard Shortcuts | Space (pause), Escape (reset), Cmd+R (reset), Cmd+±5m |
| ⚙️ Settings | Theme, quote interval, menu bar toggle |

---

## 🚀 How to Run

### Option A — Open in Xcode (Recommended)

```bash
open Package.swift
```

Xcode will open the Swift package. Press **▶ Run** (or `Cmd+R`) to launch the app.

### Option B — Run from Terminal

```bash
cd FocusFlow
swift run
```

### Option C — Use the launch script

```bash
bash launch.sh
```

---

## 📁 Project Structure

```
FocusFlow/
├── Package.swift                          # Swift Package manifest
├── launch.sh                              # Quick-launch helper
└── Sources/FocusFlow/
    ├── FocusFlowApp.swift                 # @main App entry point, AppDelegate
    ├── ContentView.swift                  # Root navigation + toolbar
    ├── Models/
    │   ├── Quote.swift                    # Quote model + 52 built-in quotes
    │   └── TimerSession.swift             # Session data model (Codable)
    ├── ViewModels/
    │   └── TimerViewModel.swift           # All timer logic, state, persistence
    └── Views/
        ├── SetupView.swift                # Session name + time picker + presets
        ├── TimerView.swift                # Main countdown screen
        ├── ClockRingView.swift            # Animated ring + tick marks + center
        ├── QuoteView.swift                # Rotating motivational quotes
        ├── CompletionView.swift           # Confetti burst + 3-option dialog
        ├── HistoryView.swift              # Session history list + summary cards
        ├── SettingsView.swift             # App preferences (3 tabs)
        └── KeyHandlers.swift              # NSEvent-based keyboard handlers
```

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|---|---|
| `Space` | Pause / Resume timer |
| `Escape` | Reset timer (returns to setup) |
| `Cmd + R` | Reset timer |
| `Cmd + +` | Add 5 minutes |
| `Cmd + -` | Remove 5 minutes |
| `Cmd + ,` | Open Settings |

---

## 🏗 Architecture

**MVVM** pattern throughout:

- **`TimerViewModel`** — Single source of truth. Owns all timer state (`TimerState` enum), async countdown via Swift concurrency `Task`, quote rotation, session history persistence via `UserDefaults`, and sound playback.
- **Views** — Purely declarative, reading from `@EnvironmentObject var vm: TimerViewModel`.
- **Models** — `Quote` and `TimerSession` are simple `Codable` value types.

---

## 🎨 Design Tokens

- **Typography**: SF Pro Display / Rounded / Monospaced (system fonts)
- **Dark background**: `#0A0A1A` with subtle gradient
- **Ring colors**: `hsl(234°, 80%, 95%)` → amber → `hsl(0°, 90%, 95%)`
- **Accent**: Blue-indigo `hsl(234°, 70%, 90%)`
- **Animations**: Spring physics for UI, linear for ring progress, fade for quotes

---

## 🔧 Requirements

- macOS 13.0 Ventura or later
- Xcode 15+ **or** Swift 5.9+ CLI tools

---

*Built with SwiftUI + Swift Concurrency. No third-party dependencies.*

