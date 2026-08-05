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

/// A time slot picker displays a list of options, and information about the time slot.
///
/// A model representing a time picker message, including the text shown in the conversation,
/// the sheet title, and the available time slots. Used to configure UI that presents time slot selection to the user.
public struct TimePickerItem: Hashable, Equatable, Sendable {
    
    // MARK: - Properties
    
    public let title: String
    
    public let sheetTitle: String
    
    public let timeSlots: [RichMessageTimeSlot]
}
