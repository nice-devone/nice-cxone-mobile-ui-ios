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

/// Protocol defining the required color properties for surface backgrounds used in the chat UI.
///
/// Conforming types provide colors for default, variant, container, subtle, and emphasis backgrounds.
public protocol BackgroundSurfaceStyleColors {
    /// The default surface background color.
    var `default`: Color { get }
    /// The variant surface background color.
    var variant: Color { get }
    /// The container surface background color.
    var container: Color { get }
    /// The subtle surface background color.
    var subtle: Color { get }
    /// The emphasis surface background color.
    var emphasis: Color { get }
}

// MARK: - Default Colors

/// Default implementation of `BackgroundSurfaceStyleColors` providing concrete color values.
///
/// Use this struct to specify the main surface background colors for light and dark themes.
public struct BackgroundSurfaceStyleColorsImpl: BackgroundSurfaceStyleColors {
    
    // MARK: - Properties
    
    /// The default surface background color.
    public let `default`: Color
    /// The variant surface background color.
    public let variant: Color
    /// The container surface background color.
    public let container: Color
    /// The subtle surface background color.
    public let subtle: Color
    /// The emphasis surface background color.
    public let emphasis: Color

    // MARK: - Init
    
    /// Initializes a new instance with `Color` values.
    ///
    /// - Parameters:
    ///   - default: The default surface background color.
    ///   - variant: The variant surface background color.
    ///   - container: The container surface background color.
    ///   - subtle: The subtle surface background color.
    ///   - emphasis: The emphasis surface background color.
    public init(default: Color, variant: Color, container: Color, subtle: Color, emphasis: Color) {
        self.default = `default`
        self.variant = variant
        self.container = container
        self.subtle = subtle
        self.emphasis = emphasis
    }
    /// Initializes a new instance with `ColorAsset` values.
    /// 
    /// - Parameters:
    ///   - default: The default surface background color asset.
    ///   - variant: The variant surface background color asset.
    ///   - container: The container surface background color asset.
    ///   - subtle: The subtle surface background color asset.
    ///   - emphasis: The emphasis surface background color asset.
    init(`default`: ColorAsset, variant: ColorAsset, container: ColorAsset, subtle: ColorAsset, emphasis: ColorAsset) {
        self.default = `default`.swiftUIColor
        self.variant = variant.swiftUIColor
        self.container = container.swiftUIColor
        self.subtle = subtle.swiftUIColor
        self.emphasis = emphasis.swiftUIColor
    }

    // MARK: - Static Properties

    /// Default light theme surface background colors.
    public static let defaultLight = BackgroundSurfaceStyleColorsImpl(
        default: Asset.Colors.Neutral._100,
        variant: Asset.Colors.Neutral._200,
        container: Asset.Colors.Neutral._300,
        subtle: Asset.Colors.Neutral._50,
        emphasis: Asset.Colors.Brand.Primary._50
    )

    /// Default dark theme surface background colors.
    public static let defaultDark = BackgroundSurfaceStyleColorsImpl(
        default: Asset.Colors.Neutral._900,
        variant: Asset.Colors.Neutral._800,
        container: Asset.Colors.Neutral._700,
        subtle: Asset.Colors.Neutral._950,
        emphasis: Asset.Colors.Brand.Primary._900
    )
}
