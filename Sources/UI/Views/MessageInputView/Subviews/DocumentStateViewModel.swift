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

    @Binding var alertType: ChatAlertType?

    // MARK: - Init

    init(alertType: Binding<ChatAlertType?>) {
        self._alertType = alertType
    }

    // MARK: Methods

    func downloadAndSaveFile(url: URL) async {
        guard loadingState.isInitial || loadingState.isFailed else {
            return
        }

        loadingState = .loading

        // Hoisted so the catch block cleans up the same path used by the success path.
        var originalFileName = url.lastPathComponent

        do {
            let (tempLocalUrl, response) = try await URLSession.shared.download(from: url)

            // Check HTTP status code - URLSession.download doesn't throw for 4xx/5xx errors
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw URLError(.badServerResponse)
            }

            // Extract filename before detached task to avoid capturing non-Sendable response
            originalFileName = (response as? HTTPURLResponse)?.suggestedFilename ?? url.lastPathComponent

            let destinationURL = try await Task.detached(priority: .utility) { [originalFileName] in
                let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                let destinationURL = cachesPath.appendingPathComponent(originalFileName)

                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                try FileManager.default.moveItem(at: tempLocalUrl, to: destinationURL)

                return destinationURL
            }.value

            isReadyToPresent = true
            loadingState = .loaded(destinationURL)
        } catch {
            error.logError()

            let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            try? FileManager.default.removeItem(at: cachesPath.appendingPathComponent(originalFileName))

            self.alertType = .genericError
            self.loadingState = .failed
        }
    }
}
