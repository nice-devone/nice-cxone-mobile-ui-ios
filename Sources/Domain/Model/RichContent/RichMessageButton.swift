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

/// Object representing ``QuickRepliesItem``'s ``QuickRepliesItem/options``
///
/// This struct is designed for creating interactive buttons in rich messages, enabling user actions or navigation to URLs. 
/// The `iconUrl` property allows you to include an icon or image with the button.
/// The `postback` can be used for custom actions, making it versatile for various interactive scenarios.
///
/// ## Example
/// ```
/// let item = RichMessageButton(
///     title: Lorem.words(nbWords: Int.random(in: 1..<3)),
///     iconUrl: iconUrl
/// )
/// ```
public struct RichMessageButton: Hashable, Equatable {
    
    // MARK: - Properties
    
    /// An optional URL for an icon or image associated with the button.
    public let iconUrl: URL?
    
    /// The label or text displayed on the button.
    public let title: String
    
    /// An optional URL to navigate to when the button is clicked.
    public let url: URL?
    
    /// An optional custom string associated with the button's action.
    public let postback: String?
    
    // MARK: - Init
    
    /// Initialization of the RichMessageButton
    ///
    /// - Parameters:
    ///   - iconUrl: An optional URL for an icon or image associated with the button.
    ///   - title: The label or text displayed on the button.
    ///   - url: An optional URL to navigate to when the button is clicked.
    ///   - postback: An optional custom string associated with the button's action.
    public init(title: String, iconUrl: URL? = nil, url: URL? = nil, postback: String? = nil) {
        self.title = title
        self.iconUrl = iconUrl
        self.url = url
        self.postback = postback
    }
}
