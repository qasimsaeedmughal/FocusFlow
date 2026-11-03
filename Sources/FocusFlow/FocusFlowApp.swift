import SwiftUI
import AppKit

// MARK: - App Entry Point

@main
struct FocusFlowApp: App {
    @StateObject private var viewModel = TimerViewModel()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
                .onAppear {
                    configureWindow()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // Timer Controls menu
            CommandMenu("Timer") {
                Button("Start / Pause") {
                    if viewModel.timerState == .running {
                        viewModel.pauseTimer()
                    } else if viewModel.timerState == .paused {
                        viewModel.resumeTimer()
                    }
                }
                .keyboardShortcut(" ", modifiers: [])

                Button("Reset Timer") {
                    viewModel.resetTimer()
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()

                Button("Add 5 Minutes") {
                    viewModel.adjustTime(by: 300)
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Remove 5 Minutes") {
                    viewModel.adjustTime(by: -300)
                }
                .keyboardShortcut("-", modifiers: .command)
            }

            // Replace default toolbar commands
            CommandGroup(replacing: .newItem) { }
        }

        // Preferences / Settings window
        Settings {
            SettingsView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }

    private func configureWindow() {
        // Remove the default window chrome for cleaner look
        DispatchQueue.main.async {
            NSApp.windows.forEach { window in
                window.titlebarAppearsTransparent = true
                window.backgroundColor = NSColor(red: 0.04, green: 0.04, blue: 0.10, alpha: 1.0)
                window.isMovableByWindowBackground = true
                window.minSize = NSSize(width: 620, height: 720)
            }
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set activation policy for a proper dock app
        NSApp.setActivationPolicy(.regular)
    }
}

