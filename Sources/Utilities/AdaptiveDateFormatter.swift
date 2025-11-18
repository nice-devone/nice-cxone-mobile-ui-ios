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

/// A locale-aware formatter that produces human-friendly date strings based on a date's recency.
///
/// This formatter adapts its output to the user's current calendar and locale, returning
/// different representations depending on how far the given date is from "now":
/// - Today: localized time only (e.g., "14:35").
/// - Yesterday: a localized relative string (e.g., "Yesterday").
/// - Within the same week: localized weekday name (e.g., "Monday").
/// - Within the same year: localized day and month (e.g., "24 Feb").
/// - Different year: localized day, month, and year (e.g., "24 Feb 2024").
///
/// The instance uses `Calendar.current` and `Locale.autoupdatingCurrent` so results
/// automatically follow the user's region and locale changes at runtime.
final class AdaptiveDateFormatter {
    
    // MARK: - Properties
    
    private let calendar: Calendar
    private let dateFormatter = DateFormatter()

    // MARK: - Init
    
    init() {
        self.calendar = .current
        self.dateFormatter.locale = .autoupdatingCurrent
    }

    // MARK: - Methods
    
    /// Formats a `Date`, adapting to the user's locale.
    ///
    /// The output is fully localized and adapts to different regions
    ///
    /// - Parameter date: the date to format
    ///
    /// - Returns: A `String` representing the formatted date:
    ///   - If the date is **today**, returns the localized time (e.g., "14:35").
    ///   - If the date is **yesterday**, returns "Yesterday".
    ///   - If the date is **within the same week**, returns the localized weekday name (e.g., "Monday").
    ///   - If the date is **older than a week but within the same year**, returns a localized day and month (e.g., "24 Feb").
    ///   - If the date is **from a different year**, returns a localized day, month, and year (e.g., "24 Feb 2024").
    func string(from date: Date) -> String {
        let now = Date.now
        
        if calendar.isDateInToday(date) {
            // Same day → show time only - e.g., "15:54"
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            return dateFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            // Yesterday → show "Yesterday" instead of weekday name - "Yesterday"
            dateFormatter.doesRelativeDateFormatting = true
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            return dateFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            // Within the same week → show weekday name - e.g., "Monday"
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
            
            return dateFormatter.string(from: date)
        } else {
            let isSameYear = calendar.isDate(date, equalTo: now, toGranularity: .year)
            
            if isSameYear {
                // Same year → show day and month - e.g., "24 Feb" or "24. 2."
                dateFormatter.setLocalizedDateFormatFromTemplate("dMMM")
            } else {
                // Different year → show day, month, and year - e.g., "24 Feb 2024"
                dateFormatter.setLocalizedDateFormatFromTemplate("dMMM yyyy")
            }
            
            return dateFormatter.string(from: date)
        }
    }
}
