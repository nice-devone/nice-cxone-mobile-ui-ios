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

extension Date {
    
    func formatted(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func formatted(
        useRelativeFormat: Bool = false,
        timeZone: TimeZone = .current,
        timeStyle: DateFormatter.Style = .short,
        dateStyle: DateFormatter.Style = .medium
    ) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.doesRelativeDateFormatting = useRelativeFormat
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        
        return formatter.string(from: self)
    }
    
    func adding(_ component: Calendar.Component, value: Int) -> Date {
        let calendar = Calendar.current
        
        guard let date = calendar.date(byAdding: component, value: value, to: self) else {
            LogManager.error("Unable to add \(component) to \(self)")
            return self
        }
        
        return date
    }
}
