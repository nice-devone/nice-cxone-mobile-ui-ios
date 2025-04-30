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

import SwiftUI

class VideoMessageCellViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Binding var alertType: ChatAlertType?
    
    @Published var cachedVideoURL: URL?
    @Published var isLoading: Bool = false
    
    let item: AttachmentItem
    let localization: ChatLocalization
    
    // MARK: - Init
    
    init(item: AttachmentItem, alertType: Binding<ChatAlertType?>, localization: ChatLocalization) {
        self.item = item
        self._alertType = alertType
        self.localization = localization
        
        Task { @MainActor in
            await cacheVideoFromURL()
        }
    }
    
    // MARK: - Functions
    
    @MainActor
    func cacheVideoFromURL() async {
        LogManager.trace("Caching video locally")
        guard let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            LogManager.error(.failed("Unable to get Caches directory URL"))
            return
        }
        let fileURL = cacheDirectoryURL.appendingPathComponent(item.fileName)
        do {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                isLoading = true
                try await downloadVideo(url: item.url, fileURL: fileURL)
                isLoading = false
            } else {
                self.cachedVideoURL = fileURL
                isLoading = false
            }
        } catch {
            error.logError()
            alertType = .genericError(localization: localization)
            isLoading = false
        }
    }
}

// MARK: - Methods

private extension VideoMessageCellViewModel {
    
    @MainActor
    func downloadVideo(url: URL, fileURL: URL) async throws {
        LogManager.trace("Downloading video")
        
        let (data, _) = try await URLSession.shared.data(from: url)
        try data.write(to: fileURL, options: .atomic)
        
        cachedVideoURL = fileURL
    }
}
