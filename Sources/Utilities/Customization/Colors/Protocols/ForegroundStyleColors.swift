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

protocol ForegroundStyleColors {
    
    var base: Color { get }
    var muted: Color { get }
    var subtle: Color { get }
    var accent: Color { get }
    var disabled: Color { get }
    var onContrast: Color { get }
    var staticDark: Color { get }
    var staticLight: Color { get }
    var error: Color { get }
}

// MARK: - Default Colors

struct ForegroundStyleColorsImpl: ForegroundStyleColors {
    
    // MARK: - Properties
    
    let base: Color
    let muted: Color
    let subtle: Color
    let accent: Color
    let disabled: Color
    let onContrast: Color
    let staticDark: Color
    let staticLight: Color
    let error: Color
    
    // MARK: - Init
    
    init(
        base: ColorAsset,
        muted: ColorAsset,
        subtle: ColorAsset,
        accent: ColorAsset,
        disabled: ColorAsset,
        onContrast: ColorAsset,
        staticDark: ColorAsset,
        staticLight: ColorAsset,
        error: ColorAsset
    ) {
        self.base = base.swiftUIColor
        self.muted = muted.swiftUIColor
        self.subtle = subtle.swiftUIColor
        self.accent = accent.swiftUIColor
        self.disabled = disabled.swiftUIColor
        self.onContrast = onContrast.swiftUIColor
        self.staticDark = staticDark.swiftUIColor
        self.staticLight = staticLight.swiftUIColor
        self.error = error.swiftUIColor
    }
    // MARK: - Static Properties

    static let defaultLight = ForegroundStyleColorsImpl(
        base: Asset.Colors.grey100,
        muted: Asset.Colors.grey60,
        subtle: Asset.Colors.grey50,
        accent: Asset.Colors.brand60,
        disabled: Asset.Colors.grey50,
        onContrast: Asset.Colors.white,
        staticDark: Asset.Colors.grey100,
        staticLight: Asset.Colors.white,
        error: Asset.Colors.red60
    )
    
    static let defaultDark = ForegroundStyleColorsImpl(
        base: Asset.Colors.white,
        muted: Asset.Colors.grey50,
        subtle: Asset.Colors.grey60,
        accent: Asset.Colors.brand60,
        disabled: Asset.Colors.grey60,
        onContrast: Asset.Colors.grey100,
        staticDark: Asset.Colors.grey100,
        staticLight: Asset.Colors.white,
        error: Asset.Colors.red40
    )
}
