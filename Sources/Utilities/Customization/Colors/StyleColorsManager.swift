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

import SwiftUI

/// A structure that manages color styles for light and dark mode.
///
/// `StyleColorsManager` provides an interface for handling and switching
/// between color styles for different color schemes.
public struct StyleColorsManager {
    
    // MARK: - Properties
    
    /// The customizable color styles for light mode.
    public let light: StyleColors
    /// The customizable color styles for dark mode.
    public let dark: StyleColors
    
    // MARK: - Init
    
    /// Initializes a new instance of `StyleColorsManager` with the specified light and dark mode color styles.
    ///
    /// - Parameters:
    ///   - light: The customizable color styles for light mode.
    ///   - dark: The customizable color styles for dark mode.
    public init(light: StyleColors, dark: StyleColors) {
        self.light = light
        self.dark = dark
    }
    
    // MARK: - Methods

    func callAsFunction(for scheme: ColorScheme) -> StyleColors {
        scheme == .dark ? dark : light
    }
}

// MARK: - Previews

private struct TestViewPreview: View, Themed {
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    
    // MARK: - Builder
    
    var body: some View {
        HStack {
            Asset.check
                .foregroundStyle(colors.brand.onPrimary)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(colors.brand.primary)
                )
            
            Text("Message sent!")
                .foregroundStyle(colors.content.primary)
        }
        .padding(24)
        .background(colors.background.surface.container)
    }
}

#Preview("Light Mode") {
    TestViewPreview()
        .environmentObject(ChatStyle())
}

#Preview("Dark Mode") {
    TestViewPreview()
        .environmentObject(ChatStyle())
        .preferredColorScheme(.dark)
}
