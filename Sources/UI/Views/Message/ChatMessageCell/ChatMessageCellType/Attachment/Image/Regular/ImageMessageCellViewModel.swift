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

import Kingfisher
import SwiftUI
import UIKit

@MainActor
final class ImageMessageCellViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var loadingState: AttachmentLoadingState<KFCrossPlatformImage> = .initial

    @Binding var alertType: ChatAlertType?

    let item: AttachmentItem

    /// Shared cache + downloader for all image cells. A per-instance `ImageCache(name:)`
    /// would give every cell its own in-memory storage, so an image downloaded by one
    /// cell couldn't warm-paint a re-created cell (e.g. after scrolling) and the
    /// synchronous first-paint lookup would always miss. Sharing one instance means
    /// downloads populate a cache every cell reads from.
    ///
    /// The trade-off is process-long lifetime instead of per-cell lifetime, so the chat UI
    /// deliberately installs no teardown hook: Kingfisher's `ImageCache` registers its own
    /// observers on init — `didReceiveMemoryWarning` clears the memory cache,
    /// `didEnterBackground`/`willTerminate` clean the expired disk cache — on top of the
    /// memory-storage expiry sweep. Eviction is therefore already handled for long sessions
    /// with many image attachments; adding a manual `clearMemoryCache()` would only throw
    /// away the warm-paint benefit this cache exists for.
    ///
    /// Internal (not `private`) only so tests and `SnapshotAttachmentFixtures.seedImageCaches()`
    /// can seed a known image — it is not a configuration point for the UI module.
    static let imageCache = ImageCache(name: ChatView.packageIdentifier)
    private static let imageDownloader = ImageDownloader(name: ChatView.packageIdentifier)

    private lazy var kingfisherManager = KingfisherManager(
        downloader: Self.imageDownloader,
        cache: Self.imageCache
    )

    // MARK: - Init

    init(item: AttachmentItem, alertType: Binding<ChatAlertType?>) {
        self.item = item
        self._alertType = alertType

        // Resolve only a cheap in-memory cache hit synchronously so a warm image
        // paints on first render. This is a pure memory lookup (no disk I/O) — the
        // view models are constructed per-cell as the list scrolls, so a synchronous
        // disk read + decode on the main actor here would drop frames. The full disk
        // read stays on the async path in `loadImageFromURL()`.
        //
        // Read from the same named cache this view model's downloads populate, not
        // `ImageCache.default` — nothing writes `.default`, so that lookup never hit
        // in the app and the warm-paint optimization was dead.
        if let cachedImage = kingfisherManager.cache.retrieveImageInMemoryCache(forKey: item.url.absoluteString) {
            loadingState = .loaded(cachedImage)
        } else {
            Task { [weak self] in
                await self?.loadImageFromURL()
            }
        }
    }
    
    // MARK: - Functions
    
    func loadImageFromURL() async {
        if let localImage = loadCachedImage() {
            await MainActor.run { [weak self] in
                self?.loadingState = .loaded(localImage)
            }
            
            return
        }

        let cacheKey = item.url.absoluteString

        await MainActor.run {
            loadingState = .loading
        }

        if !kingfisherManager.cache.isCached(forKey: cacheKey) {
            await downloadImage(cacheKey: cacheKey)
        } else {
            await retrieveImage(cacheKey: cacheKey)
        }
    }
}

// MARK: - Private methods

private extension ImageMessageCellViewModel {
    
    func loadCachedImage() -> KFCrossPlatformImage? {
        guard let cacheDirectoryURL = FileManager.default.cachesDirectory else {
            return nil
        }

        let fileURL = cacheDirectoryURL.appendingPathComponent(item.fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = KFCrossPlatformImage(data: data) else {
            return nil
        }

        return image
    }

    func downloadImage(cacheKey: String) async {
        LogManager.trace("Downloading image from URL")

        do {
            // Explicitly use Kingfisher.ImageResource to avoid SwiftUI's ImageResource
            let resource = Kingfisher.KF.ImageResource(downloadURL: item.url, cacheKey: cacheKey)
            let result = try await kingfisherManager.retrieveImage(
                with: resource,
                options: [.targetCache(kingfisherManager.cache)]
            )

            loadingState = .loaded(result.image)
        } catch {
            error.logError()

            alertType = .genericError
            self.loadingState = .failed
        }
    }

    func retrieveImage(cacheKey: String) async {
        LogManager.trace("Retrieving image from cache")

        do {
            let result = try await kingfisherManager.cache.retrieveImage(forKey: cacheKey)

            if let image = result.image {
                loadingState = .loaded(image)
            } else {
                LogManager.error("Image not found in cache")

                alertType = .genericError
                loadingState = .failed
            }
        } catch {
            error.logError()

            alertType = .genericError
            loadingState = .failed
        }
    }
}
