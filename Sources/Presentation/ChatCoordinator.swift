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
import UIKit

/// Class responsible for coordinating and managing chat related views navigation
///
/// This class is designed to simplify the management of chat related views navigation,
/// such as thread list, form or transcript, allowing you to initialize and present chat interfaces with customizable visual styles,
/// specify threads to open, and present dynamic forms. 
/// It offers flexibility in creating and managing chat-related content within your application.
open class ChatCoordinator {

    // MARK: - Properties

    /// The visual style configuration for the chat interface.
    public var chatStyle: ChatStyle
    /// The localization configuration for the chat interface.
    public var chatLocalization: ChatLocalization
    /// The additional configuration for the chat interface (additional fields, flags etc.).
    public var chatConfiguration: ChatConfiguration
    /// Indicates whether the chat is currectly active (i.e., a chat session is ongoing).
    public private(set) var isActive = false
    
    // MARK: - Init
    
    /// Initializes a new instance of `ChatCoordinator` with customizable localization settings.
    ///
    /// It sets up the `ChatCoordinator` with specified or default instance of
    /// `ChatLocalization`. This property allows customization of the chat localization strings,
    /// ensuring that the chat views align language preferences.
    ///
    /// - Parameters:
    ///   - chatStyle: An instance of ``ChatStyle`` that defines the visual style and appearance settings for a chat interface
    ///   - chatLocalization: An instance of ``ChatLocalization`` to handle language and locale-specific text and behavior.
    ///   - chatChonfiguration: an Instance of ``ChatConfiguration`` to handle additional configuration parameters
    ///     that are passed to the UI module wrapping the SDK.
    ///
    /// If no parameters are provided, the default style and localization will be applied.
    public init(
        chatStyle: ChatStyle = ChatStyle(),
        chatLocalization: ChatLocalization = ChatLocalization(),
        chatConfiguration: ChatConfiguration = ChatConfiguration()
    ) {
        self.chatStyle = chatStyle
        self.chatLocalization = chatLocalization
        self.chatConfiguration = chatConfiguration
    }

    // MARK: - Methods
    
    /// Starts the chat coordinator by presenting the chat interface within the given parent view controller.
    ///
    /// This method initializes a `UIHostingController` with a SwiftUI view, which is presented modally
    /// on the provided `parentViewController`. You have the option of providing a `threadId` to open an existing chat thread.
    /// This feature is used for deep linking into specific chat threads
    /// within a multi-threaded channel configuration to resume previous conversations.
    ///
    /// - Note: The `threadId` parameter does not have any effect if the channel configuration is set to single-threaded or live chat
    /// because there is always a single conversation so it's not necessary to handle the `threadId`.
    ///
    /// - Parameters:
    ///   - threadId: The unique identifier for the chat thread to be opened (deeplinking). If `nil`,
    ///     the SDK tries to refresh existing conversation(s) or creates a new one for single-thread and live chat configurations.
    ///   - parentViewController: The view controller in which the chat UI will be presented.
    ///   - presentModally: The flag if the content view is going to be presented modally or in full-screen.
    ///   - onFinish: A closure that is executed when the chat session finishes or is dismissed.
    ///
    /// The method will automatically dismiss any currently presented view controller on the `parentViewController`.
    @available(*, deprecated, message: "Use alternative with `String` parameter. It preserves the original case-sensitive identifier from the backend.")
    public func start(threadId: UUID? = nil, in parentViewController: UIViewController, presentModally: Bool, onFinish: (() -> Void)? = nil) {
        start(threadId: threadId?.uuidString, in: parentViewController, presentModally: presentModally, onFinish: onFinish)
    }
    
    /// Starts the chat coordinator by presenting the chat interface within the given parent view controller.
    ///
    /// This method initializes a `UIHostingController` with a SwiftUI view, which is presented modally
    /// on the provided `parentViewController`. You have the option of providing a `threadId` to open an existing chat thread.
    /// This feature is used for deep linking into specific chat threads
    /// within a multi-threaded channel configuration to resume previous conversations.
    ///
    /// - Note: The `threadId` parameter does not have any effect if the channel configuration is set to single-threaded or live chat
    /// because there is always a single conversation so it's not necessary to handle the `threadId`.
    ///
    /// - Parameters:
    ///   - threadId: The unique identifier for the chat thread to be opened (deeplinking). If `nil`,
    ///     the SDK tries to refresh existing conversation(s) or creates a new one for single-thread and live chat configurations.
    ///   - parentViewController: The view controller in which the chat UI will be presented.
    ///   - presentModally: The flag if the content view is going to be presented modally or in full-screen.
    ///   - onFinish: A closure that is executed when the chat session finishes or is dismissed.
    ///
    /// The method will automatically dismiss any currently presented view controller on the `parentViewController`.
    public func start(threadId: String? = nil, in parentViewController: UIViewController, presentModally: Bool, onFinish: (() -> Void)? = nil) {
        LogManager.trace("Starting the chat coordinator with threadId: \(threadId ?? "nil")")
        
        let content = content(threadId: threadId, presentModally: presentModally) {
            onFinish?()
            
            if presentModally {
                parentViewController.presentedViewController?.dismiss(animated: true)
            } else {
                (parentViewController as? UINavigationController)?.popViewController(animated: true)
            }
        }
        
        let viewController = ChatHostingController(rootView: content, chatStyle: chatStyle)

        if presentModally {
            parentViewController.present(viewController, animated: true)
        } else {
            parentViewController.show(viewController, sender: self)
        }
    }

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
    @available(*, deprecated, message: "Use alternative with `String` parameter. It preserves the original case-sensitive identifier from the backend.")
    public func content(threadId: UUID? = nil, presentModally: Bool, onFinish: (() -> Void)? = nil) -> some View {
        content(threadId: threadId?.uuidString, presentModally: presentModally, onFinish: onFinish)
    }
    
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
    public func content(threadId: String? = nil, presentModally: Bool, onFinish: (() -> Void)? = nil) -> some View {
        isActive = true
        
        return ChatContainerView(
            viewModel: ChatContainerViewModel(
                chatProvider: CXoneChat.shared,
                threadToOpen: threadId,
                chatLocalization: chatLocalization,
                chatStyle: chatStyle,
                chatConfiguration: chatConfiguration,
                presentModally: presentModally
            ) { [weak self] in
                self?.isActive = false
                
                onFinish?()
            }
        )
        .environmentObject(chatStyle)
        .environmentObject(chatLocalization)
    }
}
