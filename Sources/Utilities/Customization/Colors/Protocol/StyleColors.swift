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

/// Protocol defining the required color style groups for the chat UI.
///
/// Conforming types provide grouped color styles for background, content, brand, border, and status elements.
public protocol StyleColors {
    /// The background color style group.
    var background: BackgroundStyleColors { get }
    /// The content color style group.
    var content: ContentStyleColors { get }
    /// The brand color style group.
    var brand: BrandStyleColors { get }
    /// The border color style group.
    var border: BorderStyleColors { get }
    /// The status color style group.
    var status: StatusStyleColors { get }
}

// MARK: - Default Colors

/// Default implementation of `StyleColors` providing grouped color styles for the chat UI.
///
/// Use this struct to specify the main color style groups for light and dark themes.
public struct StyleColorsImpl: StyleColors {
    
    // MARK: - Properties
    
    /// The background color style group.
    public let background: BackgroundStyleColors
    /// The content color style group.
    public let content: ContentStyleColors
    /// The brand color style group.
    public let brand: BrandStyleColors
    /// The border color style group.
    public let border: BorderStyleColors
    /// The status color style group.
    public let status: StatusStyleColors

    // MARK: - Init
    
    /// Initializes a new instance with grouped color styles.
    /// - Parameters:
    ///   - background: The background color style group.
    ///   - content: The content color style group.
    ///   - brand: The brand color style group.
    ///   - border: The border color style group.
    ///   - status: The status color style group.
    public init(
        background: BackgroundStyleColors,
        content: ContentStyleColors,
        brand: BrandStyleColors,
        border: BorderStyleColors,
        status: StatusStyleColors
    ) {
        self.background = background
        self.content = content
        self.brand = brand
        self.border = border
        self.status = status
    }
    
    // MARK: - Default
    
    /// Default light theme grouped color styles.
    public static let defaultLight = StyleColorsImpl(
        background: BackgroundStyleColorsImpl.defaultLight,
        content: ContentStyleColorsImpl.defaultLight,
        brand: BrandStyleColorsImpl.defaultLight,
        border: BorderStyleColorsImpl.defaultLight,
        status: StatusStyleColorsImpl.defaultLight
    )
    /// Default dark theme grouped color styles.
    public static let defaultDark = StyleColorsImpl(
        background: BackgroundStyleColorsImpl.defaultDark,
        content: ContentStyleColorsImpl.defaultDark,
        brand: BrandStyleColorsImpl.defaultDark,
        border: BorderStyleColorsImpl.defaultDark,
        status: StatusStyleColorsImpl.defaultDark
    )
}
