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

/// A protocol that defines the color properties for the background.
public protocol BackgroundStyleColors {
    /// The base color.
    var base: Color { get }
    
    /// The subtle color.
    var subtle: Color { get }
    
    /// The muted color.
    var muted: Color { get }
    
    /// The contrast color.
    var contrast: Color { get }
    
    /// The surface color.
    var surface: Color { get }
    
    /// The interactive primary color.
    var interactivePrimary: Color { get }
    
    /// The interactive secondary color.
    var interactiveSecondary: Color { get }
    
    /// The interactive tertiary color.
    var interactiveTertiary: Color { get }
    
    /// The success contrast color.
    var successContrast: Color { get }
    
    /// The error color.
    var error: Color { get }
    
    /// The error contrast color.
    var errorContrast: Color { get }
    
    /// The warning color.
    var warning: Color { get }
    
    /// The disabled color.
    var disabled: Color { get }
    
    /// The danger primary color.
    var dangerPrimary: Color { get }
    
    /// The danger secondary color.
    var dangerSecondary: Color { get }
    
    /// The danger tertiary color.
    var dangerTertiary: Color { get }
}

// MARK: - Default Colors

/// Default colors for the background.
public struct BackgroundStyleColorsImpl: BackgroundStyleColors {
    
    // MARK: - Properties
    
    public let base: Color
    public let subtle: Color
    public let muted: Color
    public let contrast: Color
    public let surface: Color
    public let interactivePrimary: Color
    public let interactiveSecondary: Color
    public let interactiveTertiary: Color
    public let successContrast: Color
    public let error: Color
    public let errorContrast: Color
    public let warning: Color
    public let disabled: Color
    public let dangerPrimary: Color
    public let dangerSecondary: Color
    public let dangerTertiary: Color
    
    // MARK: - Init
    
    /// Initializes the default light colors for the background.
    ///
    /// - Parameters:
    ///  - base: The base color.
    ///  - subtle: The subtle color.
    ///  - muted: The muted color.
    ///  - contrast: The contrast color.
    ///  - surface: The surface color.
    ///  - interactivePrimary: The interactive primary color.
    ///  - interactiveSecondary: The interactive secondary color.
    ///  - interactiveTertiary: The interactive tertiary color.
    ///  - successContrast: The success contrast color.
    ///  - error: The error color.
    ///  - errorContrast: The error contrast color.
    ///  - warning: The warning color.
    ///  - disabled: The disabled color.
    ///  - dangerPrimary: The danger primary color.
    ///  - dangerSecondary: The danger secondary color.
    ///  - dangerTertiary: The danger tertiary color.
    public init(
        base: Color,
        subtle: Color,
        muted: Color,
        contrast: Color,
        surface: Color,
        interactivePrimary: Color,
        interactiveSecondary: Color,
        interactiveTertiary: Color,
        successContrast: Color,
        error: Color,
        errorContrast: Color,
        warning: Color,
        disabled: Color,
        dangerPrimary: Color,
        dangerSecondary: Color,
        dangerTertiary: Color
    ) {
        self.base = base
        self.subtle = subtle
        self.muted = muted
        self.contrast = contrast
        self.surface = surface
        self.interactivePrimary = interactivePrimary
        self.interactiveSecondary = interactiveSecondary
        self.interactiveTertiary = interactiveTertiary
        self.successContrast = successContrast
        self.error = error
        self.errorContrast = errorContrast
        self.warning = warning
        self.disabled = disabled
        self.dangerPrimary = dangerPrimary
        self.dangerSecondary = dangerSecondary
        self.dangerTertiary = dangerTertiary
    }
    
    // MARK: - Static Properties
    
    static let defaultLight = BackgroundStyleColorsImpl(
        base: Asset.Colors.white.swiftUIColor,
        subtle: Asset.Colors.grey10.swiftUIColor,
        muted: Asset.Colors.grey20.swiftUIColor,
        contrast: Asset.Colors.grey100.swiftUIColor,
        surface: Asset.Colors.white.swiftUIColor,
        interactivePrimary: Asset.Colors.grey20.swiftUIColor,
        interactiveSecondary: Asset.Colors.grey30.swiftUIColor,
        interactiveTertiary: Asset.Colors.grey40.swiftUIColor,
        successContrast: Asset.Colors.green60.swiftUIColor,
        error: Asset.Colors.red10.swiftUIColor,
        errorContrast: Asset.Colors.red60.swiftUIColor,
        warning: Asset.Colors.yellow10.swiftUIColor,
        disabled: Asset.Colors.grey30.swiftUIColor,
        dangerPrimary: Asset.Colors.red50.swiftUIColor,
        dangerSecondary: Asset.Colors.red60.swiftUIColor,
        dangerTertiary: Asset.Colors.red70.swiftUIColor
    )
    
    static let defaultDark = BackgroundStyleColorsImpl(
        base: Asset.Colors.grey100.swiftUIColor,
        subtle: Asset.Colors.grey90.swiftUIColor,
        muted: Asset.Colors.grey80.swiftUIColor,
        contrast: Asset.Colors.white.swiftUIColor,
        surface: Asset.Colors.grey80.swiftUIColor,
        interactivePrimary: Asset.Colors.grey80.swiftUIColor,
        interactiveSecondary: Asset.Colors.grey70.swiftUIColor,
        interactiveTertiary: Asset.Colors.grey60.swiftUIColor,
        successContrast: Asset.Colors.green50.swiftUIColor,
        error: Asset.Colors.red80.swiftUIColor,
        errorContrast: Asset.Colors.red50.swiftUIColor,
        warning: Asset.Colors.yellow80.swiftUIColor,
        disabled: Asset.Colors.grey80.swiftUIColor,
        dangerPrimary: Asset.Colors.red50.swiftUIColor,
        dangerSecondary: Asset.Colors.red60.swiftUIColor,
        dangerTertiary: Asset.Colors.red70.swiftUIColor
    )
}
