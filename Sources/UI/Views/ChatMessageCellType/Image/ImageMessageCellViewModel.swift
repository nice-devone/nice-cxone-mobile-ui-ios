//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Kingfisher
import SwiftUI
import UIKit

class ImageMessageCellViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var image: KFCrossPlatformImage?
    
    @Binding var alertType: ChatAlertType?
    
    let item: AttachmentItem
    let localization: ChatLocalization
    
    private lazy var kingfisherManager = KingfisherManager(
        downloader: ImageDownloader(name: ChatView.packageIdentifier),
        cache: ImageCache(name: ChatView.packageIdentifier)
    )
    
    // MARK: - Init
    
    init(item: AttachmentItem, alertType: Binding<ChatAlertType?>, localization: ChatLocalization) {
        self.item = item
        self._alertType = alertType
        self.localization = localization
        
        Task {
            await loadImageFromURL()
        }
    }
    
    // MARK: - Functions
    
    func loadImageFromURL() async {
        let cacheKey = item.url.absoluteString
        
        if !kingfisherManager.cache.isCached(forKey: cacheKey) {
            await downloadImage(cacheKey: cacheKey)
        } else {
            await retrieveImage(cacheKey: cacheKey)
        }
    }
}

// MARK: - Private methods

private extension ImageMessageCellViewModel {
    
    func downloadImage(cacheKey: String) async {
        LogManager.trace("Downloading image from URL")
        do {
            // Explicitly use Kingfisher.ImageResource to avoid SwiftUI's ImageResource
            let resource = Kingfisher.KF.ImageResource(downloadURL: item.url, cacheKey: cacheKey)
            let result = try await kingfisherManager.retrieveImage(
                with: resource,
                options: [
                    .targetCache(kingfisherManager.cache)
                ]
            )
            await MainActor.run { [weak self] in
                self?.image = result.image
            }
        } catch {
            error.logError()
            await MainActor.run { [weak self] in
                guard let self else {
                    return
                }
                
                self.alertType = .genericError(localization: self.localization)
            }
        }
    }

    func retrieveImage(cacheKey: String) async {
        LogManager.trace("Retrieving image from cache")
        do {
            let result = try await kingfisherManager.cache.retrieveImage(forKey: cacheKey)
            await MainActor.run { [weak self] in
                guard let self else {
                    return
                }
                
                if let image = result.image {
                    self.image = image
                } else {
                    LogManager.error("Image not found in cache")
                    
                    self.alertType = .genericError(localization: self.localization)
                }
            }
        } catch {
            error.logError()
            await MainActor.run { [weak self] in
                guard let self else {
                    return
                }
                
                self.alertType = .genericError(localization: self.localization)
            }
        }
    }
}
