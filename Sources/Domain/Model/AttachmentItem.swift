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

import Foundation

/// Representation of an attachment, typically a URL or resource, with associated metadata
///
/// This struct is designed for representing attachments or files with associated metadata,
/// making it suitable for various use cases, such as sharing files, resources, or documents.
/// The `url` points to the attachment, and the `mimeType` and `fileName` provide additional information about the attachment's content.
public struct AttachmentItem: Hashable, Equatable {

    // MARK: - Properties
    
    /// The URL pointing to the attachment.
    public let url: URL

    /// A user-friendly name or label for the attachment.
    public let friendlyName: String

    /// The MIME type of the attachment, specifying its content type.
    public let mimeType: String

    /// The file name of the attachment.
    public let fileName: String
    
    /// Indicates whether this attachment requires security-scoped resource access
    public let requiresSecurityScope: Bool
    
    /// The local identifier of the selected asset.
    public let assetIdentifier: String?
    
    // MARK: - Init
    
    /// Initialization of the AttachmentItem
    ///
    /// - Parameters:
    ///   - url: The URL pointing to the attachment.
    ///   - friendlyName: A user-friendly name or label for the attachment.
    ///   - mimeType: The MIME type of the attachment, specifying its content type.
    ///   - fileName: The file name of the attachment.
    ///   - assetIdentifier: The local identifier of the selected asset.
    public init(url: URL, friendlyName: String, mimeType: String, fileName: String, requiresSecurityScope: Bool = false, assetIdentifier: String? = nil) {
        self.url = url
        self.friendlyName = friendlyName
        self.mimeType = mimeType
        self.fileName = fileName
        self.requiresSecurityScope = requiresSecurityScope
        self.assetIdentifier = assetIdentifier
    }
}

// MARK: - Methods

extension AttachmentItem {
    
    private static var megabyte: Int32 = 1024 * 1024
    
    func isSizeValid(allowedFileSize: Int32) -> Bool {
        do {
            return try url.accessSecurelyScopedResource { url in
                let allowedFileSize = allowedFileSize * Self.megabyte
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)

                guard let fileSize = attributes[.size] as? Int32 else {
                    return false
                }

                return fileSize <= allowedFileSize
            }
        } catch {
            error.logError()
            
            return false
        }
    }
}
