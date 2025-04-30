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

struct ThreadView: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
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
            hasMoreMessagesToLoad: $viewModel.hasMoreMessagesToLoad,
            typingAgent: $viewModel.typingAgent,
            isUserTyping: $viewModel.isUserTyping,
            isInputEnabled: $viewModel.isInputEnabled,
            isProcessDialogVisible: $viewModel.isProcessDialogVisible,
            alertType: $viewModel.alertType,
            attachmentRestrictions: viewModel.attachmentRestrictions,
            queuePosition: viewModel.positionInQueue,
            onNewMessage: { messageType, attachments in
                viewModel.onSendMessage(messageType, attachments: attachments)
            },
            loadMoreMessages: viewModel.loadMoreMessages,
            onRichMessageElementSelected: viewModel.onRichMessageElementSelected
        )
        .background(colors.customizable.background)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .navigationTitle(viewModel.chatTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                viewModel.menu.build(colors: colors)
            }
        }
        .alert(localization.alertUpdateThreadNameTitle, isPresented: $viewModel.isEditingThreadName) {
            TextField(localization.alertUpdateThreadNamePlaceholder, text: $viewModel.threadName)
            
            VStack {
                Button(localization.commonCancel, role: .cancel) {
                    viewModel.isEditingThreadName = false
                }
                
                Button(localization.commonConfirm) {
                    viewModel.setThread(name: viewModel.threadName)
                }
            }
        }
        .onChange(of: viewModel.isProcessDialogVisible) { isVisible in
            if isVisible {
                viewModel.containerViewModel?.showLoading(message: localization.chatAttachmentsUpload)
            } else {
                viewModel.containerViewModel?.hideOverlay()
            }
        }
        .onChange(of: viewModel.isUserTyping) { _ in
            viewModel.onUserTyping()
        }
        .onChange(of: scheme) { _ in
            NotificationCenter.default.post(name: .colorSchemeChanged, object: nil)
        }
    }
}

// MARK: - Helpers

extension Notification.Name {
    
    static let colorSchemeChanged = Notification.Name("colorSchemeChanged")
}
