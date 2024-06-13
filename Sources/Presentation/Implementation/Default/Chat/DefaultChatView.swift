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

struct DefaultChatView: Alertable, View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @EnvironmentObject var localization: ChatLocalization

    @SwiftUI.Environment(\.presentationMode) private var presentationMode
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    @ObservedObject private var viewModel: DefaultChatViewModel
        
    var positionInQueueBinding: Binding<Int?> {
        Binding<Int?>(
            get: { self.viewModel.thread?.positionInQueue },
            set: { newValue in self.viewModel.thread?.positionInQueue = newValue }
        )
    }

    // MARK: - Init
    
    init(viewModel: DefaultChatViewModel) {
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
                if CXoneChat.shared.mode == .liveChat, let thread = viewModel.thread, !thread.state.isLoaded {
                    LiveChatQueueView(positionInQueue: positionInQueueBinding)
                }
                
                ChatView(
                    messages: $viewModel.messages,
                    isAgentTyping: $viewModel.isAgentTyping,
                    isUserTyping: $viewModel.isUserTyping,
                    isInputEnabled: $viewModel.isInputEnabled,
                    alertType: $viewModel.alertType,
                    onNewMessage: { messageType, attachments in
                        viewModel.onSendMessage(messageType, attachments: attachments)
                    },
                    onPullToRefresh: viewModel.onPullToRefresh,
                    onRichMessageElementSelected: { text, element in // swiftlint:disable:this trailing_closure
                        viewModel.onRichMessageElementSelected(textToSend: text, element: element)
                    }
                )
                .isRefreshable(viewModel.isRefreshable)
                .onChange(of: viewModel.isUserTyping) { _ in
                    viewModel.onUserTyping()
                }
            }
        }
        .background(style.backgroundColor)
        .onAppear(perform: viewModel.onAppear)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: viewModel.willEnterForeground)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: viewModel.didEnterBackground)
        .alert(item: $viewModel.alertType, content: alertContent)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if CXoneChat.shared.mode != .multithread {
                    Button {
                        viewModel.alertType = .disconnect(localization: localization, primaryAction: viewModel.onDisconnectTapped)
                    } label: {
                        Asset.disconnect
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isTrailingNavigarionBarItemVisible {
                    toolbarTrailingMenu
                }
            }
        }
        .navigationBarHidden(viewModel.isEndConversationVisible)
        .navigationBarTitleDisplayMode(viewModel.thread?.state == .closed ? .inline : .large)
        .navigationBarBackButtonHidden(CXoneChat.shared.mode != .multithread)
        .navigationBarTitle(viewModel.thread?.state == .closed ? "" : viewModel.title ?? localization.commonUnassignedAgent)
        .overlay(isVisible: $viewModel.isEndConversationVisible) {
            endConversationOverlay
        }
    }
}

// MARK: - Subviews

private extension DefaultChatView {
    
    var endConversationOverlay: some View {
        EndConversationView(
            agentAvatarUrl: viewModel.thread?.assignedAgent.flatMap { URL(string: $0.imageUrl) },
            agentName: viewModel.thread?.assignedAgent?.fullName ?? viewModel.thread?.lastAssignedAgent?.fullName,
            onStartNewTapped: viewModel.onEndConversationStartChatTapped,
            onBackToConversationTapped: viewModel.onEndConversationBackTapped,
            onCloseChatTapped: viewModel.onEndConversationCloseTapped
        )
        .ignoresSafeArea()
    }
    
    var toolbarTrailingMenu: some View {
        Menu {
            if isOptionEditPrechatFieldVisible {
                Button {
                    viewModel.onEditPrechatField(title: localization.alertEditPrechatCustomFieldsTitle)
                } label: {
                    HStack {
                        Text(localization.chatMenuOptionEditPrechatCustomFields)
                        
                        Asset.ChatThread.editPrechatCustomFields
                    }
                }
            }
            if isOptionEditThreadNameVisible {
                Button(action: viewModel.onEditThreadName) {
                    HStack {
                        Text(localization.chatMenuOptionUpdateName)
                        
                        Asset.ChatThread.editThreadName
                    }
                }
            } else if isOptionEndConversationVisible {
                Button {
                    if viewModel.thread?.state == .closed {
                        viewModel.onEndConversation()
                    } else {
                        viewModel.alertType = .endConversation(localization: localization, primaryAction: viewModel.onEndConversation)
                    }
                } label: {
                    HStack {
                        Text(localization.chatMenuOptionEndConversation)

                        Asset.close
                    }
                }
            }
        } label: {
            Asset.menu
                .imageScale(.large)
        }
        .foregroundColor(style.navigationBarElementsColor)
    }
}

// MARK: - Helpers

private extension DefaultChatView {
    
    var isTrailingNavigarionBarItemVisible: Bool {
        isOptionEditPrechatFieldVisible || isOptionEditThreadNameVisible || isOptionEndConversationVisible
    }
    
    var isOptionEditPrechatFieldVisible: Bool {
        viewModel.isInputEnabled && !viewModel.isEditPrechatCustomFieldsHidden
    }
    
    var isOptionEditThreadNameVisible: Bool {
        viewModel.isInputEnabled && CXoneChat.shared.mode == .multithread
    }
    
    var isOptionEndConversationVisible: Bool {
        CXoneChat.shared.mode == .liveChat
    }
}
