//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

struct PrimaryButtonStyle: ButtonStyle {
    
    // MARK: - Properties
    
    // Note: Apparently this can't be accessed via @EnvironmentObject on iOS 14,
    // so we have to pass it in from somewhere else that has it.
    private let chatStyle: ChatStyle

    // MARK: - Constructors

    init(chatStyle: ChatStyle) {
        self.chatStyle = chatStyle
    }
    
    // MARK: - Methods
    
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .adjustForA11y()
            .frame(maxWidth: .infinity)
            .foregroundColor(chatStyle.buttonTextColor)
            .background(configuration.isPressed ? chatStyle.buttonBackgroundColor.opacity(0.8) : chatStyle.buttonBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

struct PrimaryButtonStyle_Previews: PreviewProvider {
    
    static var previews: some View {
        Button("Button") { }
            .padding()
            .buttonStyle(PrimaryButtonStyle(chatStyle: ChatStyle()))
            .environmentObject(ChatStyle())
    }
}
