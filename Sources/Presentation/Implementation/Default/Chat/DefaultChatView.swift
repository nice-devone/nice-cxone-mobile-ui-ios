//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

struct DefaultChatView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @SwiftUI.Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject private var viewModel: DefaultChatViewModel
    
    // MARK: - Init
    
    init(chatThread: ChatThread, coordinator: DefaultChatCoordinator) {
        self.viewModel = DefaultChatViewModel(thread: chatThread, coordinator: coordinator)
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: style.formTextColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ChatView(
                    messages: $viewModel.messages,
                    isAgentTyping: $viewModel.isAgentTyping,
                    isUserTyping: $viewModel.isUserTyping,
                    onNewMessage: { messageType, attachments in
                        viewModel.onSendMessage(messageType, attachments: attachments)
                    },
                    onPullToRefresh: viewModel.onPullToRefresh,
                    onRichMessageElementSelected: { text, element in
                        viewModel.onRichMessageElementSelected(textToSend: text, element: element)
                    }
                )
                .isRefreshable(viewModel.isRefreshable)
                .onChange(of: viewModel.isUserTyping) { _ in
                    viewModel.onUserTyping()
                }
                .onChange(of: viewModel.dismiss) { _ in
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .background(style.backgroundColor)
        .onAppear(perform: viewModel.onAppear)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.willEnterForeground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewModel.didEnterBackgroundNotification()
        }
        .alert(isPresented: $viewModel.shouldShowGenericError)
        .alert(
            isPresented: $viewModel.shouldShowDisconnectAlert,
            title: "Attention",
            message: "Do you want to disconnect from the CXone services?",
            primaryButton: .destructive(Text("Disconnect"), action: viewModel.onDisconnectTapped),
            secondaryButton: .cancel()
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if CXoneChat.shared.mode == .singlethread {
                    Button {
                        viewModel.shouldShowDisconnectAlert = true
                    } label: {
                        Asset.List.disconnect
                    }
                }
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !viewModel.isEditCustomFieldsHidden {
                    Button(action: viewModel.onEditCustomField) {
                        Asset.editCustomFields
                    }
                    .foregroundColor(style.navigationBarElementsColor)
                }
                
                if CXoneChat.shared.mode == .multithread {
                    Button(action: viewModel.onEditThreadName) {
                        Asset.editThreadName
                    }
                    .foregroundColor(style.navigationBarElementsColor)
                }
            }
        }
        .navigationBarTitle(Text(viewModel.title))
        .navigationBarBackButtonHidden(CXoneChat.shared.mode == .singlethread)
    }
}
