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

    private lazy var kingfisherManager = KingfisherManager(
        downloader: ImageDownloader(name: ChatView.packageIdentifier),
        cache: ImageCache(name: ChatView.packageIdentifier)
    )
    
    // MARK: - Init

    init(item: AttachmentItem, alertType: Binding<ChatAlertType?>) {
        self.item = item
        self._alertType = alertType

        Task { [weak self] in
            await self?.loadImageFromURL()
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
        guard let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
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
