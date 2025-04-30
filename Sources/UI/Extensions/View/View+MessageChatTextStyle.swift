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
            .foregroundColor(message.isUserAgent ? colors.customizable.agentText : colors.customizable.customerText)
            .tint(message.isUserAgent ? colors.customizable.agentText : colors.customizable.customerText)
            .cornerRadius(topLeftCornerRadius, corners: .topLeft)
            .cornerRadius(topRightCornerRadius, corners: .topRight)
            .cornerRadius(bottomLeftCornerRadius, corners: .bottomLeft)
            .cornerRadius(bottomRightCornerRadius, corners: .bottomRight)
    }
}

// MARK: - Helpers

private extension ChatTextStyleModifier {
    
    @ViewBuilder
    var background: some View {
        if text?.isLargeEmoji == true {
            Color.clear
        } else {
            message.isUserAgent ? colors.customizable.agentBackground : colors.customizable.customerBackground
        }
    }
    
    private static let cornerRadiusBetweenMessages: CGFloat = 4
    
    // MARK: - Helpers
    
    var topLeftCornerRadius: CGFloat {
        guard position != .single, message.isUserAgent else {
            return StyleGuide.Message.cornerRadius
        }
        
        return position == .first ? StyleGuide.Message.cornerRadius : Self.cornerRadiusBetweenMessages
    }
    
    var topRightCornerRadius: CGFloat {
        guard position != .single, !message.isUserAgent else {
            return StyleGuide.Message.cornerRadius
        }
        
        return position == .first ? StyleGuide.Message.cornerRadius : Self.cornerRadiusBetweenMessages
    }
    
    var bottomLeftCornerRadius: CGFloat {
        guard position != .single, message.isUserAgent else {
            return StyleGuide.Message.cornerRadius
        }
        
        return [.first, .inside].contains(position) ? Self.cornerRadiusBetweenMessages : StyleGuide.Message.cornerRadius
    }
    
    var bottomRightCornerRadius: CGFloat {
        guard position != .single, !message.isUserAgent else {
            return StyleGuide.Message.cornerRadius
        }
        
        return [.first, .inside].contains(position) ? Self.cornerRadiusBetweenMessages : StyleGuide.Message.cornerRadius
    }
}
