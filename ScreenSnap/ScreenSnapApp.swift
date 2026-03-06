import SwiftUI
import AppKit

@main
struct ScreenSnapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let store = ScreenshotStore()
    private var watcher: ScreenshotWatcher!
    private let hotkey = GlobalHotKey()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up menu bar status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.viewfinder",
                                   accessibilityDescription: "ScreenSnap")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Set up popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 340, height: 300)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarPopover(store: store)
        )

        // Start watching for screenshots
        watcher = ScreenshotWatcher { [weak self] url in
            self?.store.update(with: url)
        }
        watcher.start()

        // Register global hotkey
        GlobalHotKey.checkAccessibilityPermission()
        hotkey.register(store: store)
    }

    func applicationWillTerminate(_ notification: Notification) {
        watcher?.stop()
        hotkey.unregister()
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Bring popover window to front
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
