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

/// A single selectable time slot used by ``MessageTimePicker``
///
/// It contains an identifier, duration, and the start date/time for the slot
public struct RichMessageTimeSlot: Hashable, Equatable, Sendable {

    // MARK: - Properties
    
    /// Unique identifier for the time slot.
    public let id: String

    /// Duration of the time slot, in seconds.
    public let duration: Int

    /// Start date and time of the slot.
    public let startTime: Date
    
    // MARK: - Computed Properties
    
    var durationInMinutes: Int {
        duration / 60
    }
    
    /// Returns a localized, human‑readable representation of the time slot.
    ///
    /// - Example: "January 3, 2026 at 3:00 PM,  30 min"
    ///
    /// - Returns: A formatted string combining the slot's start date/time and its duration in minutes.
    var formattedDescription: String {
        L10n.Chat.Message.TimePicker.formatted(
            self.startTime.formatted(date: .long, time: .shortened),
            self.durationInMinutes.description
        )
    }
}
