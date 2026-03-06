import Foundation

final class ScreenshotWatcher {
    private var source: DispatchSourceFileSystemObject?
    private var debounceWork: DispatchWorkItem?
    private let desktopURL: URL
    private let onChange: (URL) -> Void

    // macOS screenshot filename pattern: "Screenshot YYYY-MM-DD at HH.MM.SS.png"
    private let screenshotRegex = try! NSRegularExpression(
        pattern: #"^Screenshot \d{4}-\d{2}-\d{2} at \d{2}\.\d{2}\.\d{2}\.png$"#
    )

    init(onChange: @escaping (URL) -> Void) {
        self.desktopURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
        self.onChange = onChange
    }

    func start() {
        let fd = open(desktopURL.path, O_EVTONLY)
        guard fd >= 0 else {
            print("ScreenshotWatcher: failed to open Desktop directory")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: .write,
            queue: .global(qos: .utility)
        )

        source.setEventHandler { [weak self] in
            self?.handleDesktopChange()
        }

        source.setCancelHandler {
            close(fd)
        }

        self.source = source
        source.resume()

        // Check for existing screenshots on launch
        handleDesktopChange()
    }

    func stop() {
        source?.cancel()
        source = nil
    }

    private func handleDesktopChange() {
        debounceWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.scanForLatestScreenshot()
        }
        debounceWork = work
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.3, execute: work)
    }

    private func scanForLatestScreenshot() {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(
            at: desktopURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else { return }

        let screenshots = contents.filter { url in
            let name = url.lastPathComponent
            let range = NSRange(name.startIndex..., in: name)
            return screenshotRegex.firstMatch(in: name, range: range) != nil
        }

        guard let newest = screenshots.max(by: { a, b in
            let dateA = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            let dateB = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            return dateA < dateB
        }) else { return }

        onChange(newest)
    }
}
