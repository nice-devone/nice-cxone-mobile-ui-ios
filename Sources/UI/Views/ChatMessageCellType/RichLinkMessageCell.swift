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

import Kingfisher
import SwiftUI

struct RichLinkMessageCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        @MainActor
        enum Spacing {
            static let gapMinLength: CGFloat = UIScreen.currentBounds.width / 3
            static let linkHorizontal: CGFloat = 2
            static let buttonContentVertical: CGFloat = 8
            static let titleAndHostVertical: CGFloat = 6
        }
        
        enum Padding {
            static let buttonContentHorizontal: CGFloat = 12
            static let buttonContentBottom: CGFloat = 12
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.openURL) private var openURL

    @State private var isShareSheetVisible = false
    @State private var imageAccessibilityLabel: String?

    let message: ChatMessage
    let item: RichLinkItem

    // MARK: - Builder

    var body: some View {
        HStack {
            Button {
                openURL(item.url)
            } label: {
                buttonContent
            }
            .background(colors.background.surface.default)
            .cornerRadius(StyleGuide.Sizing.Message.cornerRadius, corners: .allCorners)
            .contextMenu {
                contextMenuContent
            }
            .accessibilityHint(A11y.Conversation.MessageCell.RichLink.hint)

            Spacer(minLength: Constants.Spacing.gapMinLength)
        }
        .sheet(isPresented: $isShareSheetVisible) {
            ShareSheet(activityItems: [item.url])
        }
    }
}

// MARK: - Subviews

private extension RichLinkMessageCell {

    var buttonContent: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.buttonContentVertical) {
            KFImage(item.imageUrl)
                .placeholder {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .onSuccess { result in
                    self.imageAccessibilityLabel = result.image.accessibilityLabel
                }
                .resizable()
                .scaledToFill()
                .frame(maxHeight: StyleGuide.Sizing.Attachment.regularDimension)
                .clipped()
                .ifLet(imageAccessibilityLabel) { view, a11yLabel in
                    view.accessibilityLabel(a11yLabel)
                } else: { view in
                    view.accessibilityHidden(true)
                }

            VStack(alignment: .leading, spacing: Constants.Spacing.titleAndHostVertical) {
                Text(item.title)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(colors.content.primary)
                    .accessibilityIdentifier(A11y.Conversation.MessageCell.RichLink.Title.identifier)

                if let host = item.url.host {
                    HStack(spacing: Constants.Spacing.linkHorizontal) {
                        Text(host)

                        Asset.Message.RichContent.link
                    }
                    .font(.caption2)
                    .foregroundStyle(colors.brand.primary)
                    .accessibilityElement(children: .ignore)
                    .accessibilityIdentifier(A11y.Conversation.MessageCell.RichLink.Host.identifier)
                    .accessibilityLabel(host)
                }
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, Constants.Padding.buttonContentHorizontal)
        }
        .padding(.bottom, Constants.Padding.buttonContentBottom)
    }

    @ViewBuilder
    var contextMenuContent: some View {
        Button {
            isShareSheetVisible = true
        } label: {
            Text(L10n.Common.share)

            Asset.share
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.RichLink.ContextMenu.ButtonShare.identifier)
        .accessibilityLabel(L10n.Common.share)
        .accessibilityValue(item.url.absoluteString)
        .accessibilityHint(A11y.Conversation.MessageCell.RichLink.ContextMenu.ButtonShare.hint)

        Button {
            UIPasteboard.general.url = item.url
            UIPasteboard.general.string = item.url.absoluteString
        } label: {
            Text(L10n.Common.copy)

            Asset.copy
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.RichLink.ContextMenu.ButtonCopy.identifier)
        .accessibilityLabel(L10n.Common.copy)
        .accessibilityValue(item.url.absoluteString)
        .accessibilityHint(A11y.Conversation.MessageCell.RichLink.ContextMenu.ButtonCopy.hint)
    }
}

// MARK: - Preview

#Preview {
    RichLinkMessageCell(message: MockData.richLinkMessage(), item: MockData.richLinkItem())
        .environmentObject(ChatStyle())
}
