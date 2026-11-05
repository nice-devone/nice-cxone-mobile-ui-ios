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
import Kingfisher

/// Feeds Kingfisher a local file that may be security-scoped — one picked from Files or iCloud Drive.
///
/// Kingfisher's own `LocalFileImageDataProvider`, which `KFImage(url)` uses for a file URL, reads the file
/// without starting its security scope. A file outside the app's sandbox then fails to load.
struct SecurityScopedImageDataProvider: ImageDataProvider {

    // MARK: - Properties

    let fileURL: URL

    /// Matches the key `MessageInputImageThumbnailView` looks up in Kingfisher's memory cache.
    var cacheKey: String {
        fileURL.absoluteString
    }

    var contentURL: URL? {
        fileURL
    }

    // MARK: - Methods

    /// The callback form, not `data() async throws`: only this one is a protocol requirement on every
    /// Kingfisher 8.x that `Package.swift` allows. Before 8.9 the async form is an internal helper, so a
    /// provider implementing only that one doesn't conform.
    func data(handler: @escaping @Sendable (Result<Data, any Error>) -> Void) {
        let fileURL = fileURL

        DispatchQueue.global(qos: .userInitiated).async {
            handler(
                Result {
                    try fileURL.accessSecurelyScopedResource { url in
                        try Data(contentsOf: url)
                    }
                }
            )
        }
    }
}
