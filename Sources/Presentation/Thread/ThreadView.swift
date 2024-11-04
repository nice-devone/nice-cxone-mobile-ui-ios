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

struct ThreadView: Alertable, View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @EnvironmentObject var localization: ChatLocalization

    @SwiftUI.Environment(\.presentationMode) private var presentationMode
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    @ObservedObject private var viewModel: ThreadViewModel
        
    var positionInQueueBinding: Binding<Int?> {
        Binding<Int?>(
            get: { self.viewModel.thread.positionInQueue },
            set: { newValue in self.viewModel.thread.positionInQueue = newValue }
        )
    }

    // MARK: - Init
    
    init(viewModel: ThreadViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: style.formTextColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if CXoneChat.shared.mode == .liveChat, !viewModel.thread.state.isLoaded {
                    LiveChatQueueView(positionInQueue: positionInQueueBinding)
                }
                
                ChatView(
                    messages: $viewModel.messages,
                    hasMoreMessagesToLoad: $viewModel.hasMoreMessagesToLoad,
                    isAgentTyping: $viewModel.isAgentTyping,
                    isUserTyping: $viewModel.isUserTyping,
                    isInputEnabled: $viewModel.isInputEnabled,
                    isProcessDialogVisible: $viewModel.isProcessDialogVisible,
                    alertType: $viewModel.alertType,
                    attachmentRestrictions: AttachmentRestrictions.map(from: CXoneChat.shared.connection.channelConfiguration.fileRestrictions),
                    onNewMessage: { messageType, attachments in
                        viewModel.onSendMessage(messageType, attachments: attachments)
                    },
                    loadMoreMessages: viewModel.loadMoreMessages,
                    onRichMessageElementSelected: viewModel.onRichMessageElementSelected
                )
                .onChange(of: viewModel.isUserTyping) { _ in
                    viewModel.onUserTyping()
                }
            }
        }
        .background(style.backgroundColor)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .alert(item: $viewModel.alertType, content: alertContent)
        .alert(localization.alertUpdateThreadNameTitle, isPresented: $viewModel.isEditingThreadName) {
            TextField(localization.alertUpdateThreadNamePlaceholder, text: $viewModel.threadName)
            
			Button(localization.commonConfirm) {
                viewModel.setThread(name: viewModel.threadName)
            }
        }
        .overlay(isVisible: $viewModel.isEndConversationVisible) {
            endConversationOverlay
        }
    }
}

// MARK: - Subviews

private extension ThreadView {

    var endConversationOverlay: some View {
        EndConversationView(
            agentAvatarUrl: viewModel.thread.assignedAgent.flatMap { URL(string: $0.imageUrl) },
            agentName: viewModel.thread.assignedAgent?.fullName ?? viewModel.thread.lastAssignedAgent?.fullName,
            onStartNewTapped: viewModel.onEndConversationStartChatTapped,
            onBackToConversationTapped: viewModel.onEndConversationBackTapped,
            onCloseChatTapped: viewModel.onEndConversationCloseTapped
        )
        .ignoresSafeArea()
    }

}
