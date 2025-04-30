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

import Foundation

final class AttachmentLoader: ObservableObject {
    
    // MARK: - Properties

    @Published var data: Data?
    @Published var isLoading = false

    private let url: URL
    private let cacheKey: String

    // MARK: - Initializers

    init(url: URL, cacheKey: String? = nil) {
        self.url = url
        self.cacheKey = cacheKey ?? url.absoluteString
        load()
    }

    // MARK: - Methods

    func load() {
        if let cached = AttachmentCache.shared.data(for: cacheKey) {
            self.data = cached
            return
        }
        isLoading = true
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data else {
                return
            }
            
            AttachmentCache.shared.set(data, for: self.cacheKey)
            DispatchQueue.main.async {
                self.data = data
                self.isLoading = false
            }
        }.resume()
    }
}
