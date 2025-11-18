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

/// Protocol defining the required color properties for background styles used in the chat UI.
///
/// Conforming types provide colors for default, inverse, and surface backgrounds.
public protocol BackgroundStyleColors {
    /// The default background color.
    var `default`: Color { get }
    /// The inverse background color (typically used for contrast).
    var inverse: Color { get }
    /// The surface background color set, providing additional surface color options.
    var surface: BackgroundSurfaceStyleColors { get }
}

// MARK: - Default Colors

/// Default implementation of `BackgroundStyleColors` providing concrete color values.
///
/// Use this struct to specify the main background, inverse, and surface colors for light and dark themes.
public struct BackgroundStyleColorsImpl: BackgroundStyleColors {
    
    // MARK: - Properties
    
    /// The default background color.
    public let `default`: Color
    /// The inverse background color.
    public let inverse: Color
    /// The surface background color set.
    public let surface: BackgroundSurfaceStyleColors

    // MARK: - Init
    
    /// Initializes a new instance with SwiftUI `Color` values.
    ///
    /// - Parameters:
    ///   - default: The default background color.
    ///   - inverse: The inverse background color.
    ///   - surface: The surface background color set.
    public init(default: Color, inverse: Color, surface: BackgroundSurfaceStyleColors) {
        self.default = `default`
        self.inverse = inverse
        self.surface = surface
    }
    /// Initializes a new instance with `ColorAsset` values.
    /// 
    /// - Parameters:
    ///   - default: The default background color asset.
    ///   - inverse: The inverse background color asset.
    ///   - surface: The surface background color set.
    init(
        default: ColorAsset,
        inverse: ColorAsset,
        surface: BackgroundSurfaceStyleColors
    ) {
        self.default = `default`.swiftUIColor
        self.inverse = inverse.swiftUIColor
        self.surface = surface
    }

    // MARK: - Static Properties

    /// Default light theme colors.
    public static let defaultLight = BackgroundStyleColorsImpl(
        default: Asset.Colors.Base.white,
        inverse: Asset.Colors.Base.black,
        surface: BackgroundSurfaceStyleColorsImpl.defaultLight
    )
    /// Default dark theme colors.
    public static let defaultDark = BackgroundStyleColorsImpl(
        default: Asset.Colors.Base.black,
        inverse: Asset.Colors.Base.white,
        surface: BackgroundSurfaceStyleColorsImpl.defaultDark
    )
}
