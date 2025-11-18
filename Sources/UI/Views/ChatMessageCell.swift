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

struct ChatMessageCell: View {

    // MARK: - Properties

    @EnvironmentObject private var localization: ChatLocalization
    
    @Binding private var alertType: ChatAlertType?
    @Binding private var isLast: Bool
    
    @State private var forceDateHeader = false

    private let message: ChatMessage
    private let messageGroupPosition: MessageGroupPosition
    private let onRichMessageElementTapped: (_ textToSend: String?, RichMessageSubElementType) -> Void
    private let isMultiAttachment: Bool

    // MARK: - Init

    init(
        message: ChatMessage,
        messageGroupPosition: MessageGroupPosition,
        isLast: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        onRichMessageElementTapped: @escaping (_ textToSend: String?, RichMessageSubElementType) -> Void
    ) {
        self.message = message
        self.messageGroupPosition = messageGroupPosition
        self._isLast = isLast
        self._alertType = alertType
        self.onRichMessageElementTapped = onRichMessageElementTapped
        self.isMultiAttachment = message.types.filter(\.isAttachment).count > 1
    }

    // MARK: - Builder

    var body: some View {
        VStack {
            if isMultiAttachment {
                MultipleAttachmentContainer(message, position: messageGroupPosition, alertType: $alertType)
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
                    alertType: $alertType,
                    localization: localization
                )
            case .image(let item):
                ImageMessageCell(
                    message: message,
                    item: item,
                    position: messageGroupPosition,
                    alertType: $alertType,
                    localization: localization
                )
            case .audio(let item):
                AudioMessageCell(
                    message: message,
                    item: item,
                    position: messageGroupPosition,
                    alertType: $alertType,
                    localization: localization
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
                    QuickRepliesMessageCell(item: item, isLast: $isLast) { option in
                        onRichMessageElementTapped(option.title, .button(option))
                    }
                case .listPicker(let item):
                    ListPickerMessageCell(item: item) { option in
                        onRichMessageElementTapped(option.title, .button(option))
                    }
                case .richLink(let item):
                    RichLinkMessageCell(message: message, item: item) { url in
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
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
                ) { _, _ in }
                
                ChatMessageCell(
                    message: MockData.textMessage(user: MockData.agent),
                    messageGroupPosition: .last,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _, _ in }
                
                ChatMessageCell(
                    message: MockData.imageMessage(user: MockData.agent, elementsCount: 1),
                    messageGroupPosition: .first,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _, _ in }
                
                ChatMessageCell(
                    message: MockData.textMessage(user: MockData.agent),
                    messageGroupPosition: .last,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _, _ in }
            }
            
            LazyVStack(spacing: 2) {
                ChatMessageCell(
                    message: MockData.audioMessage(user: MockData.customer),
                    messageGroupPosition: .first,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _, _ in }
                
                ChatMessageCell(
                    message: MockData.documentMessage(user: MockData.customer),
                    messageGroupPosition: .inside,
                    isLast: .constant(false),
                    alertType: .constant(nil)
                ) { _, _ in }
                
                ChatMessageCell(
                    message: MockData.imageMessage(user: MockData.customer, elementsCount: 5),
                    messageGroupPosition: .last,
                    isLast: .constant(true),
                    alertType: .constant(nil)
                ) { _, _ in }
            }
        }
    }
    .padding(.horizontal, 12)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
