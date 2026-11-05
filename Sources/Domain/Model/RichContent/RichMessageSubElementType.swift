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

/// Object representing the elements available for selection within the ``ListPickerItem`` or Menu message cell elements
///
/// This enum is designed for organizing and representing various sub-elements within rich messages,
/// which can include interactive buttons and time slots.
/// The `postback` property allows easy access to the postback value for these elements,
/// making it convenient for handling user interactions in rich messages.
enum RichMessageSubElementType: Hashable, Equatable {
    
    // MARK: - Cases
    
    /// Represents a button element within the rich message.
    case button(RichMessageButton)
    
    case timeSlot(RichMessageTimeSlot)
    
    // MARK: - Properties
    
    /// The postback value of the sub-element: the button's postback, or the time slot's identifier.
    var postback: String? {
        switch self {
        case .button(let entity):
            return entity.postback
        case .timeSlot(let entity):
            return entity.id
        }
    }
}
