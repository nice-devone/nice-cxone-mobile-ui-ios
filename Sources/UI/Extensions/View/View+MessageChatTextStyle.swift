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

extension View {
    
    func messageChatStyle(_ message: ChatMessage, position: MessageGroupPosition, text: String? = nil) -> some View {
        modifier(ChatTextStyleModifier(message: message, text: text, position: position))
    }
}

// MARK: - ChatBubbleModifier

private struct ChatTextStyleModifier: ViewModifier, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let cornerRadiusBetweenMessages: CGFloat = 4
        }
    }
    
	// MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let message: ChatMessage
    let text: String?
    let position: MessageGroupPosition
    
    private var font: Font? {
        guard let text else {
            return nil
        }
        
        return text.isLargeEmoji ? .largeTitle : .callout
    }
    
    // MARK: - Builder
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .background(background)
            .foregroundColor(message.isUserAgent ? colors.content.primary : colors.brand.onPrimary)
            .tint(message.isUserAgent ? colors.content.primary : colors.brand.onPrimary)
            .cornerRadius(position.topLeftCornerRadius(isUserAgent: message.isUserAgent), corners: .topLeft)
            .cornerRadius(position.topRightCornerRadius(isUserAgent: message.isUserAgent), corners: .topRight)
            .cornerRadius(position.bottomLeftCornerRadius(isUserAgent: message.isUserAgent), corners: .bottomLeft)
            .cornerRadius(position.bottomRightCornerRadius(isUserAgent: message.isUserAgent), corners: .bottomRight)
    }
}

// MARK: - Helpers

private extension ChatTextStyleModifier {
    
    @ViewBuilder
    var background: some View {
        if text?.isLargeEmoji == true {
            Color.clear
        } else {
            message.isUserAgent ? colors.background.surface.default : colors.brand.primary
        }
    }
}
