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

import CXoneChatSDK
import SwiftUI

struct ThreadView: View, Themed {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @SwiftUI.Environment(\.colorScheme) var scheme: ColorScheme

    @ObservedObject private var viewModel: ThreadViewModel

    // MARK: - Init

    init(viewModel: ThreadViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Builder

    var body: some View {
        ChatView(
            messageGroups: $viewModel.messageGroups,
            hasMoreMessagesToLoad: $viewModel.hasMoreMessagesToLoad,
            typingAgent: $viewModel.typingAgent,
            isUserTyping: $viewModel.isUserTyping,
            isInputEnabled: $viewModel.isInputEnabled,
            isThreadClosed: $viewModel.isThreadClosed,
            isSendingMessage: $viewModel.isSendingMessage,
            isLiveChat: viewModel.isLiveChat,
            alertType: $viewModel.alertType,
            attachmentRestrictions: viewModel.attachmentRestrictions,
            queuePosition: viewModel.positionInQueue,
            onNewMessage: { messageType, attachments in
                viewModel.onSendMessage(messageType, attachments: attachments)
            },
            loadMoreMessages: viewModel.loadMoreMessages,
            onRichMessageElementSelected: viewModel.onRichMessageElementSelected
        )
        .background(colors.background.default)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .modifier(
            ChatNavigationTitle(
                title: viewModel.thread?.titleForConversation ?? L10n.Common.unassignedAgent,
                isAiAssistant: viewModel.thread?.isAiAssistant == true
            )
        )
        .chatToolbarBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                viewModel.menu.build(colors: colors)
            }
        }
        .alert(L10n.Alert.UpdateThreadName.title, isPresented: $viewModel.isEditingThreadName) {
            TextField(L10n.Alert.UpdateThreadName.placeholder, text: $viewModel.threadName)
                .accessibilityIdentifier(A11y.Alert.UpdateThreadName.identifier)

            VStack {
                Button(L10n.Common.cancel, role: .cancel) {
                    viewModel.isEditingThreadName = false
                }
                
                Button(L10n.Common.confirm) {
                    Task {
                        await viewModel.setThread(name: viewModel.threadName)
                    }
                }
            }
        }
        .onChange(of: viewModel.isUserTyping) { _ in
            viewModel.onUserTyping()
        }
        .onChange(of: scheme) { _ in
            NotificationCenter.default.post(name: .colorSchemeChanged, object: nil)
        }
        .onChange(of: viewModel.thread?.assignedAgent?.id) { newValue in
            guard newValue != nil else {
                return
            }

            if let name = viewModel.thread?.assignedAgent?.fullName {
                A11y.announce(A11y.Announcement.AgentAssignment.assigned(name))
            } else {
                A11y.announce(A11y.Announcement.AgentAssignment.Assigned.unknown)
            }
        }
    }
}

// MARK: - Helpers

extension Notification.Name {

    static let colorSchemeChanged = Notification.Name("colorSchemeChanged")
}

#Preview {
    let threadId = "preview-thread"
    let agent = MockChatProvider.mockAgent
    let messages: [Message] = [
        Message(
            id: "1",
            threadId: threadId,
            contentType: .text(MessagePayload(text: "Hello, how can I help you today?", postback: nil)),
            createdAt: MockData.fixedDate,
            attachments: [],
            direction: .toClient,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: agent,
            authorEndUserIdentity: nil,
            status: .seen,
            isAiGenerated: true
        ),
        Message(
            id: "2",
            threadId: threadId,
            contentType: .text(MessagePayload(text: "I have a question about my order.", postback: nil)),
            createdAt: MockData.fixedDate.addingTimeInterval(60),
            attachments: [],
            direction: .toAgent,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentity(id: "customer-1", firstName: "Peter", lastName: "Parker"),
            status: .seen
        ),
        Message(
            id: "3",
            threadId: threadId,
            contentType: .text(MessagePayload(text: "Of course — please share your order number.", postback: nil)),
            createdAt: MockData.fixedDate.addingTimeInterval(120),
            attachments: [],
            direction: .toClient,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: agent,
            authorEndUserIdentity: nil,
            status: .seen,
            isAiGenerated: true
        )
    ]

    let sdkThread = CXoneChatSDK.ChatThread(
        id: threadId,
        state: .ready,
        name: "Customer Support",
        messages: messages,
        assignedAgent: agent,
        ownerAssignee: nil
    )

    let viewModel: ThreadViewModel = {
        let container = ChatContainerViewModel(
            chatProvider: MockChatProvider(initialThreads: [sdkThread]),
            chatConfiguration: ChatConfiguration(),
            presentModally: false
        )
        let uiThread = CXoneChatUI.ChatThread(
            id: threadId,
            name: "Customer Support",
            messages: messages,
            assignedAgent: agent,
            lastAssignedAgent: nil,
            ownerAssignee: nil,
            scrollToken: "",
            state: .ready,
            positionInQueue: nil
        )
        let viewModel = ThreadViewModel(thread: uiThread, containerViewModel: container)
        viewModel.messageGroups = messages
            .map(ChatMessageMapper.map)
            .groupMessages(interval: MessageGroup.defaultGroupingInterval)
        viewModel.isInputEnabled = true

        return viewModel
    }()

    return NavigationStack {
        ThreadView(viewModel: viewModel)
    }
    .environmentObject(ChatStyle())
}
