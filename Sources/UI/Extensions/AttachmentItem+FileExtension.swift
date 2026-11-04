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

extension AttachmentItem {

    // MARK: - Properties

    /// The attachment's lowercased file extension.
    ///
    /// Resolved from the file name, then the URL, then the MIME type, counting only extensions the system
    /// recognises — so a dot in a display name (`Invoice 2024.10`) doesn't override a `application/pdf`
    /// MIME type. When nothing is recognised, the raw file name or URL extension is used (`dump.xyz`).
    var fileExtension: String? {
        let fileNameExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased().nilIfEmpty()
        let urlExtension = url.pathExtension.lowercased().nilIfEmpty()

        return Self.knownExtension(fileNameExtension)
            ?? Self.knownExtension(urlExtension)
            ?? UTType(mimeType: mimeType)?.preferredFilenameExtension?.lowercased().nilIfEmpty()
            ?? fileNameExtension
            ?? urlExtension
    }

    /// Whether the attachment is a PDF document.
    var isPDF: Bool {
        fileExtension == "pdf"
    }
}

// MARK: - Private methods

private extension AttachmentItem {

    static func knownExtension(_ pathExtension: String?) -> String? {
        guard let pathExtension, let fileType = UTType(filenameExtension: pathExtension), !fileType.isDynamic else {
            return nil
        }

        return pathExtension
    }
}
