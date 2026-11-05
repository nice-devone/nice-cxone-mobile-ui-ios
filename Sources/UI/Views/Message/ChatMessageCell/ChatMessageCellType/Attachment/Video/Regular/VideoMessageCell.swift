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

struct VideoMessageCell: View, Themed, LayoutAware {

    // MARK: - Constants
    
    private enum Constants {
        static let displayMode: AttachmentThumbnailDisplayMode = .regular
        static let accessibilityIdentifierType = "video"
    }
    
    // MARK: - Properties
    
    @StateObject private var viewModel: VideoMessageCellViewModel

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    @Environment(\.presentAttachmentPreview) private var presentAttachmentPreview

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `AttachmentThumbnailDisplayMode.size` directly, so a rotation invalidates this view and the size
    /// is resolved again.
    private var thumbnailSize: CGSize {
        attachmentSize(for: Constants.displayMode)
    }

    private let message: ChatMessage
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
        self._viewModel = StateObject(wrappedValue: VideoMessageCellViewModel(item: item, alertType: alertType))
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

private extension VideoMessageCell {

    @ViewBuilder
    var content: some View {
        // Computed once and shared by all three loading states so the failed/loading
        // placeholders line up with the same message-group corner as the loaded video.
        let clipShape = position.attachmentClipShape(isUserAgent: message.isUserAgent)

        switch viewModel.loadingState {
        case .loaded(let url):
            Button {
                presentAttachmentPreview(.video(url, name: viewModel.item.friendlyName))
            } label: {
                VideoThumbnailView(url: url, displayMode: Constants.displayMode, clipShape: clipShape)
            }
            .clippedHitArea(clipShape)
            .overlay {
                clipShape
                    .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(A11y.Conversation.MessageCell.Attachment.identifier(type: Constants.accessibilityIdentifierType))
            .accessibilityLabel(A11y.Conversation.MessageCell.Attachment.Video.label(viewModel.item.fileName))
            .accessibilityHint(A11y.Conversation.MessageCell.Attachment.Video.hint)
        case .failed:
            Button {
                Task { @MainActor in
                    await viewModel.cacheVideoFromURL()
                }
            } label: {
                AttachmentFailedView(size: thumbnailSize, clipShape: clipShape, drawsBorder: true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(A11y.Conversation.MessageCell.Attachment.Video.Failed.identifier)
            .accessibilityLabel(A11y.Conversation.MessageCell.Attachment.Video.Failed.label)
            .accessibilityHint(A11y.Conversation.MessageCell.Attachment.Video.Failed.hint)
        default:
            AttachmentLoadingView(size: thumbnailSize, clipShape: clipShape, drawsBorder: true)
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(A11y.Conversation.MessageCell.Attachment.Video.Loading.identifier)
            .accessibilityLabel(A11y.Conversation.MessageCell.Attachment.Video.Loading.label)
        }
    }
}

// MARK: - Preview

#Preview("Single") {
    ScrollView {
        VStack(spacing: 4) {
            VideoMessageCell(
                message: MockData.videoMessage(user: MockData.agent),
                item: MockData.videoItem,
                position: .single,
                alertType: .constant(nil)
            )

            VideoMessageCell(
                message: MockData.videoMessage(user: MockData.customer),
                item: MockData.videoItem,
                position: .single,
                alertType: .constant(nil)
            )
            
            VStack(spacing: 4) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    position: .first,
                    alertType: .constant(nil)
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    position: .inside,
                    alertType: .constant(nil)
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    position: .last,
                    alertType: .constant(nil)
                )
            }
            
            VStack(spacing: 4) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    position: .first,
                    alertType: .constant(nil)
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    position: .inside,
                    alertType: .constant(nil)
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    position: .last,
                    alertType: .constant(nil)
                )
            }
        }
        .padding(.horizontal, 16)
    }
    .environmentObject(ChatStyle())
}

@available(iOS 17, *)
#Preview("Multiple") {
    @Previewable @Environment(\.colorScheme) var scheme

    let style = ChatStyle()

    VStack {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    alertType: .constant(nil)
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    alertType: .constant(nil)
                )
            }
            
            HStack(spacing: 12) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    alertType: .constant(nil)
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
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
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    alertType: .constant(nil)
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    alertType: .constant(nil)
                )
            }
            
            HStack(spacing: 12) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    alertType: .constant(nil)
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
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
    .environmentObject(style)
}
