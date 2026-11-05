//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import SwiftUI

@MainActor
final class VideoMessageCellViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Binding var alertType: ChatAlertType?
    
    @Published var loadingState: AttachmentLoadingState<URL> = .initial
    
    let item: AttachmentItem
    
    // MARK: - Init
    
    init(item: AttachmentItem, alertType: Binding<ChatAlertType?>) {
        self.item = item
        self._alertType = alertType

        // If the video is already cached on disk, resolve it synchronously so the
        // cell renders its thumbnail on first paint instead of flashing the loading
        // spinner for content that is already available. This is `fileExists`, a
        // single `stat()` syscall against local storage — not the disk read + decode
        // `ImageMessageCellViewModel` avoids doing synchronously (see its `init`); an
        // async detour here would only reintroduce the exact first-paint flicker this
        // check exists to prevent, for no measurable benefit.
        if let cachedURL = cachedVideoURL() {
            loadingState = .loaded(cachedURL)
        } else {
            // Not yet cached: pre-fetch in the background. `presentAlertOnFailure: false`
            // is essential here — this silent pre-fetch must NOT pop the full-screen error
            // alert over the whole conversation when the download fails (e.g. an expired
            // link on a video that was cached under the old path before an app update, or
            // an offline / 4xx response), and repeatedly for multi-video threads. The cell
            // still drops to `.failed`, so an explicit tap retries via `cacheVideoFromURL()`
            // — which does surface the alert. Mirrors `DocumentStateViewModel`.
            Task { @MainActor [weak self] in
                await self?.cacheVideoFromURL(presentAlertOnFailure: false)
            }
        }
    }

    // MARK: - Functions

    /// Downloads the video to the per-URL caches location and resolves `loadingState`.
    ///
    /// - Parameter presentAlertOnFailure: When `true` (the default, used by the tap-retry
    ///   button), a failed download pops the generic error alert. The background pre-fetch
    ///   in `init` passes `false` so it fails silently.
    func cacheVideoFromURL(presentAlertOnFailure: Bool = true) async {
        LogManager.trace("Caching video locally")
        guard let fileURL = item.url.attachmentCacheURL(fileName: item.fileName) else {
            LogManager.error(.failed("Unable to get Caches directory URL"))
            return
        }

        do {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                loadingState = .loading

                let url = try await downloadVideo(url: item.url, fileURL: fileURL)

                loadingState = .loaded(url)
            } else {
                loadingState = .loaded(fileURL)
            }
        } catch {
            error.logError()

            if presentAlertOnFailure {
                alertType = .genericError
            }

            loadingState = .failed
        }
    }
}

// MARK: - Methods

private extension VideoMessageCellViewModel {

    /// Returns the locally-cached video file URL if it already exists on disk, at the
    /// per-URL location `cacheVideoFromURL()` writes to.
    ///
    /// We deliberately do NOT read (or migrate) the legacy flat `caches/<fileName>` path a
    /// previous app version used: that path is keyed by friendly filename alone, so two
    /// attachments from different URLs that share a filename collide there. Trusting it
    /// could bind one video's bytes to a different attachment's URL and play the wrong
    /// video. A legacy-cached video therefore re-downloads once into its per-URL slot
    /// after an app update — the safe trade-off, since showing the wrong content is worse
    /// than re-fetching (and an expired link honestly resolves to `.failed`).
    func cachedVideoURL() -> URL? {
        guard let fileURL = item.url.attachmentCacheURL(fileName: item.fileName) else {
            return nil
        }

        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    func downloadVideo(url: URL, fileURL: URL) async throws -> URL {
        LogManager.trace("Downloading video")

        let (data, response) = try await URLSession.shared.data(from: url)

        // Check HTTP status code - URLSession.data doesn't throw for 4xx/5xx errors
        if response.isHTTPFailure {
            throw URLError(.badServerResponse)
        }

        // Offload the directory creation and full-file write to a background task so a
        // large video doesn't block the main actor and drop frames while scrolling —
        // mirroring the detached move in `DocumentStateViewModel`.
        return try await Task.detached(priority: .utility) {
            // Ensure the per-URL subdirectory exists before writing the file into it.
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            try data.write(to: fileURL, options: .atomic)

            return fileURL
        }.value
    }
}
