import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var vm: TimerViewModel
    @State private var customQuoteText = ""
    @State private var customQuoteAuthor = ""

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            quotesTab
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 460, height: 340)
        .background(Color(red: 0.06, green: 0.06, blue: 0.13))
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $vm.appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .onChange(of: vm.appTheme) { _ in vm.saveSettings() }
            }

            Section("Quotes") {
                Picker("Rotate every", selection: $vm.quoteRotationInterval) {
                    ForEach(QuoteRotationInterval.allCases) { interval in
                        Text(interval.label).tag(interval)
                    }
                }
                .onChange(of: vm.quoteRotationInterval) { _ in vm.saveSettings() }
            }

            Section("Menu Bar") {
                Toggle("Show remaining time in menu bar", isOn: $vm.showInMenuBar)
                    .onChange(of: vm.showInMenuBar) { _ in vm.saveSettings() }
            }

            Section("Sessions") {
                HStack {
                    Text("Total sessions: \(vm.sessions.count)")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Clear History", role: .destructive) {
                        vm.clearHistory()
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.red)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .padding()
    }

    // MARK: - Quotes Tab

    private var quotesTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Built-in Library")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            Text("FocusFlow includes \(Quote.all.count) curated motivational quotes spanning deep work, Stoic philosophy, mindfulness, and achievement.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(Quote.all.prefix(10)) { quote in
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\"\(quote.text)\"")
                                .font(.system(size: 12, design: .serif))
                                .italic()
                                .foregroundColor(.white.opacity(0.7))
                            Text("— \(quote.author)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }

                    if Quote.all.count > 10 {
                        Text("… and \(Quote.all.count - 10) more")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
        }
        .padding(.top)
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("⏱")
                .font(.system(size: 52))

            VStack(spacing: 6) {
                Text("FocusFlow")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Version 1.0")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Text("A distraction-free focus timer for macOS.\nSet your intention. Own your time.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 24) {
                Label("\(vm.completedSessionsCount) sessions", systemImage: "checkmark.seal")
                Label("\(vm.totalFocusMinutes)m focused", systemImage: "clock")
            }
            .font(.system(size: 12))
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}

