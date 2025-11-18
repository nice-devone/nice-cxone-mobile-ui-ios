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

/// Protocol defining the required color properties for brand styles used in the chat UI.
///
/// Conforming types provide colors for primary and secondary brand colors, including their containers and on-colors.
public protocol BrandStyleColors {
    /// The primary brand color.
    var primary: Color { get }
    /// The color used for content on top of the primary color.
    var onPrimary: Color { get }
    /// The primary container color.
    var primaryContainer: Color { get }
    /// The color used for content on top of the primary container.
    var onPrimaryContainer: Color { get }
    /// The secondary brand color.
    var secondary: Color { get }
    /// The color used for content on top of the secondary color.
    var onSecondary: Color { get }
    /// The secondary container color.
    var secondaryContainer: Color { get }
    /// The color used for content on top of the secondary container.
    var onSecondaryContainer: Color { get }
}

// MARK: - Default Colors

/// Default implementation of `BrandStyleColors` providing concrete color values.
///
/// Use this struct to specify the main brand colors for light and dark themes.
public struct BrandStyleColorsImpl: BrandStyleColors {
    
    // MARK: - Properties
    
    /// The primary brand color.
    public let primary: Color
    /// The color used for content on top of the primary color.
    public let onPrimary: Color
    /// The primary container color.
    public let primaryContainer: Color
    /// The color used for content on top of the primary container.
    public let onPrimaryContainer: Color
    /// The secondary brand color.
    public let secondary: Color
    /// The color used for content on top of the secondary color.
    public let onSecondary: Color
    /// The secondary container color.
    public let secondaryContainer: Color
    /// The color used for content on top of the secondary container.
    public let onSecondaryContainer: Color

    // MARK: - Init
    
    /// Initializes a new instance with `Color` values.
    ///
    /// - Parameters:
    ///   - primary: The primary brand color.
    ///   - onPrimary: The color used for content on top of the primary color.
    ///   - primaryContainer: The primary container color.
    ///   - onPrimaryContainer: The color used for content on top of the primary container.
    ///   - secondary: The secondary brand color.
    ///   - onSecondary: The color used for content on top of the secondary color.
    ///   - secondaryContainer: The secondary container color.
    ///   - onSecondaryContainer: The color used for content on top of the secondary container.
    public init(
        primary: Color,
        onPrimary: Color,
        primaryContainer: Color,
        onPrimaryContainer: Color,
        secondary: Color,
        onSecondary: Color,
        secondaryContainer: Color,
        onSecondaryContainer: Color
    ) {
        self.primary = primary
        self.onPrimary = onPrimary
        self.primaryContainer = primaryContainer
        self.onPrimaryContainer = onPrimaryContainer
        self.secondary = secondary
        self.onSecondary = onSecondary
        self.secondaryContainer = secondaryContainer
        self.onSecondaryContainer = onSecondaryContainer
    }
    /// Initializes a new instance with `ColorAsset` values.
    /// 
    /// - Parameters:
    ///   - primary: The primary brand color asset.
    ///   - onPrimary: The color used for content on top of the primary color asset.
    ///   - primaryContainer: The primary container color asset.
    ///   - onPrimaryContainer: The color used for content on top of the primary container asset.
    ///   - secondary: The secondary brand color asset.
    ///   - onSecondary: The color used for content on top of the secondary color asset.
    ///   - secondaryContainer: The secondary container color asset.
    ///   - onSecondaryContainer: The color used for content on top of the secondary container asset.
    init(
        primary: ColorAsset,
        onPrimary: ColorAsset,
        primaryContainer: ColorAsset,
        onPrimaryContainer: ColorAsset,
        secondary: ColorAsset,
        onSecondary: ColorAsset,
        secondaryContainer: ColorAsset,
        onSecondaryContainer: ColorAsset
    ) {
        self.primary = primary.swiftUIColor
        self.onPrimary = onPrimary.swiftUIColor
        self.primaryContainer = primaryContainer.swiftUIColor
        self.onPrimaryContainer = onPrimaryContainer.swiftUIColor
        self.secondary = secondary.swiftUIColor
        self.onSecondary = onSecondary.swiftUIColor
        self.secondaryContainer = secondaryContainer.swiftUIColor
        self.onSecondaryContainer = onSecondaryContainer.swiftUIColor
    }

    // MARK: - Static Properties

    /// Default light theme brand colors.
    public static let defaultLight = BrandStyleColorsImpl(
        primary: Asset.Colors.Brand.Primary.base,
        onPrimary: Asset.Colors.Base.white,
        primaryContainer: Asset.Colors.Brand.Primary._200,
        onPrimaryContainer: Asset.Colors.Brand.Primary._700,
        secondary: Asset.Colors.Brand.Secondary.base,
        onSecondary: Asset.Colors.Base.black,
        secondaryContainer: Asset.Colors.Brand.Secondary._100,
        onSecondaryContainer: Asset.Colors.Brand.Secondary._900
    )

    /// Default dark theme brand colors.
    public static let defaultDark = BrandStyleColorsImpl(
        primary: Asset.Colors.Brand.Primary._300,
        onPrimary: Asset.Colors.Base.black,
        primaryContainer: Asset.Colors.Brand.Primary._700,
        onPrimaryContainer: Asset.Colors.Brand.Primary._200,
        secondary: Asset.Colors.Brand.Secondary._300,
        onSecondary: Asset.Colors.Base.black,
        secondaryContainer: Asset.Colors.Brand.Secondary._900,
        onSecondaryContainer: Asset.Colors.Brand.Secondary._100
    )
}
