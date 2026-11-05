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

struct ChatMessageCell: View {

    // MARK: - Properties
    
    @Binding private var alertType: ChatAlertType?
    @Binding private var isLast: Bool
    
    @State private var forceDateHeader = false

    private let message: ChatMessage
    private let messageGroupPosition: MessageGroupPosition
    private let onRichMessageElementTapped: (RichMessageSubElementType) -> Void
    private let isMultiAttachment: Bool

    // MARK: - Init

    init(
        message: ChatMessage,
        messageGroupPosition: MessageGroupPosition,
        isLast: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        onRichMessageElementTapped: @escaping (RichMessageSubElementType) -> Void
    ) {
        self.message = message
        self.messageGroupPosition = messageGroupPosition
        self._isLast = isLast
        self._alertType = alertType
        self.onRichMessageElementTapped = onRichMessageElementTapped
        self.isMultiAttachment = message.attachmentTypes.count > 1
    }

    // MARK: - Builder

    var body: some View {
        VStack {
            if isMultiAttachment {
                MultipleAttachmentsContainer(message, position: messageGroupPosition, alertType: $alertType)
            } else {
                messageContent
            }
        }
    }
}

// MARK: - Subviews

private extension ChatMessageCell {

    @ViewBuilder
    var messageContent: some View {
        ForEach(message.types, id: \.self) { type in
            switch type {
            case .text(let text):
                TextMessageCell(message: message, text: text, position: messageGroupPosition)
                    .onTapGesture {
                        withAnimation {
                            forceDateHeader.toggle()
                        }
                    }
            case .video(let item):
                VideoMessageCell(
                    message: message,
                    item: item,
                    position: messageGroupPosition,
                    alertType: $alertType
                )
            case .image(let item):
                ImageMessageCell(
                    message: message,
                    item: item,
                    position: messageGroupPosition,
                    alertType: $alertType
                )
            case .audio(let item):
                AudioMessageCell(
                    message: message,
                    item: item,
                    position: messageGroupPosition,
                    alertType: $alertType
                )
            case .documentPreview(let item):
                DocumentMessageCell(
                    message: message,
                    item: item,
                    position: messageGroupPosition,
                    alertType: $alertType
                )
            case .richContent(let content):
                switch content {
                case .quickReplies(let item):
                    QuickRepliesMessageCell(message: message, item: item, isLast: $isLast) { option in
                        onRichMessageElementTapped(.button(option))
                    }
                case .listPicker(let item):
                    ListPickerMessageCell(message: message, item: item) { option in
                        onRichMessageElementTapped(.button(option))
                    }
                case .richLink(let item):
                    RichLinkMessageCell(message: message, item: item)
                case .timePicker(let item):
                    TimePickerMessageCell(message: message, item: item, isLast: $isLast) { option in
                         onRichMessageElementTapped(.timeSlot(option))
                    }
                }
            case .unknown(let fallbackText):
                UnsupportedMessageCell(message: message, text: fallbackText, position: messageGroupPosition)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack {
            LazyVStack(spacing: 2) {
                ChatMessageCell(
                    message: MockData.imageMessage(user: MockData.agent, elementsCount: 1),
                    messageGroupPosition: .first,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _ in }
                
                ChatMessageCell(
                    message: MockData.unsupportedMessage(),
                    messageGroupPosition: .inside,
                    isLast: .constant(false),
                    alertType: .constant(nil)) { _ in }
                
                ChatMessageCell(
                    message: MockData.textMessage(user: MockData.agent),
                    messageGroupPosition: .inside,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _ in }
                
                ChatMessageCell(
                    message: MockData.imageMessage(user: MockData.agent, elementsCount: 1),
                    messageGroupPosition: .inside,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _ in }
                
                ChatMessageCell(
                    message: MockData.textMessage(user: MockData.agent),
                    messageGroupPosition: .last,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _ in }
            }
            
            LazyVStack(spacing: 2) {
                ChatMessageCell(
                    message: MockData.audioMessage(user: MockData.customer),
                    messageGroupPosition: .first,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _ in }
                
                ChatMessageCell(
                    message: MockData.documentMessage(user: MockData.customer),
                    messageGroupPosition: .inside,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _ in }
                
                ChatMessageCell(
                    message: MockData.imageMessage(user: MockData.customer, elementsCount: 5),
                    messageGroupPosition: .last,
                    isLast: .constant(true),
                    alertType: .constant(nil)
                ) { _ in }
            }
        }
    }
    .padding(.horizontal, 12)
    .environmentObject(ChatStyle())
}
