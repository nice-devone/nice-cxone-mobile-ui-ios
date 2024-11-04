//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

    let chatStyle: ChatStyle
    let chatLocalization: ChatLocalization

    // MARK: - Init
    
    /// Initialization of the ChatCoordinator
    ///
    public init(
        chatStyle: ChatStyle = ChatStyle(),
        chatLocalization: ChatLocalization = ChatLocalization()
    ) {
        self.chatStyle = chatStyle
        self.chatLocalization = chatLocalization
    }

    // MARK: - Methods
    
    public func start(threadId: UUID? = nil, in parentViewController: UIViewController) {
        LogManager.trace("Starting the chat coordinator with threadId: \(threadId?.uuidString ?? "nil")")
        
        let viewController = UIHostingController(rootView: content(threadId: threadId) {
            parentViewController.presentedViewController?.dismiss(animated: true)
        })

        parentViewController.present(viewController, animated: true)
    }

    public func content(threadId: UUID? = nil, onFinish: @escaping () -> Void) -> some View {
        ChatContainerView(
            viewModel: ChatContainerViewModel(
                chatProvider: CXoneChat.shared,
                threadToOpen: threadId,
                chatLocalization: chatLocalization,
                onDismiss: onFinish
            )
        )
        .environmentObject(chatLocalization)
        .environmentObject(chatStyle)
    }
}
