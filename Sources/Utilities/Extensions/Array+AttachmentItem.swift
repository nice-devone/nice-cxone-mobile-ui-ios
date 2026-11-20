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

// MARK: - Methods

extension Array where Element == AttachmentItem {

    /// The staged image whose file holds exactly `data`, so a picked photo isn't staged twice.
    ///
    /// Only images that weren't picked from the Files app are compared: a picked photo is a freshly encoded JPEG, so a
    /// staged video or a file from Files never matches it, and reading those would cost a full read each time. A file
    /// from Files is also unreadable outside its security scope. Sizes are compared first, so a file is read only when
    /// it could match. An image that can't be read is logged and treated as a different file, so it can't make the
    /// whole selection fail.
    func firstImage(containing data: Data) -> AttachmentItem? {
        first { attachment in
            guard AttachmentMediaType(mimeType: attachment.mimeType) == .image, attachment.requiresSecurityScope == false else {
                return false
            }

            do {
                guard try attachment.url.resourceValues(forKeys: [.fileSizeKey]).fileSize == data.count else {
                    return false
                }

                return try Data(contentsOf: attachment.url) == data
            } catch {
                LogManager.warning("A staged image couldn't be read for the duplicate check: \(error.localizedDescription)")

                return false
            }
        }
    }
}
