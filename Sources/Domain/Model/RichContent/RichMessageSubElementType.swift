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

/// Object representing the elements available for selection within the ``ListPickerItem`` or Menu message cell elements
///
/// This enum is designed for organizing and representing various sub-elements within rich messages,
/// which can include interactive buttons, text content, and file attachments.
/// The `postback` property allows easy access to the postback value for button elements,
/// making it convenient for handling user interactions in rich messages.
public enum RichMessageSubElementType: Hashable, Equatable {
    
    // MARK: - Cases
    
    /// Represents a button element within the rich message.
    case button(RichMessageButton)
    
    /// Represents a text element, which can be either regular text or a title, in the rich message.
    case text(String, isTitle: Bool)
    
    /// Represents a file attachment with a URL.
    case file(URL)
    
    // MARK: - Properties
    
    /// An optional property that extracts the postback value from a button sub-element, returning `nil` for other types.
    public var postback: String? {
        guard case .button(let entity) = self else {
            return nil
        }
        
        return entity.postback
    }
}
