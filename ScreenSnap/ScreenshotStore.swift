import SwiftUI
import AppKit
import AudioToolbox

final class ScreenshotStore: ObservableObject {
    @Published var latestScreenshotURL: URL?
    @Published var thumbnail: NSImage?
    private var cachedImageData: Data?

    private let logFile = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Desktop/screensnap-debug.log")

    private func log(_ msg: String) {
        let line = "\(Date()): \(msg)\n"
        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile.path) {
                if let handle = try? FileHandle(forWritingTo: logFile) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: logFile)
            }
        }
    }

    func update(with url: URL) {
        let data = try? Data(contentsOf: url)
        log("update called with: \(url.path), data size: \(data?.count ?? -1)")
        DispatchQueue.main.async {
            self.latestScreenshotURL = url
            self.cachedImageData = data
            if let data = data, let image = NSImage(data: data) {
                self.thumbnail = self.makeThumbnail(from: image, maxDimension: 300)
                self.log("thumbnail created OK")
            } else {
                self.log("thumbnail creation FAILED")
            }
        }
    }

    func copyToClipboard() {
        log("copyToClipboard called, url: \(latestScreenshotURL?.path ?? "NIL")")

        guard let url = latestScreenshotURL else {
            log("BAIL: no URL")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            log("BAIL: could not read file data")
            return
        }

        let pb = NSPasteboard.general
        pb.clearContents()

        // Write both image data and file URL so it works everywhere
        pb.setData(data, forType: .png)
        pb.writeObjects([url as NSURL])

        log("clipboard set with PNG data + file URL")
        AudioServicesPlaySystemSound(1004)
    }

    func openInFinder() {
        guard let url = latestScreenshotURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func makeThumbnail(from image: NSImage, maxDimension: CGFloat) -> NSImage? {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }

        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)

        let thumb = NSImage(size: newSize)
        thumb.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: size),
                   operation: .copy, fraction: 1.0)
        thumb.unlockFocus()
        return thumb
    }
}
