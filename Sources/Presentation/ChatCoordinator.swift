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
import UIKit

/// Class responsible for coordinating and managing chat related views navigation
///
/// This class is designed to simplify the management of chat related views navigation,
/// such as thread list, form or transcript, allowing you to initialize and present chat interfaces with customizable visual styles,
/// specify threads to open, and present dynamic forms. 
/// It offers flexibility in creating and managing chat-related content within your application.
@MainActor
open class ChatCoordinator {

    // MARK: - Properties

    /// The CXoneChat instance that provides chat services.
    public let chatProvider: ChatProvider
    /// The visual style configuration for the chat interface.
    public var chatStyle: ChatStyle
    /// The localization configuration for the chat interface.
    public var chatLocalization: ChatLocalization
    /// The additional configuration for the chat interface (additional fields, flags etc.).
    public var chatConfiguration: ChatConfiguration
    /// The accessibility strings configuration for the chat interface.
    ///
    /// Use this to override the SDK's built-in accessibility strings or provide full localization
    /// in additional languages. See ``ChatAccessibility`` for usage details.
    public var chatAccessibility: ChatAccessibility
    /// Indicates whether the chat is currently active (i.e., a chat session is ongoing).
    public private(set) var isActive = false
    /// A closure that is executed when an explicit-PKCE session's refresh-grant recovery fails
    /// during connect and no further automatic recovery is possible — the host app must start a new
    /// authorization flow. Called instead of showing the generic connection-error alert.
    ///
    /// - Note: This callback covers connect-time failures only. A refresh-grant rejection during
    ///   a message send surfaces as a regular send error, not through this handler.
    ///
    /// Set this before calling ``content(threadId:presentModally:onFinish:)``.
    public var onSessionExpired: (() -> Void)?

    // MARK: - Init

    /// Initializes a new instance of `ChatCoordinator`.
    ///
    /// - Parameters:
    ///   - chatProvider: The `ChatProvider` instance (typically `CXoneChat`) that manages the chat session.
    ///   - chatStyle: An instance of ``ChatStyle`` that defines the visual style and appearance settings for a chat interface.
    ///   - chatLocalization: An instance of ``ChatLocalization`` to handle language and locale-specific text and behavior.
    ///   - chatConfiguration: An instance of ``ChatConfiguration`` to handle additional configuration parameters
    ///     that are passed to the UI module wrapping the SDK.
    ///   - chatAccessibility: An instance of ``ChatAccessibility`` to override built-in accessibility strings.
    public init(
        chatProvider: ChatProvider,
        chatStyle: ChatStyle = ChatStyle(),
        chatLocalization: ChatLocalization = ChatLocalization(),
        chatConfiguration: ChatConfiguration = ChatConfiguration(),
        chatAccessibility: ChatAccessibility = ChatAccessibility()
    ) {
        self.chatProvider = chatProvider
        self.chatStyle = chatStyle
        self.chatLocalization = chatLocalization
        self.chatConfiguration = chatConfiguration
        self.chatAccessibility = chatAccessibility
    }

    // MARK: - Methods
    
    /// Provides the SwiftUI view content for the chat interface.
    ///
    /// This method generates a chat container view that handles  the entire chat experience.
    /// The method allows to provide a `threadId` to open an existing chat thread.
    /// This feature is used for deep linking into specific chat threads
    /// within a multi-threaded channel configuration to resume previous conversations.
    /// A closure, `onFinish`, is provided to handle the
    /// dismissal or any cleanup when the chat session finishes.
    ///
    /// - Note: The `threadId` parameter does not have any effect if the channel configuration is set to single-threaded or live chat
    /// because there is always a single conversation so it's not necessary to handle the `threadId`.
    ///
    /// - Parameters:
    ///   - threadId: The unique identifier for the chat thread to be opened (deeplinking). If `nil`,
    ///     the SDK tries to refresh existing conversation(s) or creates a new one for single-thread and live chat configurations.
    ///   - presentModally: The flag if the content view is going to be presented modally or in full-screen.
    ///   - onFinish: A closure that is executed when the chat session finishes or is dismissed.
    ///
    /// - Returns: A `View` representing the chat UI to be displayed.
    ///
    /// This view is may be used within a `UIHostingController` for integration into a UIKit-based app.
    ///
    /// - SeeAlso: ``onSessionExpired`` for handling an unrecoverable explicit-PKCE session.
    public func content(
        threadId: String? = nil,
        presentModally: Bool,
        onFinish: (() -> Void)? = nil
    ) -> some View {
        isActive = true

        let viewModel = ChatContainerViewModel(
            chatProvider: chatProvider,
            threadToOpen: threadId,
            chatConfiguration: chatConfiguration,
            presentModally: presentModally,
            onDismiss: { [weak self] in
                self?.isActive = false

                L10n.overrideBundle = nil
                L10n.overrideProvider = nil

                A11y.overrideBundle = nil
                A11y.overrideProvider = nil

                onFinish?()
            },
            onSessionExpired: onSessionExpired
        )

        L10n.overrideBundle = chatLocalization.bundle
        L10n.overrideProvider = chatLocalization.provider

        A11y.overrideBundle = chatAccessibility.bundle
        A11y.overrideProvider = chatAccessibility.provider

        return ChatContainerView(viewModel: viewModel)
            .environmentObject(chatStyle)
            .environmentObject(chatLocalization)
    }
}
