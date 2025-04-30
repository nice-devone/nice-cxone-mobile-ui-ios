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

protocol AccentStyleColors {
    
    var accent: Color { get }
    var onAccent: Color { get }
    var primary: Color { get }
    var muted: Color { get }
    var dim: Color { get }
    var bold: Color { get }
    var strong: Color { get }
    var pop: Color { get }
}

// MARK: - Default Colors

struct AccentStyleColorsImpl: AccentStyleColors {
    
    // MARK: - Properties
    
    let accent: Color
    let onAccent: Color
    let primary: Color
    let muted: Color
    let dim: Color
    let bold: Color
    let strong: Color
    let pop: Color
    
    // MARK: - Init
    
    init(
        onAccent: ColorAsset,
        primary: ColorAsset,
        muted: ColorAsset,
        dim: ColorAsset,
        accent: ColorAsset,
        bold: ColorAsset,
        strong: ColorAsset,
        pop: ColorAsset
    ) {
        self.accent = accent.swiftUIColor
        self.onAccent = onAccent.swiftUIColor
        self.primary = primary.swiftUIColor
        self.muted = muted.swiftUIColor
        self.dim = dim.swiftUIColor
        self.bold = bold.swiftUIColor
        self.strong = strong.swiftUIColor
        self.pop = pop.swiftUIColor
    }
    
    // MARK: - Static Properties
    
    static let defaultLight = AccentStyleColorsImpl(
        onAccent: Asset.Colors.white,
        primary: Asset.Colors.brand20,
        muted: Asset.Colors.brand30,
        dim: Asset.Colors.brand40,
        accent: Asset.Colors.brand60,
        bold: Asset.Colors.brand70,
        strong: Asset.Colors.brand80,
        pop: Asset.Colors.accentPop
    )
    
    static let defaultDark = AccentStyleColorsImpl(
        onAccent: Asset.Colors.white,
        primary: Asset.Colors.brand90,
        muted: Asset.Colors.brand80,
        dim: Asset.Colors.brand70,
        accent: Asset.Colors.brand60,
        bold: Asset.Colors.brand40,
        strong: Asset.Colors.brand30,
        pop: Asset.Colors.accentPop
    )
}
