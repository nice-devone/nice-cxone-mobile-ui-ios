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
import CXoneGuideUtility
import Foundation

// MARK: - MockChatThreadProvider

final class MockChatThreadProvider: ChatThreadProvider, @unchecked Sendable {

    // MARK: - Properties

    private(set) var chatThread: CXoneChatSDK.ChatThread

    private let emitEvent: @Sendable (ChatEvent) -> Void
    private let sortedThreads: @Sendable () -> [CXoneChatSDK.ChatThread]

    // MARK: - Init

    init(
        thread: CXoneChatSDK.ChatThread,
        emitEvent: @escaping @Sendable (ChatEvent) -> Void,
        sortedThreads: @escaping @Sendable () -> [CXoneChatSDK.ChatThread]
    ) {
        self.chatThread = thread
        self.emitEvent = emitEvent
        self.sortedThreads = sortedThreads
    }

    // MARK: - Methods

    func loadMoreMessages() async throws {
        LogManager.trace("[MOCK] Load more messages")
    }

    func send(_ message: OutboundMessage) async throws {
        let customerMessage = Message(
            id: LowercaseUUID().uuidString,
            threadId: chatThread.id,
            contentType: .text(MessagePayload(text: message.text)),
            createdAt: Date(),
            attachments: message.attachments.map(Attachment.init),
            direction: .toAgent,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: nil,
            authorEndUserIdentity: CustomerIdentity(id: "mock-customer", firstName: "You", lastName: nil),
            status: .sent
        )

        let updatedThread = CXoneChatSDK.ChatThread(
            id: chatThread.id,
            state: chatThread.state,
            name: chatThread.name,
            messages: chatThread.messages + [customerMessage],
            assignedAgent: chatThread.assignedAgent,
            lastAssignedAgent: chatThread.lastAssignedAgent,
            ownerAssignee: chatThread.ownerAssignee,
            scrollToken: chatThread.scrollToken,
            positionInQueue: chatThread.positionInQueue
        )

        chatThread = updatedThread

        await MainActor.run {
            emitEvent(.threadUpdated(updatedThread))
            emitEvent(.threadsUpdated(sortedThreads()))
        }

        Task { @MainActor [weak self] in
            await self?.scheduleAgentResponse(customerMessageId: customerMessage.id)
        }
    }

    func updateName(_ name: String) async throws {
        let renamed = CXoneChatSDK.ChatThread(
            id: chatThread.id,
            state: chatThread.state,
            name: name,
            messages: chatThread.messages,
            assignedAgent: chatThread.assignedAgent,
            lastAssignedAgent: chatThread.lastAssignedAgent,
            ownerAssignee: chatThread.ownerAssignee,
            scrollToken: chatThread.scrollToken,
            positionInQueue: chatThread.positionInQueue
        )

        chatThread = renamed

        await MainActor.run {
            emitEvent(.threadUpdated(renamed))
            emitEvent(.threadsUpdated(sortedThreads()))
        }
    }

    func archive() async throws {
        let archived = CXoneChatSDK.ChatThread(
            id: chatThread.id,
            state: .closed,
            name: chatThread.name,
            messages: chatThread.messages,
            assignedAgent: chatThread.assignedAgent,
            lastAssignedAgent: chatThread.lastAssignedAgent,
            ownerAssignee: chatThread.ownerAssignee,
            scrollToken: chatThread.scrollToken,
            positionInQueue: chatThread.positionInQueue
        )

        chatThread = archived

        await MainActor.run {
            emitEvent(.threadUpdated(archived))
            emitEvent(.threadsUpdated(sortedThreads()))
        }
    }

    func markRead() async throws {
        LogManager.trace("[MOCK] Thread marked as read")
    }

    func endContact() async throws {
        let closed = CXoneChatSDK.ChatThread(
            id: chatThread.id,
            state: .closed,
            name: chatThread.name,
            messages: chatThread.messages,
            assignedAgent: chatThread.assignedAgent,
            lastAssignedAgent: chatThread.lastAssignedAgent,
            ownerAssignee: chatThread.ownerAssignee,
            scrollToken: chatThread.scrollToken,
            positionInQueue: chatThread.positionInQueue
        )

        chatThread = closed

        await MainActor.run {
            emitEvent(.threadUpdated(closed))
            emitEvent(.threadsUpdated(sortedThreads()))
        }
    }

    func reportTypingStart(_ didStart: Bool) async throws {
        LogManager.trace("[MOCK] Report typing: \(didStart)")
    }

    func sendTranscript(to email: String) async throws {
        LogManager.trace("[MOCK] Send transcript to: \(email)")
    }
}

// MARK: - Agent response simulation

private extension MockChatThreadProvider {

    /// Simulates the full agent lifecycle for a sent customer message:
    /// sent → delivered → seen → typing → agent reply.
    @MainActor
    func scheduleAgentResponse(customerMessageId: String) async {
        try? await Task.sleep(for: .seconds(0.5))
        updateMessageStatus(id: customerMessageId, to: .delivered)

        try? await Task.sleep(for: .seconds(0.5))
        updateMessageStatus(id: customerMessageId, to: .seen)

        try? await Task.sleep(for: .seconds(1.5))
        emitEvent(.agentTyping(isTyping: true, agent: MockChatProvider.mockAgent, threadId: chatThread.id))

        try? await Task.sleep(for: .seconds(2.0))

        let agentMessage = randomAgentMessage(threadId: chatThread.id)
        let updatedThread = CXoneChatSDK.ChatThread(
            id: chatThread.id,
            state: chatThread.state,
            name: chatThread.name,
            messages: chatThread.messages + [agentMessage],
            assignedAgent: chatThread.assignedAgent ?? MockChatProvider.mockAgent,
            lastAssignedAgent: chatThread.lastAssignedAgent,
            ownerAssignee: chatThread.ownerAssignee,
            scrollToken: chatThread.scrollToken,
            positionInQueue: chatThread.positionInQueue
        )

        chatThread = updatedThread
        emitEvent(.agentTyping(isTyping: false, agent: MockChatProvider.mockAgent, threadId: updatedThread.id))
        emitEvent(.threadUpdated(updatedThread))
        emitEvent(.threadsUpdated(sortedThreads()))
    }

    /// Replaces the status of the message with the given ID and emits a thread update.
    @MainActor
    func updateMessageStatus(id: String, to status: MessageStatus) {
        let updatedMessages = chatThread.messages.map { $0.id == id ? $0.with(status: status) : $0 }
        let updatedThread = CXoneChatSDK.ChatThread(
            id: chatThread.id,
            state: chatThread.state,
            name: chatThread.name,
            messages: updatedMessages,
            assignedAgent: chatThread.assignedAgent,
            lastAssignedAgent: chatThread.lastAssignedAgent,
            ownerAssignee: chatThread.ownerAssignee,
            scrollToken: chatThread.scrollToken,
            positionInQueue: chatThread.positionInQueue
        )

        chatThread = updatedThread
        emitEvent(.threadUpdated(updatedThread))
        emitEvent(.threadsUpdated(sortedThreads()))
    }

    @MainActor
    func randomAgentMessage(threadId: String) -> Message {
        enum ResponseType: CaseIterable {
            case text, textWithAttachments, richLink, quickReplies, listPicker, timePicker
        }

        let responseType = ResponseType.allCases.randomElement() ?? .text
        let result: (type: MessageContentType, attachments: [Attachment]) = switch responseType {
        case .text:
            (.text(MessagePayload(text: Lorem.sentence())), [])
        case .textWithAttachments:
            (.text(MessagePayload(text: Lorem.sentence())), randomAttachments())
        case .richLink:
            (.richLink(mockRichLink()), [])
        case .quickReplies:
            (.quickReplies(mockQuickReplies()), [])
        case .listPicker:
            (.listPicker(mockListPicker()), [])
        case .timePicker:
            (.timePicker(mockTimePicker()), [])
        }

        return Message(
            id: LowercaseUUID().uuidString,
            threadId: threadId,
            contentType: result.type,
            createdAt: Date(),
            attachments: result.attachments,
            direction: .toClient,
            agentStatistics: nil,
            customerStatistics: nil,
            authorUser: MockChatProvider.mockAgent,
            authorEndUserIdentity: nil,
            status: .sent
        )
    }

    func randomAttachments() -> [Attachment] {
        let pool: [Attachment] = [
            Attachment(url: MockData.imageUrl().absoluteString, friendlyName: "photo.jpg", mimeType: "image/jpeg", fileName: "photo.jpg"),
            Attachment(url: MockData.imageUrl().absoluteString, friendlyName: "photo2.jpg", mimeType: "image/jpeg", fileName: "photo2.jpg"),
            Attachment(url: MockData.videoUrl.absoluteString, friendlyName: "ForBiggerEscapes.mp4", mimeType: "video/mp4", fileName: "ForBiggerEscapes.mp4"),
            Attachment(
                url: MockData.audioUrl.absoluteString,
                friendlyName: "file_example_MP3_700KB",
                mimeType: "audio/mpeg",
                fileName: "file_example_MP3_700KB.mp3"
            ),
            Attachment(url: MockData.pdfPreviewUrl.absoluteString, friendlyName: "sample PDF", mimeType: "application/pdf", fileName: "lorem-ipsum.pdf")
        ]
        return Array(pool.shuffled().prefix(Int.random(in: 1...3)))
    }

    func mockRichLink() -> MessageRichLink {
        let imageUrl = MockData.imageUrl()
        
        return MessageRichLink(
            title: Lorem.words(),
            url: imageUrl,
            fileName: imageUrl.lastPathComponent,
            fileUrl: imageUrl,
            mimeType: "image/jpeg"
        )
    }

    func mockQuickReplies() -> MessageQuickReplies {
        MessageQuickReplies(
            title: Lorem.sentence(),
            buttons: (0..<Int.random(in: 2...4)).map { _ in
                MessageReplyButton(
                    text: Lorem.words(nbWords: Int.random(in: 1...2)),
                    iconUrl: Bool.random() ? MockData.imageUrl() : nil,
                    iconMimeType: Bool.random() ? "image/jpeg" : nil
                )
            }
        )
    }

    func mockListPicker() -> MessageListPicker {
        MessageListPicker(
            title: Lorem.words(),
            text: Lorem.sentence(),
            buttons: (0..<Int.random(in: 2...4)).map { _ in
                .replyButton(MessageReplyButton(
                    text: Lorem.words(nbWords: Int.random(in: 1...2)),
                    description: Bool.random() ? Lorem.sentence() : nil,
                    iconUrl: Bool.random() ? MockData.imageUrl() : nil,
                    iconMimeType: Bool.random() ? "image/jpeg" : nil
                ))
            }
        )
    }

    func mockTimePicker() -> MessageTimePicker {
        let now = Date()
        let calendar = Calendar.current
        return MessageTimePicker(
            title: Lorem.words(),
            sheetTitle: Lorem.words(),
            timeSlots: (0..<Int.random(in: 3...6)).map { offset in
                MessageTimePickerTimeSlot(
                    id: LowercaseUUID().uuidString,
                    duration: [1800, 2700, 3600, 5400].randomElement() ?? 1800,
                    startTime: calendar.date(byAdding: .hour, value: offset * 2, to: now) ?? now
                )
            }
        )
    }
}

// MARK: - Attachment + ContentDescriptor

private extension Attachment {

    /// Creates a mock `Attachment` from an outbound `ContentDescriptor`.
    /// For `.url` sources the original URL is preserved; for `.bytes` sources a placeholder is used
    /// since no real upload occurs in the mock.
    init(_ descriptor: ContentDescriptor) {
        let url: String
        if case .url(let fileURL) = descriptor.data {
            url = fileURL.absoluteString
        } else {
            url = ""
        }

        self.init(
            url: url,
            friendlyName: descriptor.friendlyName,
            mimeType: descriptor.mimeType,
            fileName: descriptor.fileName
        )
    }
}

// MARK: - Message + status copy

private extension Message {

    func with(status: MessageStatus) -> Message {
        Message(
            id: id,
            threadId: threadId,
            contentType: contentType,
            createdAt: createdAt,
            attachments: attachments,
            direction: direction,
            agentStatistics: agentStatistics,
            customerStatistics: customerStatistics,
            authorUser: authorUser,
            authorEndUserIdentity: authorEndUserIdentity,
            status: status
        )
    }
}
