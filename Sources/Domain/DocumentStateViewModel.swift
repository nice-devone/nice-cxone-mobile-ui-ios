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

import Foundation
import SwiftUI

@MainActor
final class DocumentStateViewModel: ObservableObject {

    // MARK: - Properties

    @Published var loadingState: AttachmentLoadingState<URL> = .initial
    @Published var isReadyToPresent = false

    /// Set by a user tap. The background pre-fetch started in `init` leaves this
    /// `false`, so it never auto-opens QuickLook; a tap that lands while that
    /// pre-fetch is still in flight flips it `true` so the download presents the
    /// preview on completion instead of being silently dropped.
    private var shouldPresentWhenReady = false

    /// The attachment's own filename, used as the on-disk cache key for both the read
    /// (`cachedFileURL`) and the write (`downloadAndSaveFile`) so the warm-cache lookup
    /// can't drift from where the file is actually saved. When `nil` (callers that only
    /// know the URL), it falls back to URL-derived names — same as before.
    private let cacheFileName: String?

    @Binding var alertType: ChatAlertType?

    // MARK: - Init

    init(alertType: Binding<ChatAlertType?>, url: URL? = nil, fileName: String? = nil) {
        self._alertType = alertType
        self.cacheFileName = fileName

        // If the document has already been downloaded to the caches directory, resolve
        // it synchronously so the cell shows its file-type icon on first render instead
        // of the loading spinner.
        if let url, let cachedURL = cachedFileURL(for: url) {
            loadingState = .loaded(cachedURL)
        } else if let url {
            // Not yet cached: pre-fetch in the background so the cell resolves to its
            // file-type icon instead of being stuck on the loading spinner until the
            // user taps it. Mirrors `ImageMessageCellViewModel` / `VideoMessageCellViewModel`,
            // which both auto-load on init when the asset isn't already on disk.
            //
            // `presentWhenReady: false` is essential here — this pre-fetch must NOT
            // auto-open the QuickLook sheet; only an explicit tap should present.
            Task { @MainActor [weak self] in
                await self?.downloadAndSaveFile(url: url, presentWhenReady: false)
            }
        }
    }

    // MARK: Methods

    /// Handles a user tap on the document cell.
    ///
    /// - `.loaded`: open the preview immediately.
    /// - `.loading`: a background pre-fetch is already in flight — record the intent
    ///   so it presents the preview when it finishes (without this, the tap would be
    ///   swallowed by `downloadAndSaveFile`'s guard and the user would have to tap twice).
    /// - `.initial` / `.failed`: record the present intent, then start (or retry) the
    ///   download. Setting `shouldPresentWhenReady` up front means that even if the
    ///   init pre-fetch wins the main-actor race and flips the state to `.loading`
    ///   before this tap's task runs, the pre-fetch still presents the preview on
    ///   completion instead of dropping the tap on `downloadAndSaveFile`'s guard.
    func handleTap(url: URL) {
        switch loadingState {
        case .loaded:
            isReadyToPresent = true
        case .loading:
            shouldPresentWhenReady = true
        case .initial, .failed:
            shouldPresentWhenReady = true
            Task { @MainActor [weak self] in
                await self?.downloadAndSaveFile(url: url)
            }
        }
    }

    /// Downloads the document to the caches directory and resolves `loadingState` to
    /// `.loaded`.
    ///
    /// - Parameters:
    ///   - url: Remote document URL to fetch.
    ///   - presentWhenReady: When `true` (the default, used by tap handlers), the
    ///     QuickLook preview sheet is opened as soon as the download completes. The
    ///     background pre-fetch in `init` passes `false` so it resolves the file-type
    ///     icon silently — unless a tap arrived mid-download and set
    ///     `shouldPresentWhenReady`, in which case it still presents.
    func downloadAndSaveFile(url: URL, presentWhenReady: Bool = true) async {
        guard loadingState.canStartLoading else {
            return
        }

        loadingState = .loading

        // Hoisted so the catch block cleans up the same path used by the success path.
        // Prefer the attachment's own filename so the write lands where `cachedFileURL`
        // looks for it; fall back to the URL's last path component.
        var originalFileName = resolvedFileName(for: url)

        // Read after the download completes: a tap during a background pre-fetch sets `shouldPresentWhenReady`.
        var isPresentationRequested: Bool {
            presentWhenReady || shouldPresentWhenReady
        }

        do {
            let (tempLocalUrl, response) = try await URLSession.shared.download(from: url)

            // Check HTTP status code - URLSession.download doesn't throw for 4xx/5xx errors
            if response.isHTTPFailure {
                throw URLError(.badServerResponse)
            }

            // Extract filename before detached task to avoid capturing non-Sendable response.
            // The attachment's own filename takes precedence so the saved file matches the
            // `cachedFileURL` key (and gives QuickLook a stable, meaningful title).
            originalFileName = resolvedFileName(for: url, suggestedFilename: (response as? HTTPURLResponse)?.suggestedFilename)

            let destinationURL = try await Task.detached(priority: .utility) { [originalFileName, url] in
                guard let destinationURL = url.attachmentCacheURL(fileName: originalFileName) else {
                    throw URLError(.cannotCreateFile)
                }

                // Ensure the per-URL subdirectory exists before moving the file into it.
                try FileManager.default.createDirectory(
                    at: destinationURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                try FileManager.default.moveItem(at: tempLocalUrl, to: destinationURL)

                return destinationURL
            }.value

            loadingState = .loaded(destinationURL)

            if isPresentationRequested {
                isReadyToPresent = true
            }
        } catch {
            error.logError()

            if let staleURL = url.attachmentCacheURL(fileName: originalFileName) {
                try? FileManager.default.removeItem(at: staleURL)
            }

            // Only surface the error alert when the user actually wanted the result
            // (an explicit tap), mirroring the presentation condition above. A silent
            // background pre-fetch must fail quietly — otherwise an offline / 4xx /
            // expired-link document would pop a modal alert over the whole conversation
            // with no user action behind it (and repeatedly for multi-document threads).
            // The cell still drops to `.failed`, so a later tap retries via `handleTap`.
            if isPresentationRequested {
                self.alertType = .genericError
            }

            self.loadingState = .failed
        }
    }
}

// MARK: - Helpers

private extension DocumentStateViewModel {

    /// The attachment's own filename, falling back to the server-suggested one and then to the URL's last path component.
    func resolvedFileName(for url: URL, suggestedFilename: String? = nil) -> String {
        cacheFileName ?? suggestedFilename ?? url.lastPathComponent
    }

    /// Returns the locally-cached document URL if it already exists on disk, at the
    /// per-URL location both this read and `downloadAndSaveFile`'s write resolve to.
    func cachedFileURL(for url: URL) -> URL? {
        guard let fileURL = url.attachmentCacheURL(fileName: resolvedFileName(for: url)) else {
            return nil
        }

        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}
