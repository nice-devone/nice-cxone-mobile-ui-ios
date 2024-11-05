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

/// A protocol defining a set of accent style colors.
public protocol AccentStyleColors {
    /// The primary accent color.
    var accent: Color { get }
    
    /// The color used for elements that are on top of the accent color.
    var onAccent: Color { get }
    
    /// The primary variant of the accent color.
    var primary: Color { get }
    
    /// A muted version of the accent color.
    var muted: Color { get }
    
    /// A dimmed version of the accent color.
    var dim: Color { get }
    
    /// A bold version of the accent color.
    var bold: Color { get }
    
    /// A strong variant of the accent color.
    var strong: Color { get }
    
    /// A pop variant of the accent color.
    var pop: Color { get }
}

// MARK: - Default Colors

/// Default colors for the accent.
public struct AccentStyleColorsImpl: AccentStyleColors {
    
    // MARK: - Properties
    
    public let accent: Color
    public let onAccent: Color
    public let primary: Color
    public let muted: Color
    public let dim: Color
    public let bold: Color
    public let strong: Color
    public let pop: Color
    
    // MARK: - Init
    
    /// Initializes the default light colors for the accent.
    ///
    /// - Parameters:
    ///  - accent: The primary accent color.
    ///  - onAccent: The color used for elements that are on top of the accent color.
    ///  - primary: The primary variant of the accent color.
    ///  - muted: A muted version of the accent color.
    ///  - dim: A dimmed version of the accent color.
    ///  - bold: A bold version of the accent color.
    ///  - strong: A strong variant of the accent color.
    ///  - pop: A pop variant of the accent color
    public init(
        accent: Color,
        onAccent: Color,
        primary: Color,
        muted: Color,
        dim: Color,
        bold: Color,
        strong: Color,
        pop: Color
    ) {
        self.accent = accent
        self.onAccent = onAccent
        self.primary = primary
        self.muted = muted
        self.dim = dim
        self.bold = bold
        self.strong = strong
        self.pop = pop
    }
    
    // MARK: - Static Properties
    
    static let defaultLight = AccentStyleColorsImpl(
        accent: Asset.Colors.brand60.swiftUIColor,
        onAccent: Asset.Colors.white.swiftUIColor,
        primary: Asset.Colors.brand20.swiftUIColor,
        muted: Asset.Colors.brand30.swiftUIColor,
        dim: Asset.Colors.brand40.swiftUIColor,
        bold: Asset.Colors.brand70.swiftUIColor,
        strong: Asset.Colors.brand80.swiftUIColor,
        pop: Asset.Colors.brand100.swiftUIColor
    )
    
    static let defaultDark = AccentStyleColorsImpl(
        accent: Asset.Colors.brand60.swiftUIColor,
        onAccent: Asset.Colors.white.swiftUIColor,
        primary: Asset.Colors.brand90.swiftUIColor,
        muted: Asset.Colors.brand80.swiftUIColor,
        dim: Asset.Colors.brand70.swiftUIColor,
        bold: Asset.Colors.brand40.swiftUIColor,
        strong: Asset.Colors.brand30.swiftUIColor,
        pop: Asset.Colors.accentPop.swiftUIColor
    )
}
