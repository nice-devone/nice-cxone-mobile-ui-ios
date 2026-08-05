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
            static let positionInQueueVertical: CGFloat = 32
            static let positionInQueueHorizontal: CGFloat = 16
            static let typingIndicatorLeading: CGFloat = 16
            static let archivedChatMessageDividerHorizontal: CGFloat = 24
            @MainActor
            static var archivedChatMessageBottom: CGFloat {
                UIDevice.hasHomeButton ? 10 : 0
            }
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle

    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @Binding private var hasMoreMessagesToLoad: Bool
    @Binding private var typingAgent: ChatUser?
    @Binding private var isUserTyping: Bool
    @Binding private var isInputEnabled: Bool
    @Binding private var isThreadClosed: Bool
    @Binding private var alertType: ChatAlertType?
    @Binding private var messageGroups: [MessageGroup]
    @Binding private var isSendingMessage: Bool

    private let attachmentRestrictions: AttachmentRestrictions
    private let isLiveChat: Bool
    private let onNewMessage: (ChatMessageType, [AttachmentItem]) -> Void
    private let loadMoreMessages: () async -> Void
    private let onRichMessageElementSelected: (RichMessageSubElementType) -> Void
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
        isSendingMessage: Binding<Bool>,
        isLiveChat: Bool,
        alertType: Binding<ChatAlertType?>,
        attachmentRestrictions: AttachmentRestrictions,
        queuePosition: Int? = nil,
        onNewMessage: @escaping (ChatMessageType, [AttachmentItem]) -> Void,
        loadMoreMessages: @escaping () async -> Void,
        onRichMessageElementSelected: @escaping (RichMessageSubElementType) -> Void
    ) {
        self._messageGroups = messageGroups
        self._hasMoreMessagesToLoad = hasMoreMessagesToLoad
        self._typingAgent = typingAgent
        self._isUserTyping = isUserTyping
        self._isInputEnabled = isInputEnabled
        self._isThreadClosed = isThreadClosed
        self._alertType = alertType
        self._isSendingMessage = isSendingMessage
        self.attachmentRestrictions = attachmentRestrictions
        self.isLiveChat = isLiveChat
        self.queuePosition = queuePosition
        self.onNewMessage = onNewMessage
        self.loadMoreMessages = loadMoreMessages
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: Constants.Spacing.bodyVertical) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        Section {
                            ForEach(messageGroups) { group in
                                MessageGroupView(
                                    group: group,
                                    isLast: messageGroups.last?.id == group.id,
                                    alertType: $alertType,
                                    onRichMessageElementSelected: onRichMessageElementSelected
                                )
                                .id(group.id)
                            }
                        } header: {
                            if let queuePosition {
                                LivechatPositionInQueueView(position: queuePosition)
                                    .padding(.vertical, Constants.Padding.positionInQueueVertical)
                                    .padding(.horizontal, Constants.Padding.positionInQueueHorizontal)
                            }
                        }
                    }
                    .onChange(of: messageGroups) { _ in
                        // On iOS 16, `.onChange` runs before the appended message has laid
                        // out, so a synchronous `scrollTo` targets the previous bottom.
                        // Schedule on a fresh MainActor turn so layout completes first. DE-175228.
                        Task { @MainActor in
                            withAnimation {
                                proxy.scrollTo(Constants.bottomID, anchor: .bottom)
                            }
                        }
                    }
                    .task { @MainActor in
                        proxy.scrollTo(messageGroups.last?.id, anchor: .bottom)
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
                .scrollDismissesKeyboard(.interactively)
            }

            if isThreadClosed {
                archivedChatMessage
                    .padding(.bottom, Constants.Padding.archivedChatMessageBottom)
            } else {
                MessageInputView(
                    attachmentRestrictions: attachmentRestrictions,
                    isEditing: $isUserTyping,
                    isInputEnabled: $isInputEnabled,
                    isSendingMessage: $isSendingMessage,
                    alertType: $alertType,
                    onSend: onNewMessage
                )
            }
        }
        .background(colors.background.default)
        .onChange(of: typingAgent?.id) { newValue in
            guard newValue != nil else {
                return
            }

            if let name = typingAgent?.userName {
                A11y.announce(A11y.Announcement.Conversation.TypingIndicator.started(name))
            } else {
                A11y.announce(A11y.Announcement.Conversation.TypingIndicator.Started.unknown)
            }
        }
    }
}

// MARK: - Subviews

private extension ChatView {

    func typingIndicator(agent: ChatUser?, proxy: ScrollViewProxy) -> some View {
        HStack {
            TypingIndicator(agent: agent)
                .onAppear {
                    // Same iOS 16 timing quirk as the `.onChange` above: `.onAppear` runs
                    // before the newly inserted indicator has laid out, so a synchronous
                    // `scrollTo` targets the previous bottom. DE-175228.
                    Task { @MainActor in
                        withAnimation {
                            proxy.scrollTo(Constants.bottomID)
                        }
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
                    isLiveChat
                        ? L10n.Chat.MessageInput.closed
                        : L10n.Chat.MessageInput.archived
                )
            }
            .foregroundStyle(colors.content.tertiary)
        }
        .background(colors.background.default)
    }
}

// MARK: - Previews

#Preview {
    let messageGroups = [
        MockData.textMessage(user: MockData.agent),
        MockData.imageMessage(user: MockData.customer),
        MockData.emojiMessage(user: MockData.agent)
    ].groupMessages(interval: MessageGroup.defaultGroupingInterval)
    let alertType: ChatAlertType? = nil

    NavigationStack {
        ChatView(
            messageGroups: .constant(messageGroups),
            hasMoreMessagesToLoad: .constant(true),
            typingAgent: .constant(MockData.agent),
            isUserTyping: .constant(false),
            isInputEnabled: .constant(true),
            isThreadClosed: .constant(false),
            isSendingMessage: .constant(false),
            isLiveChat: false,
            alertType: .constant(alertType),
            attachmentRestrictions: MockData.attachmentRestrictions,
            queuePosition: 3,
            onNewMessage: { _, _ in },
            loadMoreMessages: { },
            onRichMessageElementSelected: { _ in }
        )
    }
    .environmentObject(ChatStyle())
}
