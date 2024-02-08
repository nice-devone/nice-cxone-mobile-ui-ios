//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

/// Object for a custom plugin message cell
///
/// This struct is designed to encapsulate information within a message item, providing flexibility in passing data between different parts of a system.
/// The `variables` dictionary allows you to include a wide range of data, making it versatile for various use cases, 
/// such as plugins or data communication between components.
///
/// ## Example
/// ```
/// let item = CustomPluginMessageItem(
///     title: "Custom Plugin Message Title",
///     variables: [
///         "thumbnail": thumbnailUrl,
///         "url": url,
///         "buttons": [
///             [
///                 "id": "buttonId",
///                 "name": "Button Title"
///             ]
///         ],
///         "size": [
///             "ios": "big",
///             "android": "middle"
///         ]
///     ]
/// )
/// ```
public struct CustomPluginMessageItem {
    
    // MARK: - Properties
    
    /// An optional title or description associated with the message item.
    public let title: String?
    
    /// A dictionary containing key-value pairs, allowing for the inclusion of various data associated with the message.
    public let variables: [String: Any]
    
    // MARK: - Init
    
    /// Initialization of the CustomPluginMessageItem
    ///
    /// - Parameters:
    ///   - title: An optional title or description associated with the message item.
    ///   - variables: A dictionary containing key-value pairs, allowing for the inclusion of various data associated with the message.
    public init(title: String?, variables: [String: Any]) {
        self.title = title
        self.variables = variables
    }
}

// MARK: - Hashable

extension CustomPluginMessageItem: Hashable {
    
    public static func == (lhs: CustomPluginMessageItem, rhs: CustomPluginMessageItem) -> Bool {
        lhs.title == rhs.title && NSDictionary(dictionary: lhs.variables).isEqual(to: rhs.variables)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(variables.count)
        
        for (key, value) in variables {
            hasher.combine(key)
            hasher.combine("\(value)")
        }
    }
}
