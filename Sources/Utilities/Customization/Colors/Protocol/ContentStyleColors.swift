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

/// Protocol defining the required color properties for content styles used in the chat UI.
///
/// Conforming types provide colors for primary, secondary, tertiary, and inverse content.
public protocol ContentStyleColors {
    /// The primary content color.
    var primary: Color { get }
    /// The secondary content color.
    var secondary: Color { get }
    /// The tertiary content color.
    var tertiary: Color { get }
    /// The inverse content color (typically used for contrast).
    var inverse: Color { get }
}

// MARK: - Default Colors

/// Default implementation of `ContentStyleColors` providing concrete color values.
///
/// Use this struct to specify the main content colors for light and dark themes.
public struct ContentStyleColorsImpl: ContentStyleColors {
    
    // MARK: - Properties
    
    /// The primary content color.
    public let primary: Color
    /// The secondary content color.
    public let secondary: Color
    /// The tertiary content color.
    public let tertiary: Color
    /// The inverse content color.
    public let inverse: Color

    // MARK: - Init
    
    /// Initializes a new instance with SwiftUI `Color` values.
    ///
    /// - Parameters:
    ///   - primary: The primary content color.
    ///   - secondary: The secondary content color.
    ///   - tertiary: The tertiary content color.
    ///   - inverse: The inverse content color.
    public init(
        primary: Color,
        secondary: Color,
        tertiary: Color,
        inverse: Color
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
        self.inverse = inverse
    }
    /// Initializes a new instance with `ColorAsset` values.
    ///
    /// - Parameters:
    ///   - primary: The primary content color asset.
    ///   - secondary: The secondary content color asset.
    ///   - tertiary: The tertiary content color asset.
    ///   - inverse: The inverse content color asset.
    init(
        primary: ColorAsset,
        secondary: ColorAsset,
        tertiary: ColorAsset,
        inverse: ColorAsset
    ) {
        self.primary = primary.swiftUIColor
        self.secondary = secondary.swiftUIColor
        self.tertiary = tertiary.swiftUIColor
        self.inverse = inverse.swiftUIColor
    }

    // MARK: - Static Properties

    /// Default light theme content colors.
    public static let defaultLight = ContentStyleColorsImpl(
        primary: Asset.Colors.Base.black,
        secondary: Asset.Colors.Neutral._700,
        tertiary: Asset.Colors.Neutral._600,
        inverse: Asset.Colors.Base.white
    )
    /// Default dark theme content colors.
    public static let defaultDark = ContentStyleColorsImpl(
        primary: Asset.Colors.Base.white,
        secondary: Asset.Colors.Neutral._200,
        tertiary: Asset.Colors.Neutral._400,
        inverse: Asset.Colors.Base.black
    )
}
