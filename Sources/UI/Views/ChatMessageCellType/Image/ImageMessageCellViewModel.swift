//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
    
    let item: AttachmentItem
    
    private lazy var kingfisherManager = KingfisherManager(
        downloader: ImageDownloader(name: ChatView.packageIdentifier),
        cache: ImageCache(name: ChatView.packageIdentifier)
    )
    
    // MARK: - Init
    
    init(item: AttachmentItem) {
        self.item = item
        
        loadImageFromURL()
    }
    
    // MARK: - Functions
    
    func loadImageFromURL() {
        if !kingfisherManager.cache.isCached(forKey: item.fileName) {
            downloadImage()
        } else {
            retrieveImage()
        }
    }
}

// MARK: - Private methods

private extension ImageMessageCellViewModel {
    
    func downloadImage() {
        kingfisherManager.downloader.downloadImage(with: item.url, options: .none) { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success(let value):
                kingfisherManager.cache.storeToDisk(value.originalData, forKey: self.item.fileName)

                self.image = value.image
            case .failure(let error):
                error.logError()
            }
        }
    }

    func retrieveImage() {
        kingfisherManager.cache.retrieveImage(forKey: item.fileName) { [weak self] result in
            switch result {
            case .success(let value):
                self?.image = value.image
            case .failure(let error):
                error.logError()
            }
        }
    }
}
