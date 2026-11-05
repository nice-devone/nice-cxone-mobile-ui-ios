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
            attachments: $viewModel.attachments,
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
        .chatNavigationTitle(
            viewModel.thread?.titleForConversation ?? L10n.Common.unassignedAgent,
            isAiAssistant: viewModel.thread?.isAiAssistant == true
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

            if let name = viewModel.thread?.assignedAgent?.displayName {
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

// MARK: - Preview

#Preview {
    NavigationStack {
        ThreadView(viewModel: makeThreadViewPreviewModel())
    }
    .environmentObject(ChatStyle())
}

@MainActor
private func makeThreadViewPreviewModel() -> ThreadViewModel { // swiftlint:disable:this function_body_length
    let threadId = "preview-thread-001"
    let agent = MockChatProvider.mockAgent
    let customer = CustomerIdentity(id: "preview-customer", firstName: "Peter", lastName: "Parker")

    // Builds a deterministic SDK message; attachments drive the image/video/document/audio cells.
    func message(_ text: String, attachments: [Attachment] = [], fromAgent: Bool, secondsOffset: TimeInterval) -> Message {
        Message(
            id: LowercaseUUID().uuidString,
            threadId: threadId,
            contentType: .text(MessagePayload(text: text)),
            createdAt: MockData.fixedDate.addingTimeInterval(secondsOffset),
            attachments: attachments,
            direction: fromAgent ? .toClient : .toAgent,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: fromAgent ? agent : nil,
            authorEndUserIdentity: fromAgent ? nil : customer,
            status: .seen
        )
    }

    let messages: [Message] = [
        message("Hi! How can I help you today?", fromAgent: true, secondsOffset: 0),
        message("I'd like to share a few files. It's going to be a video, photo, audio, and a document.", fromAgent: false, secondsOffset: 60),
        message(
            "",
            attachments: [Attachment(url: MockData.imageUrl().absoluteString, friendlyName: "photo.jpg", mimeType: "image/jpeg", fileName: "photo.jpg")],
            fromAgent: false,
            secondsOffset: 120
        ),
        message(
            "",
            attachments: [
                Attachment(
                    url: MockData.videoUrl.absoluteString,
                    friendlyName: "Big Buck Bunny",
                    mimeType: "video/mp4",
                    fileName: MockData.videoUrl.lastPathComponent
                )
            ],
            fromAgent: false,
            secondsOffset: 180
        ),
        message(
            "",
            attachments: [
                Attachment(
                    url: MockData.pdfPreviewUrl.absoluteString,
                    friendlyName: "lorem-ipsum.pdf",
                    mimeType: "application/pdf",
                    fileName: "lorem-ipsum.pdf"
                )
            ],
            fromAgent: false,
            secondsOffset: 240
        ),
        message(
            "",
            attachments: [
                Attachment(
                    url: MockData.audioUrl.absoluteString,
                    friendlyName: "voice memo",
                    mimeType: "audio/mpeg",
                    fileName: "voice-memo.mp3"
                )
            ],
            fromAgent: false,
            secondsOffset: 300
        ),
        message("Got them — thanks!", fromAgent: true, secondsOffset: 360)
    ]

    let sdkThread = CXoneChatSDK.ChatThread(
        id: threadId,
        state: .ready,
        name: "Customer Support",
        messages: messages,
        assignedAgent: agent
    )

    // Mock provider — never connects to a real chat.
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

    return ThreadViewModel(thread: uiThread, containerViewModel: container)
}
