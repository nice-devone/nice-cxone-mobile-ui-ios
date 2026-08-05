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

struct AttachmentFailedView: View, Themed {

    // MARK: - Constants

    private enum Constants {

        enum Padding {
            static let failureVertical: CGFloat = 10
        }
    }

    // MARK: - Properties

    let width: CGFloat
    let height: CGFloat

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    // MARK: Builder

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Asset.Attachment.placeholder
                .font(.title)
                .foregroundStyle(colors.content.secondary)

            Asset.Attachment.failed
                .foregroundStyle(colors.status.onError, colors.status.error)
        }
        .padding(.vertical, Constants.Padding.failureVertical)
        .padding(.horizontal, Constants.Padding.failureVertical)
        .frame(width: width, height: height)
        .background {
            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                .stroke(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                .background(
                    RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                        .fill(colors.background.default)
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.Attachment.Failed.identifier)
        .accessibilityLabel(A11y.Conversation.MessageCell.Attachment.Failed.label)
        .accessibilityHint(A11y.Conversation.MessageCell.Attachment.Failed.hint)
    }
}

// MARK: - Previews

#Preview("Small") {
    AttachmentFailedView(
        width: StyleGuide.Sizing.Attachment.smallDimension,
        height: StyleGuide.Sizing.Attachment.smallDimension
    )
    .environmentObject(ChatStyle())
}

#Preview("Regular") {
    AttachmentFailedView(
        width: StyleGuide.Sizing.Attachment.regularDimension,
        height: StyleGuide.Sizing.Attachment.regularDimension
    )
    .environmentObject(ChatStyle())
}

#Preview("Large") {
    AttachmentFailedView(
        width: StyleGuide.Sizing.Attachment.largeWidth,
        height: StyleGuide.Sizing.Attachment.largeHeight
    )
    .environmentObject(ChatStyle())
}
