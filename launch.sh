#!/bin/bash
# FocusFlow - Launch Script
# Opens the app in Xcode or runs it directly

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Option 1: Open in Xcode (recommended for development)
if command -v xcodebuild &> /dev/null; then
    echo "Opening FocusFlow in Xcode..."
    open "$PROJECT_DIR/Package.swift"
    echo "✅ Opened Package.swift in Xcode. Press ▶ to run."
else
    echo "Xcode not found. Running via swift run..."
    cd "$PROJECT_DIR"
    swift run
fi

