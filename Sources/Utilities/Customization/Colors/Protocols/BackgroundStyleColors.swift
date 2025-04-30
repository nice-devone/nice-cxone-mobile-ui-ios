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

protocol BackgroundStyleColors {
    
    var canvas: Color { get }
    var subtle: Color { get }
    var muted: Color { get }
    var contrast: Color { get }
    var surface: Color { get }
    var interactivePrimary: Color { get }
    var interactiveSecondary: Color { get }
    var interactiveTertiary: Color { get }
    var successContrast: Color { get }
    var error: Color { get }
    var errorContrast: Color { get }
    var warning: Color { get }
    var disabled: Color { get }
    var dangerPrimary: Color { get }
    var dangerSecondary: Color { get }
    var dangerTertiary: Color { get }
}

// MARK: - Default Colors

struct BackgroundStyleColorsImpl: BackgroundStyleColors {
    
    // MARK: - Properties
    
    let canvas: Color
    let subtle: Color
    let muted: Color
    let contrast: Color
    let surface: Color
    let interactivePrimary: Color
    let interactiveSecondary: Color
    let interactiveTertiary: Color
    let successContrast: Color
    let error: Color
    let errorContrast: Color
    let warning: Color
    let disabled: Color
    let dangerPrimary: Color
    let dangerSecondary: Color
    let dangerTertiary: Color
    
    // MARK: - Init
    
    init(
        canvas: ColorAsset,
        subtle: ColorAsset,
        muted: ColorAsset,
        contrast: ColorAsset,
        surface: ColorAsset,
        interactivePrimary: ColorAsset,
        interactiveSecondary: ColorAsset,
        interactiveTertiary: ColorAsset,
        successContrast: ColorAsset,
        error: ColorAsset,
        errorContrast: ColorAsset,
        warning: ColorAsset,
        disabled: ColorAsset,
        dangerPrimary: ColorAsset,
        dangerSecondary: ColorAsset,
        dangerTertiary: ColorAsset
    ) {
        self.canvas = canvas.swiftUIColor
        self.subtle = subtle.swiftUIColor
        self.muted = muted.swiftUIColor
        self.contrast = contrast.swiftUIColor
        self.surface = surface.swiftUIColor
        self.interactivePrimary = interactivePrimary.swiftUIColor
        self.interactiveSecondary = interactiveSecondary.swiftUIColor
        self.interactiveTertiary = interactiveTertiary.swiftUIColor
        self.successContrast = successContrast.swiftUIColor
        self.error = error.swiftUIColor
        self.errorContrast = errorContrast.swiftUIColor
        self.warning = warning.swiftUIColor
        self.disabled = disabled.swiftUIColor
        self.dangerPrimary = dangerPrimary.swiftUIColor
        self.dangerSecondary = dangerSecondary.swiftUIColor
        self.dangerTertiary = dangerTertiary.swiftUIColor
    }
    
    // MARK: - Static Properties
    
    static let defaultLight = BackgroundStyleColorsImpl(
        canvas: Asset.Colors.white,
        subtle: Asset.Colors.grey10,
        muted: Asset.Colors.grey20,
        contrast: Asset.Colors.grey100,
        surface: Asset.Colors.white,
        interactivePrimary: Asset.Colors.grey20,
        interactiveSecondary: Asset.Colors.grey30,
        interactiveTertiary: Asset.Colors.grey40,
        successContrast: Asset.Colors.green60,
        error: Asset.Colors.red10,
        errorContrast: Asset.Colors.red60,
        warning: Asset.Colors.yellow10,
        disabled: Asset.Colors.grey30,
        dangerPrimary: Asset.Colors.red50,
        dangerSecondary: Asset.Colors.red60,
        dangerTertiary: Asset.Colors.red70
    )
    
    static let defaultDark = BackgroundStyleColorsImpl(
        canvas: Asset.Colors.grey100,
        subtle: Asset.Colors.grey90,
        muted: Asset.Colors.grey80,
        contrast: Asset.Colors.white,
        surface: Asset.Colors.grey80,
        interactivePrimary: Asset.Colors.grey80,
        interactiveSecondary: Asset.Colors.grey70,
        interactiveTertiary: Asset.Colors.grey60,
        successContrast: Asset.Colors.green50,
        error: Asset.Colors.red80,
        errorContrast: Asset.Colors.red50,
        warning: Asset.Colors.yellow80,
        disabled: Asset.Colors.grey80,
        dangerPrimary: Asset.Colors.red50,
        dangerSecondary: Asset.Colors.red60,
        dangerTertiary: Asset.Colors.red70
    )
}
