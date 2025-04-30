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

import CXoneChatSDK
import SwiftUI

struct ChatView: View, Themed {

    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @EnvironmentObject private var localization: ChatLocalization

    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @Binding private var hasMoreMessagesToLoad: Bool
    @Binding private var typingAgent: ChatUser?
    @Binding private var isUserTyping: Bool
    @Binding private var isInputEnabled: Bool
    @Binding private var isProcessDialogVisible: Bool
    @Binding private var alertType: ChatAlertType?
    @Binding private var messageGroups: [MessageGroup]

    private let attachmentRestrictions: AttachmentRestrictions
    private let onNewMessage: (ChatMessageType, [AttachmentItem]) -> Void
    private let loadMoreMessages: () async -> Void
    private let onRichMessageElementSelected: (_ textToSend: String?, RichMessageSubElementType) -> Void
    private let queuePosition: Int?
    
    static let packageIdentifier = "CXoneChatUI"
    
    private static let bottomID = "bottom"
    private static let messageGroupsVerticalSpace: CGFloat = 16
    private static let typingIndicatorLeadingPadding: CGFloat = 16
    
    // MARK: - Init

    init(
        messageGroups: Binding<[MessageGroup]>,
        hasMoreMessagesToLoad: Binding<Bool>,
        typingAgent: Binding<ChatUser?>,
        isUserTyping: Binding<Bool>,
        isInputEnabled: Binding<Bool>,
        isProcessDialogVisible: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        attachmentRestrictions: AttachmentRestrictions,
        queuePosition: Int? = nil,
        onNewMessage: @escaping (ChatMessageType, [AttachmentItem]) -> Void,
        loadMoreMessages: @escaping () async -> Void,
        onRichMessageElementSelected: @escaping (_ textToSend: String?, RichMessageSubElementType) -> Void
    ) {
        self._messageGroups = messageGroups
        self._hasMoreMessagesToLoad = hasMoreMessagesToLoad
        self._typingAgent = typingAgent
        self._isUserTyping = isUserTyping
        self._isInputEnabled = isInputEnabled
        self._isProcessDialogVisible = isProcessDialogVisible
        self._alertType = alertType
        self.attachmentRestrictions = attachmentRestrictions
        self.queuePosition = queuePosition
        self.onNewMessage = onNewMessage
        self.loadMoreMessages = loadMoreMessages
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: 0) {
            if let queuePosition {
                LivechatPositionInQueueView(position: queuePosition)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        Spacer(minLength: Self.messageGroupsVerticalSpace)
                        
                        ForEach(messageGroups) { group in
                            MessageGroupView(
                                group: group,
                                isProcessDialogVisible: $isProcessDialogVisible,
                                alertType: $alertType,
                                onRichMessageElementSelected: onRichMessageElementSelected
                            )
                            .id(group.id)
                        }
                    }
                    .onChange(of: messageGroups) { _ in
                        withAnimation {
                            proxy.scrollTo(Self.bottomID, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(messageGroups.last?.id, anchor: .bottom)
                    }

                    if let typingAgent {
                        typingIndicator(agent: typingAgent, proxy: proxy)
                            .padding(.leading, Self.typingIndicatorLeadingPadding)
                    }
                    
                    Spacer(minLength: Self.messageGroupsVerticalSpace)
                        .id(Self.bottomID)
                }
                .if(hasMoreMessagesToLoad) { view in
                    view.refreshable {
                        await loadMoreMessages()
                    }
                }
            }

            if isInputEnabled {
                MessageInputView(
                    attachmentRestrictions: attachmentRestrictions,
                    isEditing: $isUserTyping,
                    alertType: $alertType,
                    localization: localization,
                    onSend: onNewMessage
                )
            } else {
                archivedChatMessage
                    .padding(.bottom, UIDevice.hasHomeButton ? 10 : 0)
            }
        }
        .background(colors.customizable.background)
    }
}

// MARK: - Subviews

private extension ChatView {

    func typingIndicator(agent: ChatUser?, proxy: ScrollViewProxy) -> some View {
        HStack {
            TypingIndicator(agent: agent)
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(Self.bottomID)
                    }
                }

            Spacer()
        }
    }
    
    var archivedChatMessage: some View {
        VStack(spacing: 10) {
            ColoredDivider(colors.customizable.background.opacity(0.5))
                .padding(.horizontal, 24)
            
            HStack {
                Asset.Message.archiveFill
                
                Text(
                    CXoneChat.shared.mode == .liveChat
                        ? localization.chatMessageInputClosed
                        : localization.chatMessageInputArchived
                )
            }
            .foregroundColor(colors.customizable.onBackground)
            .opacity(0.5)
        }
    }
}

// MARK: - Previews

#Preview {
    let messageGroups = [
        MockData.textMessage(user: MockData.agent),
        MockData.imageMessage(user: MockData.customer),
        MockData.emojiMessage(user: MockData.agent)
    ].groupMessages(interval: 120)
    let alertType: ChatAlertType? = nil

    return ChatView(
        messageGroups: .constant(messageGroups),
        hasMoreMessagesToLoad: .constant(true),
        typingAgent: .constant(MockData.agent),
        isUserTyping: .constant(false),
        isInputEnabled: .constant(true),
        isProcessDialogVisible: .constant(false),
        alertType: .constant(alertType),
        attachmentRestrictions: MockData.attachmentResrictions,
        queuePosition: 3,
        onNewMessage: { _, _ in },
        loadMoreMessages: { },
        onRichMessageElementSelected: { _, _ in }
    )
    .environmentObject(ChatLocalization())
    .environmentObject(ChatStyle())
}
