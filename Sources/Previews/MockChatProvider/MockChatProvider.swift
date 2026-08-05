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

// MARK: - MockChatProvider

/// An in-memory implementation of `ChatProvider` for use in SwiftUI previews.
///
/// Simulates the full chat lifecycle without a real SDK connection:
/// - Thread creation (with or without a prechat survey flow)
/// - Message sending (customer messages are shown immediately)
/// - Agent auto-responses (after a short delay, with a typing indicator)
///
/// Use ``emit(_:)`` to push arbitrary ``ChatEvent`` values from preview code.
@MainActor
final class MockChatProvider: ChatProvider {

    // MARK: - Properties

    static var logWriter: LogWriter?

    var state: ChatState
    var mode: ChatMode

    var connection: ConnectionProvider { mockConnection }
    var customer: CustomerProvider { mockCustomer }
    var customerCustomFields: CustomerCustomFieldsProvider { mockCustomerCustomFields }
    var threads: ChatThreadListProvider { mockThreads }
    var analytics: AnalyticsProvider { mockAnalytics }
    var proactiveAction: ProactiveActionProvider { mockProactiveAction }

    private let mockConnection: MockConnectionProvider
    private let mockCustomer = MockCustomerProvider()
    private let mockCustomerCustomFields = MockCustomerCustomFieldsProvider()
    private let mockThreads: MockChatThreadListProvider
    private let mockAnalytics = MockAnalyticsProvider()
    private let mockProactiveAction = MockProactiveActionProvider()

    private var eventContinuations: [String: AsyncStream<ChatEvent>.Continuation] = [:]
    private var emitEvent: @Sendable (ChatEvent) -> Void {
        { [weak self] event in
            MainActor.assumeIsolated { self?.emit(event) }
        }
    }

    static let mockAgent = Agent(
        id: 1,
        firstName: "Jane",
        surname: "Doe",
        nickname: "Support",
        isBotUser: false,
        isSurveyUser: false,
        imageUrl: ""
    )

    // MARK: - Init

    init(
        state: ChatState = .prepared,
        mode: ChatMode = .multithread,
        initialThreads: [CXoneChatSDK.ChatThread] = []
    ) {
        self.state = state
        self.mode = mode

        self.mockConnection = MockConnectionProvider(mode: mode)
        self.mockThreads = MockChatThreadListProvider()

        // Wire event emitter and state updater after all stored properties are initialized
        self.mockThreads.emitEvent = { [weak self] event in
            MainActor.assumeIsolated { self?.emit(event) }
        }
        self.mockConnection.emitEvent = { [weak self] event in
            MainActor.assumeIsolated { self?.emit(event) }
        }
        self.mockConnection.setState = { [weak self] newState in
            MainActor.assumeIsolated { self?.state = newState }
        }

        // Seed any pre-supplied threads so previews and snapshot tests can render
        // pre-populated conversations without going through the full create/send flow.
        seedInitialThreads(initialThreads)
    }

    // MARK: - ChatProvider

    func events() -> AsyncStream<ChatEvent> {
        let id = LowercaseUUID().uuidString
        let (stream, continuation) = AsyncStream<ChatEvent>.makeStream(bufferingPolicy: .bufferingNewest(64))
        eventContinuations[id] = continuation

        continuation.onTermination = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.eventContinuations.removeValue(forKey: id)
            }
        }

        return stream
    }

    func signOut() {
        LogManager.trace("[MOCK] Sign out")
    }
}

// MARK: - Private methods

private extension MockChatProvider {

    func emit(_ event: ChatEvent) {
        eventContinuations.values.forEach { $0.yield(event) }
    }

    func seedInitialThreads(_ threads: [CXoneChatSDK.ChatThread]) {
        let emit = self.emitEvent
        let sorted: @Sendable () -> [CXoneChatSDK.ChatThread] = { [weak self] in
            self?.mockThreads.get() ?? []
        }
        for thread in threads {
            let provider = MockChatThreadProvider(
                thread: thread,
                emitEvent: emit,
                sortedThreads: sorted
            )
            mockThreads.providers[thread.id] = provider
        }
    }
}

#if DEBUG
import SwiftUI

// MARK: - Previews

#Preview("Chat (Multithread)") {
    ChatContainerView(
        viewModel: ChatContainerViewModel(
            chatProvider: MockChatProvider(state: .prepared, mode: .multithread),
            chatConfiguration: ChatConfiguration(),
            presentModally: true
        )
    )
    .environmentObject(ChatStyle())
}

#Preview("Chat (Single Thread)") {
    ChatContainerView(
        viewModel: ChatContainerViewModel(
            chatProvider: MockChatProvider(state: .prepared, mode: .singlethread),
            chatConfiguration: ChatConfiguration(),
            presentModally: true
        )
    )
    .environmentObject(ChatStyle())
}

#Preview("Chat (Live Chat)") {
    ChatContainerView(
        viewModel: ChatContainerViewModel(
            chatProvider: MockChatProvider(state: .prepared, mode: .liveChat),
            chatConfiguration: ChatConfiguration(),
            presentModally: true
        )
    )
    .environmentObject(ChatStyle())
}

#endif
