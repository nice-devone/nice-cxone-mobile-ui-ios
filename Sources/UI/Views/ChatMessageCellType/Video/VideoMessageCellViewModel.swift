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
        
        Task { @MainActor [weak self] in
            await self?.cacheVideoFromURL()
        }
    }
    
    // MARK: - Functions

    func cacheVideoFromURL() async {
        LogManager.trace("Caching video locally")
        guard let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            LogManager.error(.failed("Unable to get Caches directory URL"))
            return
        }
        
        let fileURL = cacheDirectoryURL.appendingPathComponent(item.fileName)
        
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
            alertType = .genericError
            loadingState = .failed
        }
    }
}

// MARK: - Methods

private extension VideoMessageCellViewModel {

    func downloadVideo(url: URL, fileURL: URL) async throws -> URL {
        LogManager.trace("Downloading video")

        let (data, response) = try await URLSession.shared.data(from: url)

        // Check HTTP status code - URLSession.data doesn't throw for 4xx/5xx errors
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

        try data.write(to: fileURL, options: .atomic)
        
        return fileURL
    }
}
