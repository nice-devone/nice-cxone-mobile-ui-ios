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

/// Class that defines the visual style and appearance settings for a chat interface
///
/// This class is designed to define the visual style and appearance settings for a chat  interface,
/// allowing customization of colors, fonts, and logo elements to create a unique chat experience.
public class ChatStyle: ObservableObject {
    
    // MARK: - Properties
    
    /// The color of the navigation bar.
    let navigationBarColor: Color
    
    /// The color of navigation bar elements, such as titles and buttons.
    let navigationBarElementsColor: Color
    
    /// The background color of the chat interface.
    let backgroundColor: Color
    
    /// The background color for chat cells representing chat agents.
    let agentCellColor: Color
    
    /// The font color for chat cells representing chat agents.
    let agentFontColor: Color
    
    /// The background color for chat cells representing customers or users.
    let customerCellColor: Color
    
    /// The font color for chat cells representing customers or users.
    let customerFontColor: Color
    
    /// The text color for forms.
    let formTextColor: Color
    
    /// The text color for form error state.
    let formErrorColor: Color
    
    /// The button text color.
    let buttonTextColor: Color
    
    /// The button background color.
    let buttonBackgroundColor: Color
    
    /// An optional logo or image for the navigation bar.
    let navigationBarLogo: Image?
    
    // MARK: - Init
    
    /// Initialization of the ChatStyle
    ///
    /// - Parameters:
    ///   - navigationBarColor: The color of the navigation bar.
    ///   - navigationBarElementsColor: The color of navigation bar elements, such as titles and buttons.
    ///   - backgroundColor: The background color of the chat interface.
    ///   - agentCellColor: The background color for chat cells representing chat agents.
    ///   - agentFontColor: The font color for chat cells representing chat agents.
    ///   - customerCellColor: The background color for chat cells representing customers or users.
    ///   - customerFontColor: The font color for chat cells representing customers or users.
    ///   - navigationBarLogo: An optional logo or image for the navigation bar.
    public init(
        navigationBarColor: Color? = nil,
        navigationBarElementsColor: Color? = nil,
        backgroundColor: Color? = nil,
        agentCellColor: Color? = nil,
        agentFontColor: Color? = nil,
        customerCellColor: Color? = nil,
        customerFontColor: Color? = nil,
        formTextColor: Color? = nil,
        formErrorColor: Color? = nil,
        buttonTextColor: Color? = nil,
        buttonBackgroundColor: Color? = .accentColor,
        navigationBarLogo: Image? = nil
    ) {
        self.navigationBarColor = navigationBarColor ?? Color(.systemBackground)
        self.navigationBarElementsColor = navigationBarElementsColor ?? .black
        self.backgroundColor = backgroundColor ?? Color(.systemBackground)
        self.agentCellColor = agentCellColor ?? Color(.systemGray2)
        self.agentFontColor = agentFontColor ?? .black
        self.customerCellColor = customerCellColor ?? .accentColor
        self.customerFontColor = customerFontColor ?? .white
        self.formTextColor = formTextColor ?? .themedColor(light: Color.black, dark: Color.white)
        self.formErrorColor = formErrorColor ?? .red
        self.buttonTextColor = buttonTextColor ?? .white
        self.buttonBackgroundColor = buttonBackgroundColor ?? .accentColor
        self.navigationBarLogo = navigationBarLogo
    }
}
