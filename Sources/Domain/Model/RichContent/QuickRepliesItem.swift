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

/// Object for a Quick Replies message cell
///
/// This struct is designed for creating quick reply items, which are commonly used to provide users with pre-defined response options,
/// making interactions in a chat context more efficient and user-friendly.
/// The `options` array allows you to specify the available choices, facilitating user engagement and interactions.
///
/// ## Example
/// ```
/// let item = QuickRepliesItem(
///     title: Lorem.word(),
///     message: Lorem.words(),
///     options: [
///         RichMessageButton(title: Lorem.words(nbWords: Int.random(in: 1..<3)), iconUrl: iconUrl)
///     ]
/// )
/// ```
struct QuickRepliesItem: Hashable, Equatable {
    
    /// The title or label associated with the quick replies item.
    let title: String
    
    /// An optional message or context providing additional information.
    let message: String?
    
    /// An array of `RichMessageButton` objects, representing the quick reply options.
    let options: [RichMessageButton]
}
