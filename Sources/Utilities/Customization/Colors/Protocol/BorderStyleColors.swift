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

/// Protocol defining the required color properties for border styles used in the chat UI.
///
/// Conforming types provide colors for default and subtle border appearances.
public protocol BorderStyleColors {
    /// The default border color.
    var `default`: Color { get }
    /// The subtle border color.
    var subtle: Color { get }
}

// MARK: - Default Colors

/// Default implementation of `BorderStyleColors` providing concrete color values.
///
/// Use this struct to specify the main border colors for light and dark themes.
public struct BorderStyleColorsImpl: BorderStyleColors {
    
    // MARK: - Properties
    
    /// The default border color.
    public let `default`: Color
    /// The subtle border color.
    public let subtle: Color

    // MARK: - Init
    
    /// Initializes a new instance with `Color` values.
    ///
    /// - Parameters:
    ///   - default: The default border color.
    ///   - subtle: The subtle border color.
    public init(default: Color, subtle: Color) {
        self.default = `default`
        self.subtle = subtle
    }
    /// Initializes a new instance with `ColorAsset` values.
    /// 
    /// - Parameters:
    ///   - default: The default border color asset.
    ///   - subtle: The subtle border color asset.
    init(default: ColorAsset, subtle: ColorAsset) {
        self.default = `default`.swiftUIColor
        self.subtle = subtle.swiftUIColor
    }
    
    // MARK: - Static Properties

    /// Default light theme border colors.
    static let defaultLight = BorderStyleColorsImpl(
        default: Asset.Colors.Neutral._200,
        subtle: Asset.Colors.Neutral._100
    )
    
    /// Default dark theme border colors.
    static let defaultDark = BorderStyleColorsImpl(
        default: Asset.Colors.Neutral._800,
        subtle: Asset.Colors.Neutral._900
    )
}
