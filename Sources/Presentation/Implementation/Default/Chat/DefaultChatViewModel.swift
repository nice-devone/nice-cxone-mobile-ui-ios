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

import Combine
import CXoneChatSDK
import SwiftUI

class DefaultChatViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var thread: ChatThread?
    @Published var title: String?
    @Published var messages = [ChatMessage]()
    @Published var alertType: ChatAlertType?
    @Published var isInputEnabled: Bool
    @Published var isRefreshable = false
    @Published var isAgentTyping = false
    @Published var isUserTyping = false
    @Published var isLoading = false
    @Published var isEditPrechatCustomFieldsHidden = true
    @Published var isEndConversationVisible = false
    @Published var isProcessDialogVisible = false
    
    let attachmentRestrictions: AttachmentRestrictions
    
    private let localization: ChatLocalization
    private let coordinator: DefaultChatCoordinator
    
    private var currentRefreshControl: UIRefreshControl?
    private var cachedThreads = [ChatThread]()
    
    // MARK: - Init
    
    init(thread: ChatThread?, coordinator: DefaultChatCoordinator, localization: ChatLocalization) {
        self.thread = thread
        self.coordinator = coordinator
        self.isInputEnabled = thread?.state != .closed
        self.localization = localization
        self.attachmentRestrictions = AttachmentRestrictions.map(from: CXoneChat.shared.connection.channelConfiguration.fileRestrictions)
        
        CXoneChat.shared.delegate = self
    }
    
    // MARK: - Methods
    
    func onAppear() {
        LogManager.trace("Default chat view appeared")
        
        guard let thread = thread else {
            Log.error("Unable to get selected thread")
            return
        }
        
        do {
            // Mark as read a thread that has not just been created locally
            LogManager.trace("Marking thread as read")
            
            try CXoneChat.shared.threads.markRead(thread)
            
            Task {
                LogManager.trace("Reporting chat window open event")
                
                try await CXoneChat.shared.analytics.chatWindowOpen()
            }
            
            if CXoneChat.shared.mode != .multithread {
                LogManager.trace("LiveChat/Single-thread chat mode = Chat thread is already recovered via automated `connect` flow -> no need to do anything")
                
                self.title = thread.chatTitle
                self.messages = thread.messages.map { ChatMessageMapper.map($0, localization: localization) }
            } else {
                LogManager.trace("Multi-thread chat mode = Chat thread is not yet recovered -> load it manually")
                
                isLoading = true
                
                // To be able to handle receiving new messages from different thread, it is necessary to cache current thread list
                cachedThreads = CXoneChat.shared.threads.get()
                
                try CXoneChat.shared.threads.load(with: thread.id)
            }
        } catch {
            error.logError()
             
            coordinator.dismiss(animated: true)
        }
    }
    
    func willEnterForeground(_ output: NotificationCenter.Publisher.Output) {
        LogManager.trace("Enter foreground")
        
        reconnect()
    }
    
    func didEnterBackground(_ output: NotificationCenter.Publisher.Output) {
        LogManager.trace("Enter background")
        
        CXoneChat.shared.connection.disconnect()
    }
}

// MARK: - Actions

extension DefaultChatViewModel {
    
    func onDisconnectTapped() {
        LogManager.trace("Disconnecting from CXoneChat services")
        
        CXoneChat.shared.delegate = nil
        
        CXoneChat.shared.connection.disconnect()
        coordinator.onFinished?()
        
        coordinator.dismiss(animated: true)
    }
    
    func onEditPrechatField(title: String) {
        LogManager.trace("Trying to edit prechat custom fields")
        
        guard let thread = thread else {
            Log.error("Unable to get selected thread")
            return
        }
        guard let prechatCustomFields = CXoneChat.shared.threads.preChatSurvey?.customFields, !prechatCustomFields.isEmpty else {
            LogManager.error(.unableToParse("prechatCustomFields"))
            return
        }

        let customFields = prechatCustomFields.map { definition in
            FormCustomFieldTypeMapper.map(definition, with: CXoneChat.shared.threads.customFields.get(for: thread.id))
        }
        
        coordinator.presentForm(title: title, customFields: customFields) { [weak self] customFields in
            guard let self else {
                return
            }
            
            do {
                try CXoneChat.shared.threads.customFields.set(customFields, for: thread.id)
            } catch {
                error.logError()
                
                alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
            }
        }
    }
    
    func onEditThreadName() {
        LogManager.trace("Editing thread name")
        
        guard let thread = thread else {
            Log.error("Unable to get selected thread")
            return
        }
        
        coordinator.presentUpdateThreadNameAlert { [weak self] threadName in
            guard let self else {
                return
            }
            
            do {
                try CXoneChat.shared.threads.updateName(threadName, for: thread.id)
            } catch {
                error.logError()
                
                alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
            }
        }
    }
    
    func onEndConversation() {
        guard let thread = thread else {
            Log.error("Unable to get selected thread")
            return
        }
        
        guard thread.state != .closed else {
            LogManager.info("Conversation has been already closed -> show end converastion view without interaction with the SDK")
            
            isEndConversationVisible = true
            return
        }
        
        LogManager.trace("Ending live chat conversation")
        
        do {
            try CXoneChat.shared.threads.endContact(thread)
            
            isLoading = true
        } catch {
            error.logError()
        }
    }
    
    @MainActor
    func onSendMessage(_ messageType: ChatMessageType, attachments: [AttachmentItem], postback: String? = nil) {
        LogManager.trace("Sending a message")
        
        guard let thread = thread else {
            Log.error("Unable to get selected thread")
            return
        }

        isProcessDialogVisible = !attachments.isEmpty
        
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
                try await CXoneChat.shared.threads.messages.send(message, for: thread)
            } catch {
                error.logError()
                
                alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
            }
            
            isProcessDialogVisible = false
        }
    }
    
    func onPullToRefresh(refreshControl: UIRefreshControl) {
        guard let thread = thread else {
            Log.error("Unable to get selected thread")
            return
        }
        
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
            
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
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
        
        guard let thread = thread else {
            Log.error("Unable to get selected thread")
            return
        }
        
        do {
            try CXoneChat.shared.threads.reportTypingStart(isUserTyping, in: thread)
        } catch {
            error.logError()
            
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
        }
    }
    
    func onEndConversationStartChatTapped() {
        LogManager.trace("Create a new live chat conversation")
        
        coordinator.showCoordinator()
    }
    
    func onEndConversationBackTapped() {
        LogManager.trace("Return to the chat transcript")
        
        isEndConversationVisible = false
    }
    
    func onEndConversationCloseTapped() {
        LogManager.trace("Close the chat and return to the host application")
        
        isEndConversationVisible = false
        
        onDisconnectTapped()
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
            LogManager.trace("Did connect to the CXone chat services")
        default:
            return
        }
    }
    
    func onUnexpectedDisconnect() {
        LogManager.trace("Reconnecting the CXone services")
        
        reconnect()
    }
    
    func onThreadUpdated(_ updatedThread: ChatThread) {
        LogManager.trace("Thread has been updated")
        
        guard let thread = thread else {
            Log.error("Unable to get selected thread")
            return
        }
        
        Task { @MainActor in
            if thread.id != updatedThread.id {
                await differentThreadHasBeenUpdated(updatedThread)
            } else {
                messages = updatedThread.messages.map { ChatMessageMapper.map($0, localization: localization) }
                title = updatedThread.chatTitle
                isRefreshable = updatedThread.hasMoreMessagesToLoad
                isInputEnabled = updatedThread.state != .closed
                
                if !isEndConversationVisible, CXoneChat.shared.mode == .liveChat, updatedThread.state == .closed {
                    if updatedThread.state != thread.state {
                        isEndConversationVisible = true
                    } else if updatedThread.assignedAgent == nil, thread.assignedAgent != nil {
                        isEndConversationVisible = false
                    }
                }
                
                let anyPrechatCustomFields = CXoneChat.shared.threads.preChatSurvey?.customFields.isEmpty == false
                
                if anyPrechatCustomFields && isEditPrechatCustomFieldsHidden {
                    isEditPrechatCustomFieldsHidden = false
                }
                if currentRefreshControl?.isRefreshing == true {
                    currentRefreshControl?.endRefreshing()
                    currentRefreshControl = nil
                }
                
                self.thread = updatedThread
                
                isLoading = false
            }
        }
    }
    
    func onAgentTyping(_ isTyping: Bool, threadId: UUID) {
        guard threadId == thread?.id else {
            return
        }
        
        LogManager.trace("Agent \(isTyping ? "started" : "ended") typing")
        
        Task { @MainActor in
            isAgentTyping = isTyping
        }
    }
    
    func onError(_ error: Error) {
        error.logError()
        
        Task { @MainActor in
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
        
            isLoading = false
        }
    }
}

// MARK: - Private methods

private extension DefaultChatViewModel {
    
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
        
        do {
            try await coordinator.showLocalNotificationForDifferentThreadMessage(lastMessage)
        } catch {
            error.logError()
            
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
        }
    }
    
    func reconnect() {
        LogManager.trace("Reconnecting to the CXone chat services")
        
        Task {
            do {
                try await CXoneChat.shared.connection.connect()
            } catch {
                error.logError()
                
                coordinator.dismiss(animated: true)
            }
        }
    }
}

private extension ChatThread {
    
    var chatTitle: String? {
        name?.nilIfEmpty()
            ?? assignedAgent?.fullName.nilIfEmpty()
            ?? lastAssignedAgent?.fullName.nilIfEmpty()
    }
}
