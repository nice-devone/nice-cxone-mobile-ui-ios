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

import SwiftUI

extension Color {
    
    // MARK: - Init
    
    init(hex: String) {
        let regex = try? NSRegularExpression(pattern: "^#?[0-9A-Fa-f]*$")
        
        guard let regex, !regex.matches(in: hex, range: NSRange(hex.startIndex..., in: hex)).isEmpty else {
            Log.error(.failed("Unable to initialize color with hex \(hex). Regex pattern does not match"))
            self = .clear
            return
        }
        
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        guard [3, 4, 6, 8].contains(hex.count) else {
            Log.error(.failed("Unable to initialize color with hex \(hex). Hex count does not match expected values"))
            self = .clear
            return
        }
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 4:
            (alpha, red, green, blue) = (255, (int >> 12) * 17, (int >> 8 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 1)
        }
        
        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: Double(alpha) / 255)
    }
    
    // MARK: - Static methods
    
    static func themedColor(light: Color, dark: Color) -> Color {
        UIApplication.isDarkModeActive ? dark : light
    }
}

// MARK: - Properties

private extension UIApplication {
    
    static var isDarkModeActive: Bool {
        UITraitCollection.current.userInterfaceStyle == .dark
    }
}
