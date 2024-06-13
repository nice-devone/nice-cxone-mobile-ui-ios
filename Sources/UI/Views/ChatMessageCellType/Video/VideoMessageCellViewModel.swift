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

import SwiftUI

class VideoMessageCellViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var cachedVideoURL: URL?
    
    let item: AttachmentItem
    
    // MARK: - Init
    
    init(item: AttachmentItem) {
        self.item = item
        
        Task { @MainActor in
            await cacheVideoFromURL()
        }
    }
    
    // MARK: - Functions
    
    @MainActor
    func cacheVideoFromURL() async {
        LogManager.trace("Caching video locally")
        
        guard let docDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            LogManager.error(.failed("Unable to get Documents directory URL"))
            return
        }
        
        let fileURL = docDirectoryURL.appendingPathComponent(item.fileName)
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            await downloadVideo(url: item.url, fileURL: fileURL)
        } else {
            self.cachedVideoURL = fileURL
        }
    }
}

// MARK: - Methods

private extension VideoMessageCellViewModel {
    
    @MainActor
    func downloadVideo(url: URL, fileURL: URL) async {
        LogManager.trace("Downloading video")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            try data.write(to: fileURL, options: .atomic)
            
            cachedVideoURL = fileURL
        } catch {
            error.logError()
        }
    }
}
