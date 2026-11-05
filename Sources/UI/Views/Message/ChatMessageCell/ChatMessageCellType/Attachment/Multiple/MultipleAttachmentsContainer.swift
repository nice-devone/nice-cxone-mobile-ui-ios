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

struct MultipleAttachmentsContainer: View, Themed, LayoutAware {
    
    // MARK: - Constants
    
    private enum Constants {
        
        static let displayMode: AttachmentThumbnailDisplayMode = .regular
        static let gridMaxCount = 4
        
        enum Spacing {
            static let itemSpacing: CGFloat = 12
        }

        enum Sizing {
            /// Two fixed columns of `thumbnailWidth`, separated by `Spacing.itemSpacing`.
            static func gridConfig(thumbnailWidth: CGFloat) -> [GridItem] {
                [
                    GridItem(.fixed(thumbnailWidth), spacing: Spacing.itemSpacing),
                    GridItem(.fixed(thumbnailWidth), spacing: Spacing.itemSpacing)
                ]
            }

            /// Exact width of the two fixed columns plus the gap between them. `LazyVGrid` otherwise
            /// consumes the full container width and distributes the leftover space into the
            /// inter-column gap — so in a wide landscape container the two thumbnails drift apart.
            /// Capping the grid at this width makes it hug its two columns.
            ///
            /// Applied as `maxWidth`, not `width`, so a container narrower than the two columns shrinks
            /// the grid instead of clipping it. The column width is derived from the screen's short edge
            /// while `messageMaxWidth` uses the screen width, so nothing structurally guarantees this
            /// stays inside the bubble if either divisor changes — see
            /// `StyleGuide.Sizing.Attachment.regularDimension`.
            static func gridWidth(thumbnailWidth: CGFloat) -> CGFloat {
                thumbnailWidth * 2 + Spacing.itemSpacing
            }
        }
        
        enum Padding {
            static let container: CGFloat = 12
            static let moreAttachmentsOverlayTextCircle: CGFloat = 10
        }
        
        enum Colors {
            static let moreAttachmentsOverlayBlur: CGFloat = 4
            static let moreAttachmentsOverlayContainerOpacity: CGFloat = 0.50
            static let moreAttachmentsOverlayTextCircleOpacity: CGFloat = 0.70
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `AttachmentThumbnailDisplayMode.size` directly, so a rotation invalidates this view and the size
    /// is resolved again. `Constants.Sizing` then derives the grid geometry from it.
    private var thumbnailSize: CGSize {
        attachmentSize(for: Constants.displayMode)
    }
    
    @Binding private var alertType: ChatAlertType?
    
    @State private var showAttachmentGalleryView = false
        
    private let message: ChatMessage
    private let position: MessageGroupPosition
    private let filteredTypes: [ChatMessageType]
    
    private var textMessage: String?
    private var audioAttachments = [AttachmentItem]()
    
    private var attachmentsGroupPosition: MessageGroupPosition {
        let hasAudio = !audioAttachments.isEmpty
        let hasText = textMessage != nil
        
        if hasAudio || hasText {
            return .first
        } else {
            return position
        }
    }
    private var audioGroupPosition: MessageGroupPosition {
        let hasAttachments = !filteredTypes.isEmpty
        let hasText = textMessage != nil
        
        switch (position, hasAttachments, hasText) {
        case (_, true, true):
            // Audio is between attachments and text
            return .inside
        case (_, true, false):
            // Audio is after attachments only
            return .last
        case (_, false, true):
            // Audio is before text only
            return .first
        case (.single, false, false):
            // Audio is the only component
            return .single
        default:
            // Use the original position in other cases
            return position
        }
    }
    
    var textMessageGroupPosition: MessageGroupPosition {
        let hasAttachments = !filteredTypes.isEmpty
        let hasAudio = !audioAttachments.isEmpty
        
        if hasAttachments || hasAudio {
            return .last
        } else {
            return position
        }
    }
    
    // MARK: - Init
    
    init(_ message: ChatMessage, position: MessageGroupPosition, alertType: Binding<ChatAlertType?>) {
        self.message = message
        self.position = position
        self._alertType = alertType
        self.filteredTypes = message.attachmentTypes
        
        for type in message.types {
            switch type {
            case .text(let text):
                self.textMessage = text
            case .audio(let audioItem):
                audioAttachments.append(audioItem)
            default:
                break
            }
        }
    }

    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: StyleGuide.Spacing.Message.groupCellSpacing) {
            LazyVGrid(columns: Constants.Sizing.gridConfig(thumbnailWidth: thumbnailSize.width), spacing: Constants.Spacing.itemSpacing) {
                contentView
            }
            .frame(maxWidth: Constants.Sizing.gridWidth(thumbnailWidth: thumbnailSize.width))
            .padding(Constants.Padding.container)
            .background(colors.bubbleBackground(isUserAgent: message.isUserAgent))
            .clipShape(attachmentsGroupPosition.clipShape(isUserAgent: message.isUserAgent))
            .shareable(message, attachments: AttachmentItemMapper.map(message.types))
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11y.Conversation.MessageCell.MultipleAttachments.Container.identifier)
            .accessibilityLabel(A11y.Conversation.MessageCell.MultipleAttachments.Container.label("\(filteredTypes.count)"))

            ForEach(audioAttachments, id: \.self) { audioAttachment in
                AudioMessageCell(
                    message: message,
                    item: audioAttachment,
                    position: audioGroupPosition,
                    alertType: $alertType
                )
            }
            
            if let textMessage {
                TextMessageCell(message: message, text: textMessage, position: textMessageGroupPosition)
            }
        }
        // Attached here, to the container's own body, and never to `contentView`: that is a `ForEach`
        // inside the `LazyVGrid`, so the modifier would ride on the grid's lazily-created children. A
        // re-layout — a rotation, or simply scrolling the conversation far enough — tears those children
        // down and rebuilds them, taking the presentation with them: the gallery dismisses and
        // immediately re-presents, destroying whatever it had presented in turn (the full-screen
        // `ImageViewer`). The body is stable for the life of the cell, so the sheet survives.
        .sheet(isPresented: $showAttachmentGalleryView) {
            NavigationStack {
                AttachmentGalleryView(message: message, messageTypes: filteredTypes, alertType: $alertType)
            }
        }
    }
}

// MARK: - Helpers

private extension MultipleAttachmentsContainer {

    /// How many grid cells are drawn.
    var visibleCount: Int {
        min(filteredTypes.count, Constants.gridMaxCount)
    }

    /// The cell that carries the "+N" overlay when there are more attachments than the grid shows.
    var overflowIndex: Int {
        Constants.gridMaxCount - 1
    }

    /// The number shown in the "+N" overlay; `0` when everything fits in the grid.
    var hiddenCount: Int {
        if filteredTypes.count > Constants.gridMaxCount {
            return filteredTypes.count - overflowIndex
        } else {
            return 0
        }
    }
}

// MARK: - Subviews

private extension MultipleAttachmentsContainer {
    
    var contentView: some View {
        ForEach(0..<visibleCount, id: \.self) { index in
            cellContent(for: filteredTypes[index])
                .if(index == overflowIndex && hiddenCount > 0) { view in
                    view
                        .blur(radius: Constants.Colors.moreAttachmentsOverlayBlur)
                        .overlay(
                            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                                .fill(colors.content.primary.opacity(Constants.Colors.moreAttachmentsOverlayContainerOpacity))
                                .overlay(moreAttachmentsIndicatorView)
                                .onTapGesture {
                                    showAttachmentGalleryView.toggle()
                                }
                        )
                }
        }
    }
    
    @ViewBuilder
    func cellContent(for messageType: ChatMessageType) -> some View {
        switch messageType {
        case .image(let item):
            ImageMessageCell(message: message, item: item, alertType: $alertType)
        case .video(let item):
            VideoMessageCell(message: message, item: item, alertType: $alertType)
        case .documentPreview(let item):
            DocumentMessageCell(message: message, item: item, alertType: $alertType)
        default:
            EmptyView()
        }
    }
    
    var moreAttachmentsIndicatorView: some View {
        Text("+\(hiddenCount)") // swiftlint:disable:this hardcoded_strings
            .font(.callout)
            .fontWeight(.bold)
            .foregroundStyle(colors.content.primary)
            .padding(Constants.Padding.moreAttachmentsOverlayTextCircle)
            .background(
                Circle()
                    .fill(colors.brand.onPrimary)
                    .opacity(Constants.Colors.moreAttachmentsOverlayTextCircleOpacity)
            )
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(A11y.Conversation.MessageCell.MultipleAttachments.MoreIndicator.identifier)
            .accessibilityLabel(A11y.Conversation.MessageCell.MultipleAttachments.MoreIndicator.label("\(hiddenCount)"))
            .accessibilityHint(A11y.Conversation.MessageCell.MultipleAttachments.MoreIndicator.hint)
    }
}

// MARK: - Preview

#Preview("Media Attachments") {
    NavigationStack {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                MultipleAttachmentsContainer(
                    MockData.multipleMediaAttachmentsMessage(
                        user: MockData.agent,
                        messages: [
                            .text(Lorem.sentence()),
                            .image(MockData.imageItem()),
                            .video(MockData.videoItem)
                        ]
                    ),
                    position: .single,
                    alertType: .constant(nil)
                )

                MultipleAttachmentsContainer(
                    MockData.multipleMediaAttachmentsMessage(user: MockData.customer),
                    position: .single,
                    alertType: .constant(nil)
                )
                
                MultipleAttachmentsContainer(
                    MockData.multipleMediaAttachmentsMessage(user: MockData.agent),
                    position: .single,
                    alertType: .constant(nil)
                )
                
                Spacer()
            }
        }
        .padding(.horizontal, 10)
    }
    .environmentObject(ChatStyle())
}

#Preview("Document Attachments") {
    NavigationStack {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                MultipleAttachmentsContainer(
                    MockData.multipleDocumentAttachmentsMessage(
                        user: MockData.agent,
                        messages: [
                            .text(Lorem.sentence()),
                            .documentPreview(MockData.pdfPreviewItem),
                            .documentPreview(MockData.docPreviewItem)
                        ]
                    ),
                    position: .single,
                    alertType: .constant(nil)
                )

                MultipleAttachmentsContainer(
                    MockData.multipleDocumentAttachmentsMessage(user: MockData.customer),
                    position: .single,
                    alertType: .constant(nil)
                )
                
                MultipleAttachmentsContainer(
                    MockData.multipleDocumentAttachmentsMessage(user: MockData.agent),
                    position: .single,
                    alertType: .constant(nil)
                )
                
                Spacer()
            }
        }
        .padding(.horizontal, 10)
    }
    .environmentObject(ChatStyle())
}
