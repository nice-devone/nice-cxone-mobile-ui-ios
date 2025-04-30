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

/// A protocol that defines the color properties for the borders.
protocol BorderStyleColors {
    
    var subtle: Color { get }
    var muted: Color { get }
    var contrast: Color { get }
    var disabled: Color { get }
    var error: Color { get }
}

// MARK: - Default Colors

struct BorderStyleColorsImpl: BorderStyleColors {
    
    // MARK: - Properties
    
    let subtle: Color
    let muted: Color
    let contrast: Color
    let disabled: Color
    let error: Color
    
    // MARK: - Init
    
    init(subtle: ColorAsset, muted: ColorAsset, contrast: ColorAsset, disabled: ColorAsset, error: ColorAsset) {
        self.subtle = subtle.swiftUIColor
        self.muted = muted.swiftUIColor
        self.contrast = contrast.swiftUIColor
        self.disabled = disabled.swiftUIColor
        self.error = error.swiftUIColor
    }
    
    // MARK: - Static Properties
    
    static let defaultLight = BorderStyleColorsImpl(
        subtle: Asset.Colors.grey20,
        muted: Asset.Colors.grey30,
        contrast: Asset.Colors.grey100,
        disabled: Asset.Colors.grey40,
        error: Asset.Colors.red40
    )
    
    static let defaultDark = BorderStyleColorsImpl(
        subtle: Asset.Colors.grey80,
        muted: Asset.Colors.grey70,
        contrast: Asset.Colors.white,
        disabled: Asset.Colors.grey60,
        error: Asset.Colors.red70
    )
}
