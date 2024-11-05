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

/// A protocol that defines the color properties for a style.
public protocol StyleColors {
    /// The color properties for the foreground.
    var foreground: ForegroundStyleColors { get }
    /// The color properties for the background.
    var background: BackgroundStyleColors { get }
    /// The color properties for the accent
    var accent: AccentStyleColors { get }
    /// The color properties for the border
    var border: BorderStyleColors { get }
}

// MARK: - Default Colors

/// Default light colors for a style.
public struct StyleColorsImpl: StyleColors {
    
    // MARK: - Properties
    
    public var foreground: any ForegroundStyleColors
    public var background: any BackgroundStyleColors
    public var accent: any AccentStyleColors
    public var border: any BorderStyleColors
    
    // MARK: - Init
    
    /// Initializes the default light colors for a style.
    ///
    /// - Parameters:
    ///   - foreground: The foreground colors.
    ///   - background: The background colors.
    ///   - accent: The accent colors.
    ///   - border: The border colors.
    public init(
        foreground: ForegroundStyleColors,
        background: BackgroundStyleColors,
        accent: AccentStyleColors,
        border: BorderStyleColors
    ) {
        self.foreground = foreground
        self.background = background
        self.accent = accent
        self.border = border
    }
    
    // MARK: - Static Properties
    
    static let defaultLight = StyleColorsImpl(
        foreground: ForegroundStyleColorsImpl.defaultLight,
        background: BackgroundStyleColorsImpl.defaultLight,
        accent: AccentStyleColorsImpl.defaultLight,
        border: BorderStyleColorsImpl.defaultLight
    )
    
    static let defaultDark = StyleColorsImpl(
        foreground: ForegroundStyleColorsImpl.defaultDark,
        background: BackgroundStyleColorsImpl.defaultDark,
        accent: AccentStyleColorsImpl.defaultDark,
        border: BorderStyleColorsImpl.defaultDark
    )
}
