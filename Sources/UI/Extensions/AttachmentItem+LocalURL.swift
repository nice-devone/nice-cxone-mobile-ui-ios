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

extension AttachmentItem {

    // MARK: - Init

    /// Creates an item for a file stored locally, deriving its name and MIME type from the given URL.
    init(from url: URL, requiresSecurityScope: Bool = false, assetIdentifier: String? = nil) {
        self.init(
            url: url,
            friendlyName: url.lastPathComponent,
            mimeType: url.mimeType,
            fileName: url.lastPathComponent,
            requiresSecurityScope: requiresSecurityScope,
            assetIdentifier: assetIdentifier
        )
    }
}
