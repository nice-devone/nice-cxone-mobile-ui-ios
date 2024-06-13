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

extension View {
    
    func messageChatStyle(_ message: ChatMessage, position: MessageGroupPosition, text: String? = nil) -> some View {
        modifier(ChatTextStyleModifier(message: message, text: text, position: position))
    }
}

// MARK: - ChatBubbleModifier

private struct ChatTextStyleModifier: ViewModifier {

    @EnvironmentObject private var style: ChatStyle
    
    private let customerCorners = UIRectCorner([.topLeft, .topRight, .bottomLeft])
    private let agentCorners = UIRectCorner([.topLeft, .topRight, .bottomRight])
    
    let message: ChatMessage
    let text: String?
    let position: MessageGroupPosition
    
    private var font: Font? {
        guard let text else {
            return nil
        }
        guard text.containsOnlyEmoji else {
            return .body
        }
        
        switch text.count {
        case 1:
            return .system(size: StyleGuide.Message.singleEmojiFontSize)
        case 2:
            return .system(size: StyleGuide.Message.twoEmojiesFontSize)
        case 3:
            return .system(size: StyleGuide.Message.threeEmojiesFontSize)
        default:
            return .body
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .background(background)
            .foregroundColor(message.user.isAgent ? style.agentFontColor : style.customerFontColor)
            .cornerRadius(topLeftCornerRadius, corners: .topLeft)
            .cornerRadius(topRightCornerRadius, corners: .topRight)
            .cornerRadius(bottomLeftCornerRadius, corners: .bottomLeft)
            .cornerRadius(bottomRightCornerRadius, corners: .bottomRight)
            
    }

    @ViewBuilder
    private var background: some View {
        if let text, text.containsOnlyEmoji {
            Color.clear
        } else {
            message.user.isAgent ? style.agentCellColor : style.customerCellColor
        }
    }
    
    // MARK: - Helpers
    
    private var topLeftCornerRadius: CGFloat {
        guard position != .single, message.user.isAgent else {
            return StyleGuide.Message.cornerRadius
        }
        
        return position == .first ? StyleGuide.Message.cornerRadius : StyleGuide.Message.cornerRadiusBetweenMessages
    }
    
    private var topRightCornerRadius: CGFloat {
        guard position != .single, !message.user.isAgent else {
            return StyleGuide.Message.cornerRadius
        }
        
        return position == .first ? StyleGuide.Message.cornerRadius : StyleGuide.Message.cornerRadiusBetweenMessages
    }
    
    private var bottomLeftCornerRadius: CGFloat {
        guard position != .single, message.user.isAgent else {
            return StyleGuide.Message.cornerRadius
        }
        
        return [.first, .inside].contains(position) ? StyleGuide.Message.cornerRadiusBetweenMessages : StyleGuide.Message.cornerRadius
    }
    
    private var bottomRightCornerRadius: CGFloat {
        guard position != .single, !message.user.isAgent else {
            return StyleGuide.Message.cornerRadius
        }
        
        return [.first, .inside].contains(position) ? StyleGuide.Message.cornerRadiusBetweenMessages : StyleGuide.Message.cornerRadius
    }
}
