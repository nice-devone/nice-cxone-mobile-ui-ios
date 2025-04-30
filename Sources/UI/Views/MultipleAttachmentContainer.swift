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

struct MultipleAttachmentContainer: View, Themed {
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @Binding private var alertType: ChatAlertType?
    
    @State private var showAttachmentsView = false
        
    private let message: ChatMessage
    private let position: MessageGroupPosition
    private let filteredTypes: [ChatMessageType]
    private let displayMode: VideoThumbnailDisplayMode = .multipleContainer

    private var textMessage: String?
    private var audioAttachment: AttachmentItem?
    
    private static let moreAttachmentsOverlayBlur: CGFloat = 4
    private static let moreAttachmentsOverlayContainerOpacity: CGFloat = 0.50
    private static let moreAttachmentsOverlayTextCircleOpacity: CGFloat = 0.75
    private static let moreAttachmentsOverlayTextCirclePadding: CGFloat = 10
    private static let itemSpacing: CGFloat = 12
    private static let containerPadding: CGFloat = 12
    
    private var config: [GridItem] {
        [
            GridItem(.fixed(displayMode.width), spacing: Self.itemSpacing),
            GridItem(.fixed(displayMode.width), spacing: Self.itemSpacing)
        ]
    }
    
    private var attachmentsGroupPosition: MessageGroupPosition {
        let hasAudio = audioAttachment != nil
        let hasText = textMessage != nil
        
        if hasAudio || hasText {
            return .first
        }
        
        return position
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
        let hasAudio = audioAttachment != nil
        
        if hasAttachments || hasAudio {
            return .last
        }
        
        return position
    }
    
    // MARK: - Init
    
    init(_ message: ChatMessage, position: MessageGroupPosition, alertType: Binding<ChatAlertType?>) {
        self.message = message
        self.position = position
        self._alertType = alertType
        self.filteredTypes = message.types.filter(\.isAttachment)
        
        for type in message.types {
            switch type {
            case .text(let text):
                self.textMessage = text
            case .audio(let audioItem):
                self.audioAttachment = audioItem
            default:
                break
            }
        }
    }

    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: StyleGuide.Message.groupCellSpacing) {
            LazyVGrid(columns: self.config, spacing: Self.itemSpacing) {
                contentView
            }
            .padding(Self.containerPadding)
            .background(
                message.isUserAgent
                    ? colors.customizable.agentBackground
                    : colors.customizable.customerBackground
            )
            .messageChatStyle(message, position: attachmentsGroupPosition)
            .shareable(message, attachments: AttachmentItemMapper.map(message.types), spacerLength: 0)
            
            if let audioAttachment {
                AudioMessageCell(
                    message: message,
                    item: audioAttachment,
                    position: audioGroupPosition,
                    alertType: $alertType,
                    localization: localization
                )
            }
            
            if let textMessage {
                TextMessageCell(message: message, text: textMessage, position: textMessageGroupPosition)
            }
        }
    }
}

// MARK: - Subviews

private extension MultipleAttachmentContainer {
    
    var contentView: some View {
        ForEach(Array(filteredTypes.enumerated().prefix(4)), id: \.element) { index, messageType in
            cellContent(for: messageType)
                .frame(width: displayMode.width, height: displayMode.height)
                .if(index == 3 && filteredTypes.count > 4) { view in
                    view
                        .blur(radius: Self.moreAttachmentsOverlayBlur)
                        .overlay(
                            colors.foreground.staticDark
                                .frame(width: displayMode.width, height: displayMode.height)
                                .opacity(Self.moreAttachmentsOverlayContainerOpacity)
                                .overlay(
                                    moreAttachmentsIndicatorView
                                )
                                .onTapGesture {
                                    showAttachmentsView.toggle()
                                }
                        )
                }
                .cornerRadius(StyleGuide.Attachment.cornerRadius, corners: .allCorners)
        }
        .sheet(isPresented: $showAttachmentsView) {
            AttachmentsView(message: message, messageTypes: filteredTypes, alertType: $alertType)
        }
    }
    
    @ViewBuilder
    func cellContent(for messageType: ChatMessageType) -> some View {
        switch messageType {
        case .image(let item):
            ImageMessageCell(
                message: message,
                item: item,
                isMultiAttachment: true,
                position: position,
                alertType: $alertType,
                localization: localization
            )
                .frame(width: displayMode.width, height: displayMode.height)
        case .video(let item):
            VideoMessageCell(
                message: message,
                item: item,
                displayMode: .multipleContainer,
                position: position,
                alertType: $alertType,
                localization: localization
            )
            .frame(width: displayMode.width, height: displayMode.height)
        case .documentPreview(let item):
            MultipleAttachmentDocumentView(
                attachmentItem: item,
                isSenderAgent: message.isUserAgent,
                width: displayMode.width,
                height: displayMode.height,
                alertType: $alertType,
                localization: localization
            )
        default:
            EmptyView()
        }
    }
    
    var moreAttachmentsIndicatorView: some View {
        Text("+\(filteredTypes.count - 3)")
            .font(.callout)
            .fontWeight(.bold)
            .foregroundColor(colors.foreground.staticDark)
            .padding(Self.moreAttachmentsOverlayTextCirclePadding)
            .background(
                Circle()
                    .fill(colors.foreground.staticLight)
                    .opacity(Self.moreAttachmentsOverlayTextCircleOpacity)
            )
    }
}

// MARK: - Preview

#Preview("Media Attachments") {
    ScrollView(showsIndicators: false) {
        LazyVStack {
            MultipleAttachmentContainer(
                MockData.multipleMediaAttachmentsMessage(user: MockData.customer),
                position: .single,
                alertType: .constant(nil)
            )
            
            MultipleAttachmentContainer(
                MockData.multipleMediaAttachmentsMessage(user: MockData.agent),
                position: .single,
                alertType: .constant(nil)
            )
            
            Spacer()
        }
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}

#Preview("Document Attachments") {
    ScrollView(showsIndicators: false) {
        LazyVStack {
            MultipleAttachmentContainer(
                MockData.multipleDocumentAttachmentsMessage(user: MockData.customer),
                position: .single,
                alertType: .constant(nil)
            )
            
            MultipleAttachmentContainer(
                MockData.multipleDocumentAttachmentsMessage(user: MockData.agent),
                position: .single,
                alertType: .constant(nil)
            )
            
            Spacer()
        }
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
