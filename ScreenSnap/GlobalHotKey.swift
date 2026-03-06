import AppKit
import Carbon

private var hotkeyStore: ScreenshotStore?

private func hotkeyHandler(nextHandler: EventHandlerCallRef?, event: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    hotkeyStore?.copyToClipboard()
    return noErr
}

final class GlobalHotKey {
    private var hotkeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    /// Registers Opt+S to copy the latest screenshot to clipboard.
    func register(store: ScreenshotStore) {
        hotkeyStore = store

        // Install Carbon event handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), hotkeyHandler,
                            1, &eventType, nil, &handlerRef)

        // Register Opt+S  (S = keycode 1, opt=0x0800)
        let modifiers: UInt32 = UInt32(optionKey)
        var hotkeyID = EventHotKeyID(signature: OSType(0x5353_4E50), // "SSNP"
                                      id: 1)
        RegisterEventHotKey(UInt32(kVK_ANSI_S), modifiers, hotkeyID,
                            GetApplicationEventTarget(), 0, &hotkeyRef)
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        if let ref = handlerRef {
            RemoveEventHandler(ref)
            handlerRef = nil
        }
        hotkeyStore = nil
    }

    /// Checks if Accessibility permission is granted and prompts if not.
    static func checkAccessibilityPermission() {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "ScreenSnap needs Accessibility access to register the global hotkey (Opt+S). Please grant access in System Settings → Privacy & Security → Accessibility."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Later")

            if alert.runModal() == .alertFirstButtonReturn {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                NSWorkspace.shared.open(url)
            }
        }
    }
}
