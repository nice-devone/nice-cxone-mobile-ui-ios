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

/// A protocol that defines the color properties for the borders.
public protocol BorderStyleColors {
    /// The subtle color.
    var subtle: Color { get }
    /// The muted color.
    var muted: Color { get }
    /// The contrast color.
    var contrast: Color { get }
    /// The disabled color.
    var disabled: Color { get }
    /// The error color.
    var error: Color { get }
}

// MARK: - Light Default Colors

public struct BorderStyleColorsImpl: BorderStyleColors {
    
    // MARK: - Properties
    
    public let subtle: Color
    public let muted: Color
    public let contrast: Color
    public let disabled: Color
    public let error: Color
    
    // MARK: - Init
    
    /// Initializes the default light colors for the borders.
    ///
    /// - Parameters:
    ///  - subtle: The subtle color.
    ///  - muted: The muted color.
    ///  - contrast: The contrast color.
    ///  - disabled: The disabled color.
    ///  - error: The error color.
    public init(subtle: Color, muted: Color, contrast: Color, disabled: Color, error: Color) {
        self.subtle = subtle
        self.muted = muted
        self.contrast = contrast
        self.disabled = disabled
        self.error = error
    }
    
    // MARK: - Static Properties
    
    static let defaultLight = BorderStyleColorsImpl(
        subtle: Asset.Colors.grey20.swiftUIColor,
        muted: Asset.Colors.grey30.swiftUIColor,
        contrast: Asset.Colors.grey100.swiftUIColor,
        disabled: Asset.Colors.grey40.swiftUIColor,
        error: Asset.Colors.red40.swiftUIColor
    )
    
    static let defaultDark = BorderStyleColorsImpl(
        subtle: Asset.Colors.grey80.swiftUIColor,
        muted: Asset.Colors.grey70.swiftUIColor,
        contrast: Asset.Colors.white.swiftUIColor,
        disabled: Asset.Colors.grey60.swiftUIColor,
        error: Asset.Colors.red70.swiftUIColor
    )
}
