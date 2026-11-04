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

struct ImageMessageCell: View, Themed, LayoutAware {

    // MARK: - Constants

    private enum Constants {
        static let accessibilityIdentifier = "image"
    }

    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    @Environment(\.presentAttachmentPreview) private var presentAttachmentPreview

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `StyleGuide.Sizing.Attachment` directly, so a rotation invalidates this view and the size is
    /// resolved again.
    private var thumbnailSize: CGSize {
        attachmentSize(for: .regular)
    }
    
    @StateObject private var viewModel: ImageMessageCellViewModel

    private let message: ChatMessage
    /// `nil` if the message is part of the `MultipleAttachmentsContainer` view.
    private let position: MessageGroupPosition?

    // MARK: - Init
    
    init(
        message: ChatMessage,
        item: AttachmentItem,
        position: MessageGroupPosition? = nil,
        alertType: Binding<ChatAlertType?>
    ) {
        self.message = message
        self.position = position

        _viewModel = StateObject(wrappedValue: ImageMessageCellViewModel(item: item, alertType: alertType))
    }
    
    // MARK: - Builder
    
    var body: some View {
        content
            .if(position != nil) { view in
                view
                    .shareable(message, attachments: [viewModel.item])
            }
    }
}

// MARK: - Subviews

private extension ImageMessageCell {

    @ViewBuilder
    var content: some View {
        // Computed once and shared by all three loading states so the failed/loading
        // placeholders line up with the same message-group corner as the loaded image.
        let clipShape = position.attachmentClipShape(isUserAgent: message.isUserAgent)

        switch viewModel.loadingState {
        case .loaded(let image):
            Button {
                presentAttachmentPreview(.image(image, name: viewModel.item.friendlyName))
            } label: {
                let image = Image(uiImage: image)

                image
                    .resizable()
                    .scaledToFill()
            }
            .frame(
                width: thumbnailSize.width,
                height: thumbnailSize.height
            )
            .clippedHitArea(clipShape)
            .overlay {
                clipShape
                    .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(A11y.Conversation.MessageCell.Attachment.identifier(type: Constants.accessibilityIdentifier))
            .accessibilityLabel(A11y.Conversation.MessageCell.Attachment.Image.label(viewModel.item.fileName))
            .accessibilityHint(A11y.Conversation.MessageCell.Attachment.Image.hint)
        case .failed:
            Button {
                Task { @MainActor in
                    await viewModel.loadImageFromURL()
                }
            } label: {
                AttachmentFailedView(size: thumbnailSize, clipShape: clipShape, drawsBorder: true)
            }
        default:
            AttachmentLoadingView(size: thumbnailSize, clipShape: clipShape, drawsBorder: true)
        }
    }
}

// MARK: - Preview

#Preview("Single") {
    NavigationStack {
        ScrollView {
            VStack {
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.agent),
                    item: MockData.imageItem(),
                    position: .single,
                    alertType: .constant(nil)
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.customer),
                    item: MockData.imageItem(),
                    position: .single,
                    alertType: .constant(nil)
                )
                
                VStack(spacing: 4) {
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.agent),
                        item: MockData.imageItem(),
                        position: .first,
                        alertType: .constant(nil)
                    )
                    
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.agent),
                        item: MockData.imageItem(),
                        position: .inside,
                        alertType: .constant(nil)
                    )
                    
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.agent),
                        item: MockData.imageItem(),
                        position: .last,
                        alertType: .constant(nil)
                    )
                }
                
                VStack(spacing: 4) {
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.customer),
                        item: MockData.imageItem(),
                        position: .first,
                        alertType: .constant(nil)
                    )
                    
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.customer),
                        item: MockData.imageItem(),
                        position: .inside,
                        alertType: .constant(nil)
                    )
                    
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.customer),
                        item: MockData.imageItem(),
                        position: .last,
                        alertType: .constant(nil)
                    )
                }
            }
        }
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
}

@available(iOS 17, *)
#Preview("Multiple") {
    @Previewable @Environment(\.colorScheme) var scheme

    let style = ChatStyle()

    NavigationStack {
        VStack {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ImageMessageCell(
                        message: MockData.imageMessageWithText(user: MockData.agent),
                        item: MockData.imageItem(),
                        alertType: .constant(nil)
                    )
                    
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.agent),
                        item: MockData.imageItem(),
                        alertType: .constant(nil)
                    )
                }
                
                HStack(spacing: 12) {
                    ImageMessageCell(
                        message: MockData.imageMessageWithText(user: MockData.agent),
                        item: MockData.imageItem(),
                        alertType: .constant(nil)
                    )
                    
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.agent),
                        item: MockData.imageItem(),
                        alertType: .constant(nil)
                    )
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(style.colors(for: scheme).background.surface.default)
            )
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ImageMessageCell(
                        message: MockData.imageMessageWithText(user: MockData.customer),
                        item: MockData.imageItem(),
                        alertType: .constant(nil)
                    )
                    
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.customer),
                        item: MockData.imageItem(),
                        alertType: .constant(nil)
                    )
                }
                
                HStack(spacing: 12) {
                    ImageMessageCell(
                        message: MockData.imageMessageWithText(user: MockData.customer),
                        item: MockData.imageItem(),
                        alertType: .constant(nil)
                    )
                    
                    ImageMessageCell(
                        message: MockData.imageMessage(user: MockData.customer),
                        item: MockData.imageItem(),
                        alertType: .constant(nil)
                    )
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(style.colors(for: scheme).brand.primary)
            )
        }
    }
    .environmentObject(style)
}
