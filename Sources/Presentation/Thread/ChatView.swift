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

    // MARK: - Constants
    
    private enum Constants {
        
        static let bottomID = "bottom"
        
        enum Spacing {
            static let bodyVertical: CGFloat = 0
            static let messageGroupsMinLength: CGFloat = 16
            static let archivedChatMessage: CGFloat = 10
            static let archivedChatElementsVertical: CGFloat = 2
        }
        
        enum Padding {
            static let positionInQueueTop: CGFloat = 32
            static let positionInQueueHorizontal: CGFloat = 16
            static let positionInQueueBottom: CGFloat = 24
            static let typingIndicatorLeading: CGFloat = 16
            static let archivedChatMessageDividerHorizontal: CGFloat = 24
            static var archivedChatMessageBottom: CGFloat {
                UIDevice.hasHomeButton ? 10 : 0
            }
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @EnvironmentObject private var localization: ChatLocalization

    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @Binding private var hasMoreMessagesToLoad: Bool
    @Binding private var typingAgent: ChatUser?
    @Binding private var isUserTyping: Bool
    @Binding private var isInputEnabled: Bool
    @Binding private var isThreadClosed: Bool
    @Binding private var alertType: ChatAlertType?
    @Binding private var messageGroups: [MessageGroup]

    private let attachmentRestrictions: AttachmentRestrictions
    private let onNewMessage: (ChatMessageType, [AttachmentItem]) -> Void
    private let loadMoreMessages: () async -> Void
    private let onRichMessageElementSelected: (_ textToSend: String?, RichMessageSubElementType) -> Void
    private let queuePosition: Int?
    
    static let packageIdentifier = "CXoneChatUI"
    
    // MARK: - Init

    init(
        messageGroups: Binding<[MessageGroup]>,
        hasMoreMessagesToLoad: Binding<Bool>,
        typingAgent: Binding<ChatUser?>,
        isUserTyping: Binding<Bool>,
        isInputEnabled: Binding<Bool>,
        isThreadClosed: Binding<Bool>,
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
        self._isThreadClosed = isThreadClosed
        self._alertType = alertType
        self.attachmentRestrictions = attachmentRestrictions
        self.queuePosition = queuePosition
        self.onNewMessage = onNewMessage
        self.loadMoreMessages = loadMoreMessages
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: Constants.Spacing.bodyVertical) {
            if let queuePosition {
                LivechatPositionInQueueView(position: queuePosition)
                    .padding(.top, Constants.Padding.positionInQueueTop)
                    .padding(.horizontal, Constants.Padding.positionInQueueHorizontal)
                    .padding(.bottom, Constants.Padding.positionInQueueBottom)
            }
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        Spacer(minLength: Constants.Spacing.messageGroupsMinLength)
                        
                        ForEach(messageGroups) { group in
                            MessageGroupView(
                                group: group,
                                isLast: messageGroups.last?.id == group.id,
                                alertType: $alertType,
                                onRichMessageElementSelected: onRichMessageElementSelected
                            )
                            .id(group.id)
                        }
                    }
                    .onChange(of: messageGroups) { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo(Constants.bottomID, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            proxy.scrollTo(messageGroups.last?.id, anchor: .bottom)
                        }
                    }

                    if let typingAgent {
                        typingIndicator(agent: typingAgent, proxy: proxy)
                            .padding(.leading, Constants.Padding.typingIndicatorLeading)
                    }
                    
                    Spacer(minLength: Constants.Spacing.messageGroupsMinLength)
                        .id(Constants.bottomID)
                }
                .if(hasMoreMessagesToLoad) { view in
                    view.refreshable {
                        await loadMoreMessages()
                    }
                }
            }

            if isThreadClosed {
                archivedChatMessage
                    .padding(.bottom, Constants.Padding.archivedChatMessageBottom)
            } else {
                MessageInputView(
                    attachmentRestrictions: attachmentRestrictions,
                    isEditing: $isUserTyping,
                    isInputEnabled: $isInputEnabled,
                    alertType: $alertType,
                    localization: localization,
                    onSend: onNewMessage
                )
            }
        }
        .background(colors.background.default)
    }
}

// MARK: - Subviews

private extension ChatView {

    func typingIndicator(agent: ChatUser?, proxy: ScrollViewProxy) -> some View {
        HStack {
            TypingIndicator(agent: agent)
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(Constants.bottomID)
                    }
                }

            Spacer()
        }
    }
    
    var archivedChatMessage: some View {
        VStack(spacing: Constants.Spacing.archivedChatMessage) {
            ColoredDivider(colors.border.default)
                .padding(.horizontal, Constants.Padding.archivedChatMessageDividerHorizontal)
            
            HStack(spacing: Constants.Spacing.archivedChatElementsVertical) {
                Asset.Message.archiveFill
                
                Text(
                    CXoneChat.shared.mode == .liveChat
                        ? localization.chatMessageInputClosed
                        : localization.chatMessageInputArchived
                )
            }
            .foregroundStyle(colors.content.tertiary)
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
        isThreadClosed: .constant(false),
        alertType: .constant(alertType),
        attachmentRestrictions: MockData.attachmentRestrictions,
        queuePosition: 3,
        onNewMessage: { _, _ in },
        loadMoreMessages: { },
        onRichMessageElementSelected: { _, _ in }
    )
    .environmentObject(ChatLocalization())
    .environmentObject(ChatStyle())
}
