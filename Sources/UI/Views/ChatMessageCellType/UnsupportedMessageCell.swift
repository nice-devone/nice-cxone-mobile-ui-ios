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

struct UnsupportedMessageCell: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let contentHorizontal: CGFloat = 0
            static let contentVertical: CGFloat = 8
        }
        
        enum Padding {
            static let cardVertical: CGFloat = 12
            static let cardHorizontal: CGFloat = 12
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    private let message: ChatMessage
    private let text: String
    private let position: MessageGroupPosition
    
    // MARK: - Init

    init(message: ChatMessage, text: String, position: MessageGroupPosition) {
        self.message = message
        self.text = text
        self.position = position
    }

    // MARK: - Builder

    var body: some View {
        HStack(spacing: Constants.Spacing.contentHorizontal) {
            VStack(alignment: .leading, spacing: Constants.Spacing.contentVertical) {
                messageCard
            }
            
            Spacer()
        }
    }
}

// MARK: - Subviews

private extension UnsupportedMessageCell {
    
    var messageCard: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.contentVertical) {
            Text(text)
                .font(.callout)
                .foregroundStyle(colors.content.primary)
            
            MessageCellTooltipView(
                text: localization.chatFallbackMessageUnknownTooltipText,
                tooltip: localization.chatFallbackMessageUnknownTooltipContent
            )
        }
        .padding(.vertical, Constants.Padding.cardVertical)
        .padding(.horizontal, Constants.Padding.cardHorizontal)
        .background(colors.background.surface.default)
        .cornerRadius(StyleGuide.Sizing.Message.cornerRadius, corners: .allCorners)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 2) {
        TextMessageCell(
            message: MockData.textMessage(user: MockData.customer),
            text: Lorem.sentence(),
            position: .first
        )

        TextMessageCell(
            message: MockData.hyperlinkMessage(user: MockData.customer),
            text: MockData.hyperlinkContent,
            position: .last
        )
        
        TextMessageCell(
            message: MockData.textMessage(user: MockData.agent),
            text: Lorem.sentence(),
            position: .single
        )
        .padding(.top, 12)
        
        TextMessageCell(
            message: MockData.phoneNumberMessage(user: MockData.customer),
            text: MockData.phoneNumberContent,
            position: .single
        )
        .padding(.top, 12)
        
        UnsupportedMessageCell(
            message: MockData.unsupportedMessage(),
            text: MockData.unsupportedMessageContent,
            position: .single
        )
        .padding(.top, 12)
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
