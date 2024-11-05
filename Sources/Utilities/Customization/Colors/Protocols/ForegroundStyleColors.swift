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

/// A protocol that defines the color properties for the foreground.
public protocol ForegroundStyleColors {
    /// The base color.
    var base: Color { get }
    /// The muted color.
    var muted: Color { get }
    /// The subtle color.
    var subtle: Color { get }
    /// The accent color.
    var accent: Color { get }
    /// The disabled color.
    var disabled: Color { get }
    /// The on contrast color.
    var onContrast: Color { get }
    /// The static dark color.
    var staticDark: Color { get }
    /// The static light color.
    var staticLight: Color { get }
    /// The error color.
    var error: Color { get }
}

// MARK: - Light Default Colors

/// Default colors for the foreground.
public struct ForegroundStyleColorsImpl: ForegroundStyleColors {
    
    // MARK: - Properties
    
    public let base: Color
    public let muted: Color
    public let subtle: Color
    public let accent: Color
    public let disabled: Color
    public let onContrast: Color
    public let staticDark: Color
    public let staticLight: Color
    public let error: Color
    
    // MARK: - Init
    
    /// Initializes the default light colors for the foreground.
    /// 
    /// - Parameters:
    ///  - base: The base color.
    ///  - muted: The muted color.
    ///  - subtle: The subtle color.
    ///  - accent: The accent color.
    ///  - disabled: The disabled color.
    ///  - onContrast: The on contrast color.
    ///  - staticDark: The static dark color.
    ///  - staticLight: The static light color.
    ///  - error: The error color.
    public init(
        base: Color, 
        muted: Color,
        subtle: Color,
        accent: Color,
        disabled: Color,
        onContrast: Color,
        staticDark: Color,
        staticLight: Color,
        error: Color
    ) {
        self.base = base
        self.muted = muted
        self.subtle = subtle
        self.accent = accent
        self.disabled = disabled
        self.onContrast = onContrast
        self.staticDark = staticDark
        self.staticLight = staticLight
        self.error = error
    }
    
    // MARK: - Static Properties

    static let defaultLight = ForegroundStyleColorsImpl(
        base: Asset.Colors.grey100.swiftUIColor,
        muted: Asset.Colors.grey60.swiftUIColor,
        subtle: Asset.Colors.grey50.swiftUIColor,
        accent: Asset.Colors.brand60.swiftUIColor,
        disabled: Asset.Colors.grey50.swiftUIColor,
        onContrast: Asset.Colors.white.swiftUIColor,
        staticDark: Asset.Colors.grey100.swiftUIColor,
        staticLight: Asset.Colors.white.swiftUIColor,
        error: Asset.Colors.red60.swiftUIColor
    )
    
    static let defaultDark = ForegroundStyleColorsImpl(
        base: Asset.Colors.white.swiftUIColor,
        muted: Asset.Colors.grey50.swiftUIColor,
        subtle: Asset.Colors.grey60.swiftUIColor,
        accent: Asset.Colors.brand60.swiftUIColor,
        disabled: Asset.Colors.grey60.swiftUIColor,
        onContrast: Asset.Colors.grey100.swiftUIColor,
        staticDark: Asset.Colors.grey100.swiftUIColor,
        staticLight: Asset.Colors.white.swiftUIColor,
        error: Asset.Colors.red40.swiftUIColor
    )
}
