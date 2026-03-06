import SwiftUI

struct MenuBarPopover: View {
    @ObservedObject var store: ScreenshotStore
    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var copied = false

    var body: some View {
        VStack(spacing: 12) {
            if let thumb = store.thumbnail {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 200)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No screenshot captured yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 100)
            }

            HStack(spacing: 8) {
                Button(action: {
                    store.copyToClipboard()
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        copied = false
                    }
                }) {
                    Label(copied ? "Copied!" : "Copy to Clipboard",
                          systemImage: copied ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .disabled(store.latestScreenshotURL == nil)

                Button(action: { store.openInFinder() }) {
                    Label("Reveal in Finder", systemImage: "folder")
                }
                .disabled(store.latestScreenshotURL == nil)
            }
            .buttonStyle(.bordered)

            Text("⌥S to copy to clipboard")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.6))

            Divider()

            HStack {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLogin.setEnabled(newValue)
                    }
                    .toggleStyle(.switch)
                    .controlSize(.small)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 340)
    }
}
