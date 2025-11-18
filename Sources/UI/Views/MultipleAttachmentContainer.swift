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
    
    // MARK: - Constants
    
    private enum Constants {
        
        static let displayMode: AttachmentThumbnailDisplayMode = .regular
        static let gridMaxCount = 4
        static let gridConfig = [
            GridItem(.fixed(displayMode.size.width), spacing: Spacing.itemSpacing),
            GridItem(.fixed(displayMode.size.width), spacing: Spacing.itemSpacing)
        ]
        
        enum Spacing {
            static let itemSpacing: CGFloat = 12
            static let shareButtonMinLength: CGFloat = 0
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
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @Binding private var alertType: ChatAlertType?
    
    @State private var showAttachmentsView = false
        
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
        let hasAudio = !audioAttachments.isEmpty
        
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
                audioAttachments.append(audioItem)
            default:
                break
            }
        }
    }

    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: StyleGuide.Spacing.Message.groupCellSpacing) {
            LazyVGrid(columns: Constants.gridConfig, spacing: Constants.Spacing.itemSpacing) {
                contentView
            }
            .padding(Constants.Padding.container)
            .background(
                message.isUserAgent
                    ? colors.background.surface.default
                    : colors.brand.primary
            )
            .messageChatStyle(message, position: attachmentsGroupPosition)
            .shareable(message, attachments: AttachmentItemMapper.map(message.types), spacerLength: Constants.Spacing.shareButtonMinLength)
            
            ForEach(audioAttachments, id: \.self) { audioAttachment in
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
        ForEach(0..<(filteredTypes.count <= Constants.gridMaxCount ? filteredTypes.count : Constants.gridMaxCount), id: \.self) { index in
            cellContent(for: filteredTypes[index])
                .frame(width: Constants.displayMode.size.width, height: Constants.displayMode.size.height)
                .if(index == 3 && filteredTypes.count > Constants.gridMaxCount) { view in
                    view
                        .blur(radius: Constants.Colors.moreAttachmentsOverlayBlur)
                        .overlay(
                            colors.content.primary
                                .frame(width: Constants.displayMode.size.width, height: Constants.displayMode.size.height)
                                .opacity(Constants.Colors.moreAttachmentsOverlayContainerOpacity)
                                .overlay(
                                    moreAttachmentsIndicatorView
                                )
                                .onTapGesture {
                                    showAttachmentsView.toggle()
                                }
                        )
                }
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
                alertType: $alertType,
                localization: localization
            )
            .frame(width: Constants.displayMode.size.width, height: Constants.displayMode.size.height)
        case .video(let item):
            VideoMessageCell(
                message: message,
                item: item,
                alertType: $alertType,
                localization: localization
            )
            .frame(width: Constants.displayMode.size.width, height: Constants.displayMode.size.height)
        case .documentPreview(let item):
            DocumentMessageCell(
                message: message,
                item: item,
                alertType: $alertType
            )
            .frame(width: Constants.displayMode.size.width, height: Constants.displayMode.size.height)
        default:
            EmptyView()
        }
    }
    
    var moreAttachmentsIndicatorView: some View {
        Text("+\(filteredTypes.count - 3)")
            .font(.callout)
            .fontWeight(.bold)
            .foregroundStyle(colors.content.primary)
            .padding(Constants.Padding.moreAttachmentsOverlayTextCircle)
            .background(
                Circle()
                    .fill(colors.brand.onPrimary)
                    .opacity(Constants.Colors.moreAttachmentsOverlayTextCircleOpacity)
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
