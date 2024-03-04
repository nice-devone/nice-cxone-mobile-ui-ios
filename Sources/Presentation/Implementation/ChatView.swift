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

import SwiftUI

struct ChatView: View {

    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    private let chatManager: ChatManager

    @Binding private var isAgentTyping: Bool
    @Binding private var isUserTyping: Bool

    private let onNewMessage: (ChatMessageType, [AttachmentItem]) -> Void
    private let onPullToRefresh: (UIRefreshControl) -> Void
    private let onRichMessageElementSelected: (_ textToSend: String?, RichMessageSubElementType) -> Void

    private var isRefreshableActive = false
    
    static let packageIdentifier = "CXoneChatUI"

    // MARK: - Init

    init(
        messages: Binding<[ChatMessage]>,
        isAgentTyping: Binding<Bool>,
        isUserTyping: Binding<Bool>,
        onNewMessage: @escaping (ChatMessageType, [AttachmentItem]) -> Void,
        onPullToRefresh: @escaping (UIRefreshControl) -> Void,
        onRichMessageElementSelected: @escaping (_ textToSend: String?, RichMessageSubElementType) -> Void
    ) {
        self.chatManager = ChatManager(messages: messages.wrappedValue)
        self._isAgentTyping = isAgentTyping
        self._isUserTyping = isUserTyping
        self.onNewMessage = onNewMessage
        self.onPullToRefresh = onPullToRefresh
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    let groupedMessages = chatManager.groupMessages()
                    
                    LazyVStack {
                        ForEach(groupedMessages) { group in
                            MessageGroupView(group: group, onRichMessageElementSelected: onRichMessageElementSelected)
                                .id(group.id)
                        }
                        .if(isRefreshableActive) { view in
                            view.onRefresh(onValueChanged: onPullToRefresh)
                        }
                    }
                    .onChange(of: groupedMessages) { group in
                        withAnimation {
                            proxy.scrollTo(group.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(groupedMessages.last?.id, anchor: .bottom)
                    }

                    if isAgentTyping {
                        HStack {
                            TypingIndicator()
                                .id("typingIndicator")
                                .padding(.leading, 10)
                                .onAppear {
                                    withAnimation {
                                        proxy.scrollTo("typingIndicator")
                                    }
                                }

                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .clipped()
            }

            MessageInputView(isEditing: $isUserTyping, onSend: onNewMessage)
        }
        .ifNotNil(style.navigationBarLogo) { view, logo in
            view.toolbar {
                ToolbarItem(placement: .principal) {
                    logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                }
            }
        }
        .background(style.backgroundColor)
    }
    
    // MARK: - Methods
    
    func isRefreshable(_ bool: Bool) -> some View {
        var view = self
        
        view.isRefreshableActive = bool
        
        return view
    }
}
