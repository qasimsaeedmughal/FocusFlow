import SwiftUI
import AppKit

// MARK: - Space Key Handler (macOS 13 compatible)
// Uses NSEvent local monitor to intercept space bar

struct SpaceKeyHandler: NSViewRepresentable {
    let action: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyCapturingView()
        view.onSpaceBar = action
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? KeyCapturingView)?.onSpaceBar = action
    }
}

// MARK: - Escape Key Handler

struct EscapeKeyHandler: NSViewRepresentable {
    let action: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = EscapeCapturingView()
        view.onEscape = action
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? EscapeCapturingView)?.onEscape = action
    }
}

// MARK: - Key Capturing Views

private class KeyCapturingView: NSView {
    var onSpaceBar: (() -> Void)?
    private var monitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.keyCode == 49 { // space
                    DispatchQueue.main.async {
                        self?.onSpaceBar?()
                    }
                    return nil // consume event
                }
                return event
            }
        } else {
            if let m = monitor {
                NSEvent.removeMonitor(m)
                monitor = nil
            }
        }
    }

    deinit {
        if let m = monitor {
            NSEvent.removeMonitor(m)
        }
    }
}

private class EscapeCapturingView: NSView {
    var onEscape: (() -> Void)?
    private var monitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.keyCode == 53 { // escape
                    DispatchQueue.main.async {
                        self?.onEscape?()
                    }
                    return nil
                }
                return event
            }
        } else {
            if let m = monitor {
                NSEvent.removeMonitor(m)
                monitor = nil
            }
        }
    }

    deinit {
        if let m = monitor {
            NSEvent.removeMonitor(m)
        }
    }
}

