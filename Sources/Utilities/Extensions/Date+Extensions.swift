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

extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    static func from(year: Int, month: Int, day: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        guard
            (0...).contains(year),
            (1...12).contains(month),
            (1...31).contains(day),
            (0..<24).contains(hour ?? 0),
            (0..<60).contains(minute ?? 0),
            (0..<60).contains(second ?? 0)
        else {
            return Date.distantPast
        }
        
        let components = DateComponents(calendar: .current, timeZone: .current, year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        
        return Calendar.current.date(from: components).unsafelyUnwrapped
    }
    
    func formatted(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
    
    func adding(_ component: Calendar.Component, value: Int) -> Date {
        let calendar = Calendar.current
        
        return calendar.date(byAdding: component, value: value, to: self).unsafelyUnwrapped
    }
}
