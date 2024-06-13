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

/// Representation of an attachment, typically a URL or resource, with associated metadata
///
/// This struct is designed for representing attachments or files with associated metadata,
/// making it suitable for various use cases, such as sharing files, resources, or documents.
/// The `url` points to the attachment, and the `mimeType` and `fileName` provide additional information about the attachment's content.
public struct AttachmentItem: Hashable {

    // MARK: - Properties
    
    /// The URL pointing to the attachment.
    public let url: URL

    /// A user-friendly name or label for the attachment.
    public let friendlyName: String

    /// The MIME type of the attachment, specifying its content type.
    public let mimeType: String

    /// The file name of the attachment.
    public let fileName: String
    
    // MARK: - Init
    
    /// Initialization of the AttachmentItem
    ///
    /// - Parameters:
    ///   - url: The URL pointing to the attachment.
    ///   - friendlyName: A user-friendly name or label for the attachment.
    ///   - mimeType: The MIME type of the attachment, specifying its content type.
    ///   - fileName: The file name of the attachment.
    public init(url: URL, friendlyName: String, mimeType: String, fileName: String) {
        self.url = url
        self.friendlyName = friendlyName
        self.mimeType = mimeType
        self.fileName = fileName
    }
}
