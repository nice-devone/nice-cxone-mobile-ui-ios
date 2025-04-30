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

/// Object for a rich link message cell
///
/// This struct is designed for creating rich link previews, commonly used in apps and websites to give users a visual and textual preview of web content. 
/// The `url` and `imageUrl` properties enable you to provide a link and a thumbnail image for a more engaging user experience.
///
/// ## Example
/// ```
/// let item = RichLinkItem(
///     title: Lorem.words(),
///     url: videoUrl,
///     imageUrl: imageUrl
/// )
/// ```
public struct RichLinkItem: Hashable, Equatable {
    
    // MARK: - Properties
    
    /// The title or label associated with the rich link.
    public let title: String
    
    /// The URL pointing to the web page or content being previewed.
    public let url: URL
    
    /// The URL of an image used as a preview thumbnail for the link.
    public let imageUrl: URL
    
    // MARK: - Init
    
    /// Initialization of the RichLinkItem
    ///
    /// - Parameters:
    ///   - title: The title or label associated with the rich link.
    ///   - url: The URL pointing to the web page or content being previewed.
    ///   - imageUrl: The URL of an image used as a preview thumbnail for the link.
    public init(title: String, url: URL, imageUrl: URL) {
        self.title = title
        self.url = url
        self.imageUrl = imageUrl
    }
}
