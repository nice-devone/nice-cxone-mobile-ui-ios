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

// MARK: - MockConnectionProvider

final class MockConnectionProvider: ConnectionProvider, @unchecked Sendable {

    // MARK: - Properties

    let channelConfiguration: ChannelConfiguration

    private let mode: ChatMode

    /// Set by `MockChatProvider` after init to broadcast events to all subscribers.
    var emitEvent: (@Sendable (ChatEvent) -> Void)?

    /// Set by `MockChatProvider` after init to keep `chatProvider.state` in sync with emitted events.
    var setState: (@Sendable (ChatState) -> Void)?

    // MARK: - Init

    init(mode: ChatMode) {
        self.mode = mode
        self.channelConfiguration = ChannelConfiguration(
            hasMultipleThreadsPerEndUser: mode == .multithread,
            isProactiveChatEnabled: false,
            isAuthorizationEnabled: false,
            isSendTranscriptEnabled: true,
            fileRestrictions: FileRestrictions(
                allowedFileSize: 40,
                allowedFileTypes: [
                    AllowedFileType(mimeType: "image/*", details: "Images"),
                    AllowedFileType(mimeType: "video/*", details: "Videos"),
                    AllowedFileType(mimeType: "audio/*", details: "Audio")
                ],
                isAttachmentsEnabled: true
            ),
            features: [:],
            isOnline: true,
            isLiveChat: mode == .liveChat,
            authenticationType: .anonymous
        )
    }

    // MARK: - Methods

    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("[MOCK] Get channel configuration (environment)")
        return channelConfiguration
    }

    func getChannelConfiguration(chatURL: String, brandId: Int, channelId: String) async throws -> ChannelConfiguration {
        LogManager.trace("[MOCK] Get channel configuration (chatURL)")
        return channelConfiguration
    }

    func prepare(environment: Environment, brandId: Int, channelId: String) async throws {
        LogManager.trace("[MOCK] Prepare (environment)")
    }

    func prepare( // swiftlint:disable:this function_parameter_count
        chatURL: String,
        socketURL: String,
        loggerURL: String,
        brandId: Int,
        channelId: String,
        tokenURL: String?
    ) async throws {
        LogManager.trace("[MOCK] Prepare (chatURL)")
    }

    /// Simulates the real SDK connection lifecycle:
    /// `.connecting` → `.connected` → `.ready`
    ///
    /// Each state transition hops to the main actor via `MainActor.run` so that the
    /// `setState` and `emitEvent` closures — which use `MainActor.assumeIsolated` — are
    /// always called on the correct executor, even after `Task.sleep` suspensions that
    /// may resume on a cooperative thread-pool thread.
    func connect() async throws {
        LogManager.trace("[MOCK] Connect")

        await MainActor.run { [setState, emitEvent, mode] in
            setState?(.connecting)
            emitEvent?(.chatUpdated(state: .connecting, mode: mode))
        }

        try? await Task.sleep(for: .seconds(0.5))

        await MainActor.run { [setState, emitEvent, mode] in
            setState?(.connected)
            emitEvent?(.chatUpdated(state: .connected, mode: mode))
        }

        try? await Task.sleep(for: .seconds(0.3))

        await MainActor.run { [setState, emitEvent, mode] in
            setState?(.ready)
            emitEvent?(.chatUpdated(state: .ready, mode: mode))
        }
    }

    func disconnect() {
        LogManager.trace("[MOCK] Disconnect")
    }

    func executeTrigger(_ triggerId: String) async throws {
        LogManager.trace("[MOCK] Execute trigger: \(triggerId)")
    }
}
