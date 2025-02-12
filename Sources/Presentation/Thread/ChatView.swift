//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

import CXoneChatSDK
import SwiftUI

struct ChatView: View, Themed {

    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @EnvironmentObject private var localization: ChatLocalization

    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @Binding private var hasMoreMessagesToLoad: Bool
    @Binding private var isAgentTyping: Bool
    @Binding private var isUserTyping: Bool
    @Binding private var isInputEnabled: Bool
    @Binding private var isProcessDialogVisible: Bool
    @Binding private var alertType: ChatAlertType?
    
    private let chatManager: ChatManager
    private let attachmentRestrictions: AttachmentRestrictions
    private let onNewMessage: (ChatMessageType, [AttachmentItem]) -> Void
    private let loadMoreMessages: () -> Void
    private let onRichMessageElementSelected: (_ textToSend: String?, RichMessageSubElementType) -> Void
    
    static let packageIdentifier = "CXoneChatUI"

    // MARK: - Init

    init(
        messages: Binding<[ChatMessage]>,
        hasMoreMessagesToLoad: Binding<Bool>,
        isAgentTyping: Binding<Bool>,
        isUserTyping: Binding<Bool>,
        isInputEnabled: Binding<Bool>,
        isProcessDialogVisible: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        attachmentRestrictions: AttachmentRestrictions,
        onNewMessage: @escaping (ChatMessageType, [AttachmentItem]) -> Void,
        loadMoreMessages: @escaping () -> Void,
        onRichMessageElementSelected: @escaping (_ textToSend: String?, RichMessageSubElementType) -> Void
    ) {
        self.chatManager = ChatManager(messages: messages.wrappedValue)
        self._hasMoreMessagesToLoad = hasMoreMessagesToLoad
        self._isAgentTyping = isAgentTyping
        self._isUserTyping = isUserTyping
        self._isInputEnabled = isInputEnabled
        self._isProcessDialogVisible = isProcessDialogVisible
        self._alertType = alertType
        self.attachmentRestrictions = attachmentRestrictions
        self.onNewMessage = onNewMessage
        self.loadMoreMessages = loadMoreMessages
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    if hasMoreMessagesToLoad {
                        Button("Load more", action: loadMoreMessages)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .font(.caption)
                            .foregroundStyle(colors.foreground.base)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colors.background.interactivePrimary)
                            )
                            .padding(.bottom, 10)
                    }
                    
                    let groupedMessages = chatManager.groupMessages()
                    
                    LazyVStack {
                        ForEach(groupedMessages) { group in
                            MessageGroupView(
                                group: group,
                                isProcessDialogVisible: $isProcessDialogVisible,
                                alertType: $alertType,
                                onRichMessageElementSelected: onRichMessageElementSelected
                            )
                            .id(group.id)
                        }
                    }
                    .onChange(of: groupedMessages) { group in
                        withAnimation {
                            proxy.scrollTo(group.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(groupedMessages.last?.id, anchor: .bottom)
                    }

                    if isAgentTyping {
                        typingIndicator(proxy: proxy)
                    }
                }
                .frame(maxWidth: .infinity)
                .clipped()
            }

            if isInputEnabled {
                MessageInputView(
                    attachmentRestrictions: attachmentRestrictions,
                    isEditing: $isUserTyping,
                    alertType: $alertType,
                    onSend: onNewMessage
                )
            } else {
                archivedChatMessage
                    .padding(.bottom, UIDevice.current.hasHomeButton ? 10 : 0)
            }
        }
        .background(style.backgroundColor)
        .overlay(isVisible: $isProcessDialogVisible) {
            attachmentsUploadOverlay
        }
    }
}

// MARK: - Subviews

private extension ChatView {

    func typingIndicator(proxy: ScrollViewProxy) -> some View {
        HStack {
            TypingIndicator()
                .id("typingIndicator")
                .padding(.leading, 10)
                .onAppear {
                    withAnimation {
                        proxy.scrollTo("typingIndicator")
                    }
                }

            Spacer()
        }
    }
    
    var archivedChatMessage: some View {
        VStack(spacing: 10) {
            Divider()
                .padding(.horizontal, 24)
                .foregroundColor(style.formTextColor)
                .opacity(0.5)
            
            HStack {
                Asset.Message.archived
                
                Text(CXoneChat.shared.mode == .liveChat ? localization.chatMessageInputClosed : localization.chatMessageInputArchived)
            }
            .foregroundColor(style.formTextColor)
            .opacity(0.5)
        }
    }

    var attachmentsUploadOverlay: some View {
        HStack(spacing: 10) {
            ProgressView()
            
            Text(localization.chatAttachmentsUpload)
                .foregroundColor(style.formTextColor)
        }
        .tint(style.formTextColor.opacity(0.5))
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.backgroundColor)
        )
    }
}

// MARK: - Previews

struct ChatView_Previews: PreviewProvider {
    
    private static let messages = [
        MockData.textMessage(user: MockData.agent),
        MockData.imageMessage(user: MockData.customer),
        MockData.emojiMessage(user: MockData.agent)
    ]
    private static let hasMoreMessagesToLoad = true
    private static let isAgentTyping = false
    private static let isInputEnabled = true
    private static let isProcessDialogVisible = false
    private static let alertType: ChatAlertType? = nil
    private static let attachmentRestrictions = AttachmentRestrictions(
        allowedFileSize: 40,
        allowedTypes: ["image/*", "video/*", "audio/*"],
        areAttachmentsEnabled: true
    )
    
    static var previews: some View {
        Group {
            ChatView(
                messages: .constant(messages),
                hasMoreMessagesToLoad: .constant(hasMoreMessagesToLoad),
                isAgentTyping: .constant(isAgentTyping),
                isUserTyping: .constant(false),
                isInputEnabled: .constant(isInputEnabled),
                isProcessDialogVisible: .constant(isProcessDialogVisible),
                alertType: .constant(alertType),
                attachmentRestrictions: attachmentRestrictions,
                onNewMessage: { _, _ in },
                loadMoreMessages: { },
                onRichMessageElementSelected: { _, _ in }
            )
            .previewDisplayName("Light mode")
            
            ChatView(
                messages: .constant(messages),
                hasMoreMessagesToLoad: .constant(hasMoreMessagesToLoad),
                isAgentTyping: .constant(isAgentTyping),
                isUserTyping: .constant(false),
                isInputEnabled: .constant(isInputEnabled),
                isProcessDialogVisible: .constant(isProcessDialogVisible),
                alertType: .constant(alertType),
                attachmentRestrictions: attachmentRestrictions,
                onNewMessage: { _, _ in },
                loadMoreMessages: { },
                onRichMessageElementSelected: { _, _ in }
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Light mode")
        }
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
    }
}
