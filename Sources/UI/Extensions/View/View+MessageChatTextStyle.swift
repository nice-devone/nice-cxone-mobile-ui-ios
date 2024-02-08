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

extension View {
    
    func messageChatTextStyle(_ message: ChatMessage, text: String, position: MessageGroupPosition) -> some View {
        modifier(ChatTextStyleModifier(message: message, text: text, position: position))
    }
}

// MARK: - ChatBubbleModifier

private struct ChatTextStyleModifier: ViewModifier {

    private let customerCorners = UIRectCorner([.topLeft, .topRight, .bottomLeft])
    private let agentCorners = UIRectCorner([.topLeft, .topRight, .bottomRight])
    
    @EnvironmentObject private var style: ChatStyle

    let message: ChatMessage
    let text: String
    let position: MessageGroupPosition
    
    private var font: Font? {
        guard text.containsOnlyEmoji else {
            return .body
        }
            
        switch text.count {
        case 1:
            return .system(size: 50)
        case 2:
            return .system(size: 38)
        case 3:
            return .system(size: 25)
        default:
            return .body
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
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
        if text.containsOnlyEmoji {
            Color.clear
        } else {
            message.user.isAgent ? style.agentCellColor : style.customerCellColor
        }
    }
    
    // MARK: - Helpers
    
    private var topLeftCornerRadius: CGFloat {
        guard position != .single, message.user.isAgent else {
            return 14
        }
        
        return position == .first ? 14 : 4
    }
    
    private var topRightCornerRadius: CGFloat {
        guard position != .single, !message.user.isAgent else {
            return 14
        }
        
        return position == .first ? 14 : 4
    }
    
    private var bottomLeftCornerRadius: CGFloat {
        guard position != .single, message.user.isAgent else {
            return 14
        }
        
        return [.first, .inside].contains(position) ? 4 : 14
    }
    
    private var bottomRightCornerRadius: CGFloat {
        guard position != .single, !message.user.isAgent else {
            return 14
        }
        
        return [.first, .inside].contains(position) ? 4 : 14
    }
}
