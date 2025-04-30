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
    private let chatStyle = ChatStyle()
    
    /// The localization configuration for the chat interface.
    public var chatLocalization: ChatLocalization
    /// The additional configuration for the chat interface (additional fields, flags etc.).
    public var chatConfiguration: ChatConfiguration
    
    // MARK: - Init
    
    /// Initializes a new instance of `ChatCoordinator` with customizable localization settings.
    ///
    /// It sets up the `ChatCoordinator` with specified or default instance of
    /// `ChatLocalization`. This property allows customization of the chat localization strings,
    /// ensuring that the chat views align language preferences.
    ///
    /// - Parameter chatLocalization: An instance of `ChatLocalization` to handle language and locale-specific text and behavior.
    ///     Defaults to a new instance of `ChatLocalization()`.
    ///
    /// If no parameters are provided, the default style and localization will be applied.
    public init(
        chatLocalization: ChatLocalization = ChatLocalization(),
        chatConfiguration: ChatConfiguration = ChatConfiguration()
    ) {
        self.chatLocalization = chatLocalization
        self.chatConfiguration = chatConfiguration
    }

    // MARK: - Methods
    
    /// Starts the chat coordinator by presenting the chat interface within the given parent view controller.
    ///
    /// This method initializes a `UIHostingController` with a SwiftUI view, which is presented modally
    /// on the provided `parentViewController`. It logs the action of starting the chat and handles the
    /// optional `threadId` if provided. If a thread ID is not passed, the chat will start a new session.
    ///
    /// - Parameters:
    ///   - threadId: The unique identifier for the chat thread to be opened. If `nil`, a new chat session will be initiated.
    ///   - parentViewController: The view controller in which the chat UI will be presented.
    ///   - presentModally: The flag if the content view is going to be presented modally or in full-screen.
    ///
    /// The method will automatically dismiss any currently presented view controller on the `parentViewController`.
    public func start(threadId: UUID? = nil, in parentViewController: UIViewController, presentModally: Bool, onFinish: (() -> Void)? = nil) {
        LogManager.trace("Starting the chat coordinator with threadId: \(threadId?.uuidString ?? "nil")")
        
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
    /// This method generates a chat container view. The view
    /// handles the entire chat experience and is passed a `threadId` (if any) to open an existing thread,
    /// or shows thread list/thread based on the channel configuration. A closure, `onFinish`, is also provided to handle the
    /// dismissal or any cleanup when the chat session finishes.
    ///
    /// - Parameters:
    ///   - threadId: The unique identifier for a specific chat thread to open.
    ///   - presentModally: The flag if the content view is going to be presented modally or in full-screen.
    ///   - onFinish: A closure that is executed when the chat session finishes or is dismissed.
    ///
    /// - Returns: A `View` representing the chat UI to be displayed.
    ///
    /// This view is may be used within a `UIHostingController` for integration into a UIKit-based app.
    public func content(threadId: UUID? = nil, presentModally: Bool, onFinish: (() -> Void)? = nil) -> some View {
        ChatContainerView(
            viewModel: ChatContainerViewModel(
                chatProvider: CXoneChat.shared,
                threadToOpen: threadId,
                chatLocalization: chatLocalization,
                chatStyle: chatStyle,
                chatConfiguration: chatConfiguration,
                presentModally: presentModally,
                onDismiss: onFinish
            )
        )
        .environmentObject(chatStyle)
        .environmentObject(chatLocalization)
    }
}
