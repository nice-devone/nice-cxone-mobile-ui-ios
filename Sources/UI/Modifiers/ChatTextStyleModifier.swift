//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import SwiftUI

struct ChatTextStyleModifier: ViewModifier, Themed, LayoutAware {

	// MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout
    
    let message: ChatMessage
    let text: String?
    let position: MessageGroupPosition
    let maxWidth: CGFloat?

    /// The caller's override, or the standard bubble cap for the current orientation.
    private var resolvedMaxWidth: CGFloat {
        maxWidth ?? messageMaxWidth
    }
    
    private var font: Font? {
        guard let text else {
            return nil
        }
        
        return text.isLargeEmoji ? .largeTitle : .callout
    }
    
    // MARK: - Init
    
    init(
        message: ChatMessage,
        text: String?,
        position: MessageGroupPosition,
        maxWidth: CGFloat?
    ) {
        self.message = message
        self.text = text
        self.position = position
        self.maxWidth = maxWidth
    }
    // MARK: - Builder
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(colors.bubbleForeground(isUserAgent: message.isUserAgent))
            .tint(colors.bubbleForeground(isUserAgent: message.isUserAgent))
            .background(
                position.clipShape(isUserAgent: message.isUserAgent)
                    .fill(backgroundColor)
            )
            .frame(maxWidth: resolvedMaxWidth, alignment: message.isUserAgent ? .leading : .trailing)
    }
}

// MARK: - Helpers

private extension ChatTextStyleModifier {
    
    var backgroundColor: Color {
        if text?.isLargeEmoji == true {
            Color.clear
        } else {
            colors.bubbleBackground(isUserAgent: message.isUserAgent)
        }
    }
}
