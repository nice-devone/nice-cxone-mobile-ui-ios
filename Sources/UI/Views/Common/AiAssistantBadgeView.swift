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

/// The "AI Assistant" pill that indicates the conversation is currently handled by an AI agent.
///
/// ``ChatNavigationTitle`` places it as the navigation subtitle on iOS 26+ (`.largeSubtitle` / `.subtitle`) or
/// inside the principal toolbar item on earlier versions.
struct AiAssistantBadgeView: View, Themed {

    // MARK: - Constants

    private enum Constants {
        enum Sizing {
            static let cornerRadius: CGFloat = 4
        }
        enum Padding {
            static let horizontal: CGFloat = 8
            static let vertical: CGFloat = 4
        }
    }

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @SwiftUI.Environment(\.colorScheme) var scheme: ColorScheme

    // MARK: - Builder

    var body: some View {
        Text(L10n.Common.aiAssistant)
            .font(.footnote)
            .foregroundStyle(colors.brand.onPrimary)
            .padding(.horizontal, Constants.Padding.horizontal)
            .padding(.vertical, Constants.Padding.vertical)
            .background(
                RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                    .fill(colors.brand.primary)
            )
            .accessibilityHint(A11y.Conversation.AiAssistantBadge.hint)
            .accessibilityIdentifier(A11y.Conversation.AiAssistantBadge.identifier)
    }
}

// MARK: - Preview

#Preview("ThreadView - AI Assistant") {
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

#Preview("ThreadView - AI handoff after 2s") {
    AiHandoffPreviewHost(viewModel: AiHandoffPreviewHost.makeNonAiViewModel())
        .environmentObject(ChatStyle())
}

/// Preview host that starts as a non-AI conversation (large title, no badge) and, after a 2 second delay,
/// appends an AI-generated agent message to the thread — flipping `isAiAssistant` to `true` so the navigation
/// title collapses to inline and the "AI Assistant" pill animates in.
private struct AiHandoffPreviewHost: View {

    @ObservedObject var viewModel: ThreadViewModel

    private static let threadId = "preview-thread-handoff"

    var body: some View {
        NavigationStack {
            ThreadView(viewModel: viewModel)
        }
        .task {
            await Task.sleep(seconds: 2)
            
            appendAiAgentMessage()
        }
    }

    @MainActor
    static func makeNonAiViewModel() -> ThreadViewModel { // swiftlint:disable:this function_body_length
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
                status: .seen
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
    }

    @MainActor
    private func appendAiAgentMessage() {
        guard let current = viewModel.thread else {
            return
        }

        let aiMessage = Message(
            id: "ai-message",
            threadId: current.id,
            contentType: .text(MessagePayload(text: "Hi! I'm an AI assistant. How can I help?", postback: nil)),
            createdAt: MockData.fixedDate.addingTimeInterval(Double(current.messages.count + 1) * 60),
            attachments: [],
            direction: .toClient,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: current.assignedAgent,
            authorEndUserIdentity: nil,
            status: .seen,
            isAiGenerated: true
        )
        let updatedMessages = current.messages + [aiMessage]
        let updatedThread = CXoneChatUI.ChatThread(
            id: current.id,
            name: current.name,
            messages: updatedMessages,
            assignedAgent: current.assignedAgent,
            lastAssignedAgent: current.lastAssignedAgent,
            ownerAssignee: nil,
            scrollToken: current.scrollToken,
            state: current.state,
            positionInQueue: current.positionInQueue
        )

        withAnimation {
            viewModel.thread = updatedThread
            viewModel.messageGroups = updatedMessages
                .map(ChatMessageMapper.map)
                .groupMessages(interval: MessageGroup.defaultGroupingInterval)
        }
    }
}
