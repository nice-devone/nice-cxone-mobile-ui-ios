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

import Combine
import CXoneChatSDK
import SwiftUI

class DefaultChatViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var title: String
    @Published var messages = [ChatMessage]()
    @Published var isRefreshable = false
    @Published var isAgentTyping = false
    @Published var isUserTyping = false
    @Published var isLoading = false
    @Published var isEditCustomFieldsHidden = true
    @Published var shouldShowGenericError = false
    @Published var shouldShowDisconnectAlert = false
    @Published var dismiss = false    

    var thread: ChatThread
    
    private let coordinator: DefaultChatCoordinator
    
    private var currentRefreshControl: UIRefreshControl?
    private var cachedThreads = [ChatThread]()
    private var wasOffline = false
    
    // MARK: - Lifecycle
    
    init(thread: ChatThread, coordinator: DefaultChatCoordinator) {
        self.thread = thread
        self.coordinator = coordinator
        
        self.title = thread.chatTitle
        self.messages = thread.messages.map(ChatMessageMapper.map)
        
        CXoneChat.shared.delegate = self
    }
    
    // MARK: - Methods
    
    func onAppear() {
        LogManager.trace("Default chat view appeared")
        
        do {
            // Mark as read a thread that has not just been created locally
            LogManager.trace("Marking thread as read")
            
            try CXoneChat.shared.threads.markRead(thread)
            
            Task {
                LogManager.trace("Reporting chat window open event")
                
                try await CXoneChat.shared.analytics.chatWindowOpen()
            }
            
            // Single-thread chat mode = Chat thread is already recovered via automated `connect` flow -> no need to do anything
            guard CXoneChat.shared.mode == .multithread else {
                return
            }
            
            // To be able to handle receiving new messages from different thread, it is necessary to cache current thread list
            cachedThreads = CXoneChat.shared.threads.get()

            LogManager.trace("Loading remaining thread properties and messages")
            
            isLoading = true
            
            try CXoneChat.shared.threads.load(with: thread.id)
        } catch {
            error.logError()
             
            dismiss = true
        }
    }
    
    func onDisconnectTapped() {
        LogManager.trace("Disconnecting from CXoneChat services")
        
        CXoneChat.shared.delegate = nil
        
        CXoneChat.shared.connection.disconnect()
        coordinator.onFinished?()
        
        dismiss = true
    }
    
    func willEnterForeground() {
        reconnect()
    }
    
    func didEnterBackgroundNotification() {
        LogManager.trace("Entering background")
        
        CXoneChat.shared.connection.disconnect()
    }
}

// MARK: - Actions

extension DefaultChatViewModel {
    
    func onEditCustomField() {
        LogManager.trace("Trying to edit custom fields")
        
        let contactCustomFields: [CustomFieldType] = CXoneChat.shared.threads.customFields.get(for: thread.id)
        
        guard !contactCustomFields.isEmpty else {
            LogManager.error(.unableToParse("contactCustomFields"))
            return
        }
        
        coordinator.presentForm(title: "Edit Custom Fields", customFields: contactCustomFields.map(FormCustomFieldTypeMapper.map)) { [weak self] customFields in
            guard let self else {
                return
            }
            
            do {
                try CXoneChat.shared.threads.customFields.set(customFields, for: self.thread.id)
            } catch {
                error.logError()
                
                self.shouldShowGenericError = true
            }
        }
    }
    
    func onEditThreadName() {
        LogManager.trace("Editing thread name")
        
        coordinator.presentUpdateThreadNameAlert { [weak self] threadName in
            guard let self else {
                return
            }
            
            do {
                try CXoneChat.shared.threads.updateName(threadName, for: self.thread.id)
            } catch {
                error.logError()
                
                self.shouldShowGenericError = true
            }
        }
    }
    
    @MainActor
    func onSendMessage(_ messageType: ChatMessageType, attachments: [AttachmentItem], postback: String? = nil) {
        LogManager.trace("Sending a message")
        
        let message: OutboundMessage

        switch messageType {
        case .text(let text):
            message = OutboundMessage(text: text, attachments: attachments.compactMap(AttachmentItemMapper.map))
        case .audio(let item):
            message = OutboundMessage(text: "", attachments: [AttachmentItemMapper.map(item)])
        default:
            LogManager.info("Trying to send message of unexpected type - \(messageType)")
            return
        }
        
        Task { @MainActor in
            do {
                // DE-90705: Core should be responsible for adding the new message to the message list and
                // publishing that change.  Then normal update mechanisms will get the changes reflected through
                // to .messages.
                let newMessage = try await CXoneChat.shared.threads.messages.send(message, for: thread)
               
                thread.messages.append(newMessage)
                messages.append(ChatMessageMapper.map(newMessage))
            } catch {
                error.logError()
                
                shouldShowGenericError = true
            }
        }
    }
    
    func onPullToRefresh(refreshControl: UIRefreshControl) {
        guard thread.hasMoreMessagesToLoad else {
            currentRefreshControl = nil
            refreshControl.endRefreshing()
            return
        }

        LogManager.trace("Trying to load more messages")
        
        self.currentRefreshControl = refreshControl
        
        do {
            try CXoneChat.shared.threads.messages.loadMore(for: thread)
        } catch {
            error.logError()
            
            currentRefreshControl?.endRefreshing()
            currentRefreshControl = nil
            
            shouldShowGenericError = true
        }
    }
    
    @MainActor
    func onRichMessageElementSelected(textToSend: String?, element: RichMessageSubElementType) {
        LogManager.trace("Did select rich content message")
        
        if let postback = element.postback {
            try? CXoneChat.shared.analytics.customVisitorEvent(data: .custom(postback))
        }
        
        if let textToSend {
            onSendMessage(.text(textToSend), attachments: [], postback: element.postback)
        }
    }
    
    func onUserTyping() {
        LogManager.trace("User has \(isUserTyping ? "started" : "ended") typing")
        
        do {
            try CXoneChat.shared.threads.reportTypingStart(isUserTyping, in: thread)
        } catch {
            error.logError()
            
            shouldShowGenericError = true
        }
    }
}

// MARK: - CXoneChatDelegate

extension DefaultChatViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ state: ChatState, mode: ChatMode) {
        switch state {
        case .connecting:
            LogManager.trace("Connecting to the CXone chat services")
            
            Task { @MainActor in
                isLoading = true
            }
        case .connected:
            // Recover is automatically done within reconnect
            if mode != .multithread {
                LogManager.trace("Did connect to the CXone chat services")
            } else {
                LogManager.trace("Did connect to the CXone chat services. Refreshing thread")
                
                do {
                    try CXoneChat.shared.threads.load(with: thread.id)
                } catch {
                    error.logError()
                    
                    dismiss = true
                }
            }
        default:
            return
        }
    }
    
    func onUnexpectedDisconnect() {
        LogManager.trace("Reconnecting the CXone services")
        
        reconnect()
    }
    
    func onThreadUpdated(_ chatThread: ChatThread) {
        LogManager.trace("Thread has been updated")
        
        Task { @MainActor in
            if chatThread.id != thread.id {
                await differentThreadHasBeenUpdated(chatThread)
            } else {
                updateThread()
                
                title = thread.chatTitle
                isRefreshable = thread.hasMoreMessagesToLoad
                
                let anyContactCustomFieldsExists = !(CXoneChat.shared.threads.customFields.get(for: thread.id) as [CustomFieldType]).isEmpty
                
                if anyContactCustomFieldsExists && isEditCustomFieldsHidden {
                    isEditCustomFieldsHidden = false
                }
                
                if currentRefreshControl?.isRefreshing == true {
                    currentRefreshControl?.endRefreshing()
                    currentRefreshControl = nil
                }
                
                isLoading = false
            }
        }
    }
    
    func onAgentTyping(_ isTyping: Bool, threadId: UUID) {
        guard threadId == thread.id else {
            return
        }
        
        LogManager.trace("Agent \(isTyping ? "started" : "ended") typing")
        
        Task { @MainActor in
            isAgentTyping = isTyping
        }
    }
    
    func onError(_ error: Error) {
        error.logError()
        
        shouldShowGenericError = true
    }
}

// MARK: - Private methods

private extension DefaultChatViewModel {

    @MainActor
    func updateThread() {
        LogManager.trace("Updating thread")
        
        guard let updatedThread = CXoneChat.shared.threads.get().thread(by: thread.id) else {
            LogManager.error(.unableToParse("updatedThread", from: CXoneChat.shared.threads))
            return
        }
        
        thread = updatedThread
        messages = thread.messages.map(ChatMessageMapper.map)
    }
    
    @MainActor
    func differentThreadHasBeenUpdated(_ updatedThread: ChatThread) async {
        let threads = self.cachedThreads
        self.cachedThreads = CXoneChat.shared.threads.get()
        
        // Check if count of threads has been changed (=> new message for different thread)
        guard let cachedThread = threads.first(where: { $0.id == updatedThread.id }), cachedThread.messages.count != updatedThread.messages.count else {
            // Thread has been updated but not messages are same = no interaction needed
            LogManager.info("Thread with \(updatedThread.id) id has been updated")
            return
        }
        guard let lastMessage = updatedThread.messages.last else {
            LogManager.error("Unable to get last message for updated thread – invalid thread")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = lastMessage.senderInfo.fullName
        content.subtitle = lastMessage.message
        content.userInfo = ["messageFromDifferentThread": true]
        content.sound = .default
        
        do {
            try await UNUserNotificationCenter
                .current()
                .add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
        } catch {
            error.logError()
            
            shouldShowGenericError = true
        }
    }
    
    func reconnect() {
        LogManager.trace("Reconnecting to the CXone chat services")
        
        CXoneChat.shared.delegate = self
        
        Task {
            do {
                try await CXoneChat.shared.connection.connect()
            } catch {
                error.logError()
                
                dismiss = true
            }
        }
    }
}

// MARK: - Helpers

private extension ChatThread {
    
    var chatTitle: String {
        name?.nilIfEmpty()
            ?? assignedAgent?.fullName.nilIfEmpty()
            ?? "No Agent"
    }
}
