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

/// Class that defines the visual style and appearance settings for a chat interface
///
/// This class is designed to define the visual style and appearance settings for a chat  interface,
/// allowing customization of colors, fonts, and logo elements to create a unique chat experience.
public class ChatStyle: ObservableObject {
    
    // MARK: - Properties
    
    /// An object that contains the color settings for light and dark modes.
    let colors: StyleColorsManager
    
    // MARK: - Init
    
    /// Initialization of the ChatStyle
    ///
    /// - Parameters:
    ///   - colors: ``StyleColorsManager`` object that contains the color settings for light and dark modes.
    public init(
        colorsManager: StyleColorsManager = StyleColorsManager(
            light: CustomizableStyleColorsImpl.defaultLight,
            dark: CustomizableStyleColorsImpl.defaultDark
        )
    ) {
        self.colors = colorsManager
    }
}
