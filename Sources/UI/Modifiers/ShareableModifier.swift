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

struct ShareableModifier: ViewModifier, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let shareButtonStrokeWidth: CGFloat = 1
        }
        
        enum Spacing {
            static let contentHorizontal: CGFloat = 16
            static let shareButtonOffset: CGFloat = -1
        }
        
        enum Padding {
            static let icon: CGFloat = 8
        }
    }

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    let message: ChatMessage
    let attachments: [AttachmentItem]

    // MARK: - Builder

    func body(content: Content) -> some View {
        HStack(spacing: Constants.Spacing.contentHorizontal) {
            if !message.isUserAgent {
                Spacer(minLength: .zero)

                shareButton
            }

            content

            if message.isUserAgent {
                shareButton

                Spacer(minLength: .zero)
            }
        }
    }
}

// MARK: - Subviews

private extension ShareableModifier {

    var shareButton: some View {
        let attachmentDescription = attachments.count == 1
            ? attachments.first?.fileName ?? A11y.Conversation.MessageCell.Attachment.ButtonShare.fallback
            : A11y.Conversation.MessageCell.MultipleAttachments.ButtonShare.fallback
        
        return ShareLink(items: attachments.map(\.url)) {
            Asset.share
                .font(.subheadline.bold())
                .foregroundStyle(colors.brand.primary)
                .offset(y: Constants.Spacing.shareButtonOffset)
        }
        .padding(Constants.Padding.icon)
        .background(
            Circle()
                .strokeBorder(colors.border.default, lineWidth: Constants.Sizing.shareButtonStrokeWidth)
                .background(
                    Circle()
                        .fill(colors.background.surface.default)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.Attachment.ButtonShare.identifier)
        .accessibilityLabel(
            attachments.count == 1
                ? A11y.Conversation.MessageCell.Attachment.ButtonShare.label
                : A11y.Conversation.MessageCell.MultipleAttachments.ButtonShare.label
        )
        .accessibilityHint(
            attachments.count == 1
                ? A11y.Conversation.MessageCell.Attachment.ButtonShare.hint(attachmentDescription)
                : A11y.Conversation.MessageCell.MultipleAttachments.ButtonShare.hint(attachmentDescription)
        )
    }
}
