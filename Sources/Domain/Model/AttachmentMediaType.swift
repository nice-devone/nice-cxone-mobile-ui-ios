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

import UniformTypeIdentifiers

/// The media type of an attachment, derived from its MIME type.
///
/// The single place that classifies a MIME type, so the message mapper and the message input
/// attachment list can't disagree about how the same attachment is rendered.
enum AttachmentMediaType {

    // MARK: - Cases

    case image
    case video
    case audio
    case document

    // MARK: - Init

    init(mimeType: String) {
        let mimeType = mimeType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if mimeType.hasPrefix(UTType.imagePrefix) {
            self = .image
        } else if mimeType.hasPrefix(UTType.videoPrefix) {
            self = .video
        } else if mimeType.hasPrefix(UTType.audioPrefix) {
            self = .audio
        } else {
            self = .document
        }
    }
}
