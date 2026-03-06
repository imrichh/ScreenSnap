# ScreenSnap

A lightweight macOS menu bar app that watches your Desktop for new screenshots and lets you quickly copy them to the clipboard.

## Features

- Lives in the menu bar — no Dock icon
- Automatically detects new screenshots on your Desktop
- Shows a thumbnail preview in a popover
- **Option+S** global hotkey to instantly copy the latest screenshot to clipboard
- "Reveal in Finder" to jump to the file
- Optional launch at login
- Plays a sound on successful copy

## Requirements

- macOS 13+ (Ventura or later)
- Accessibility permission (required for the global hotkey)

## Installation

Download the latest `.zip` from [Releases](../../releases), unzip, and drag **ScreenSnap.app** to your Applications folder.

On first launch, macOS will ask you to grant Accessibility permission in **System Settings > Privacy & Security > Accessibility**.

## Building from Source

Open `ScreenSnap.xcodeproj` in Xcode and build (Cmd+B). No external dependencies.

## Usage

1. Take a screenshot as usual (Cmd+Shift+3 or Cmd+Shift+4)
2. Press **Option+S** to copy it to your clipboard, or click the menu bar icon to preview and copy

## License

MIT
