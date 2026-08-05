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

// MARK: - MockChatThreadListProvider

final class MockChatThreadListProvider: ChatThreadListProvider, @unchecked Sendable {

    // MARK: - Properties

    let preChatSurvey: PreChatSurvey? = nil

    var customFields: ContactCustomFieldsProvider { mockContactCustomFields }

    /// Live thread store — keyed by thread ID. Each value is the owning provider,
    /// so `get()` always reflects the latest thread state without a separate snapshot copy.
    var providers: [String: MockChatThreadProvider] = [:]

    /// Set by `MockChatProvider` after init to broadcast events to all subscribers.
    var emitEvent: (@Sendable (ChatEvent) -> Void)?

    private let mockContactCustomFields = MockContactCustomFieldsProvider()

    // MARK: - Methods

    func get() -> [CXoneChatSDK.ChatThread] {
        providers.values
            .map { $0.chatThread }
            .sorted { lhs, rhs in
                let lDate = lhs.messages.last?.createdAt ?? Date.distantPast
                let rDate = rhs.messages.last?.createdAt ?? Date.distantPast
                return lDate > rDate
            }
    }

    func create() async throws -> any ChatThreadProvider {
        let threadId = LowercaseUUID().uuidString
        let thread = CXoneChatSDK.ChatThread(
            id: threadId,
            state: .ready,
            name: "Chat \(providers.count + 1)",
            assignedAgent: await MockChatProvider.mockAgent
        )

        let provider = MockChatThreadProvider(
            thread: thread,
            emitEvent: emitEvent ?? { _ in }
        ) { [weak self] in
            self?.get() ?? []
        }

        await MainActor.run { [weak self] in
            guard let self else {
                return
            }
            self.providers[threadId] = provider
            self.emitEvent?(.threadsUpdated(self.get()))
        }

        return provider
    }

    func create(with customFields: [String: String]) async throws -> any ChatThreadProvider {
        try await create()
    }

    func load(with id: String?) async throws {
        LogManager.trace("[MOCK] Load threads")
        await MainActor.run {
            emitEvent?(.threadsUpdated(get()))
        }
    }

    func provider(for threadId: String) throws -> any ChatThreadProvider {
        guard let provider = providers[threadId] else {
            fatalError("Thread '\(threadId)' not found in mock store")
        }
        return provider
    }

    func provider(for thread: CXoneChatSDK.ChatThread) throws -> any ChatThreadProvider {
        try provider(for: thread.id)
    }
}
