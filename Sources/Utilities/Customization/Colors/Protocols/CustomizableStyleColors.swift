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

/// A protocol that defines the color properties to customize chat appereance.
public protocol CustomizableStyleColors {
    /// The primary color.
    var primary: Color { get }
    /// The color for elements on primary.
    var onPrimary: Color { get }
    /// The primary background color.
    var background: Color { get }
    /// The color for elements on background.
    var onBackground: Color { get }
    /// The accent color.
    var accent: Color { get }
    /// The color for elements on accent.
    var onAccent: Color { get }
    /// The color for agent's cell background.
    var agentBackground: Color { get }
    /// The color for an agent's cell text.
    var agentText: Color { get }
    /// The color for a customer's cell background.
    var customerBackground: Color { get }
    /// The color for a customer's cell text.
    var customerText: Color { get }
}

// MARK: - Default Colors

public struct CustomizableStyleColorsImpl: CustomizableStyleColors {
    
    // MARK: - Properties
    
    public let primary: Color
    public let onPrimary: Color
    public let background: Color
    public let onBackground: Color
    public let accent: Color
    public let onAccent: Color
    public let agentBackground: Color
    public let agentText: Color
    public let customerBackground: Color
    public let customerText: Color
    
    // MARK: - Init
    
    /// Initializes the default light colors for the customizable style.
    ///
    /// - Parameters:
    ///   - primary: The primary color.
    ///   - onPrimary: The color for elements on primary.
    ///   - background: The primary background color.
    ///   - onBackground: The color for elements on background.
    ///   - accent: The accent color.
    ///   - onAccent: The color for elements on accent.
    ///   - agentBackground: The color for agent's cell background.
    ///   - agentText: The color for an agent's cell text.
    ///   - customerBackground: The color for a customer's cell background.
    ///   - customerText: The color for a customer's cell text.
    public init(
        primary: Color,
        onPrimary: Color,
        background: Color,
        onBackground: Color,
        accent: Color,
        onAccent: Color,
        agentBackground: Color,
        agentText: Color,
        customerBackground: Color,
        customerText: Color
    ) {
        self.primary = primary
        self.onPrimary = onPrimary
        self.background = background
        self.onBackground = onBackground
        self.accent = accent
        self.onAccent = onAccent
        self.agentBackground = agentBackground
        self.agentText = agentText
        self.customerBackground = customerBackground
        self.customerText = customerText
    }
    
    init(
        primary: ColorAsset,
        onPrimary: ColorAsset,
        background: ColorAsset,
        onBackground: ColorAsset,
        accent: ColorAsset,
        onAccent: ColorAsset,
        agentBackground: ColorAsset,
        agentText: ColorAsset,
        customerBackground: ColorAsset,
        customerText: ColorAsset
    ) {
        self.primary = primary.swiftUIColor
        self.onPrimary = onPrimary.swiftUIColor
        self.background = background.swiftUIColor
        self.onBackground = onBackground.swiftUIColor
        self.accent = accent.swiftUIColor
        self.onAccent = onAccent.swiftUIColor
        self.agentBackground = agentBackground.swiftUIColor
        self.agentText = agentText.swiftUIColor
        self.customerBackground = customerBackground.swiftUIColor
        self.customerText = customerText.swiftUIColor
    }
    
    // MARK: - Static Properties
    
    public static let defaultLight = CustomizableStyleColorsImpl(
        primary: Asset.Colors.brand60,
        onPrimary: Asset.Colors.white,
        background: Asset.Colors.white,
        onBackground: Asset.Colors.grey100,
        accent: Asset.Colors.brand80,
        onAccent: Asset.Colors.white,
        agentBackground: Asset.Colors.grey20,
        agentText: Asset.Colors.grey100,
        customerBackground: Asset.Colors.brand60,
        customerText: Asset.Colors.white
    )
    
    public static let defaultDark = CustomizableStyleColorsImpl(
        primary: Asset.Colors.brand60,
        onPrimary: Asset.Colors.white,
        background: Asset.Colors.grey100,
        onBackground: Asset.Colors.white,
        accent: Asset.Colors.brand80,
        onAccent: Asset.Colors.white,
        agentBackground: Asset.Colors.grey80,
        agentText: Asset.Colors.white,
        customerBackground: Asset.Colors.brand60,
        customerText: Asset.Colors.white
    )
}
