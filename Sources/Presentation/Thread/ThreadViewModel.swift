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

class ThreadViewModel: NavigationItem {

    // MARK: - Properties
    
    @Published var thread: ChatThread
    @Published var messages = [ChatMessage]()
    @Published var alertType: ChatAlertType?
    @Published var isInputEnabled: Bool
    @Published var hasMoreMessagesToLoad = false
    @Published var isAgentTyping = false
    @Published var isUserTyping = false
    @Published var isLoading = false
    @Published var canEditThreadName = false
    @Published var isEndConversationVisible = false
    @Published var isProcessDialogVisible = false
    @Published var isEditingThreadName = false
    @Published var threadName: String
    
    private let localization: ChatLocalization

    private var cachedThreads = [ChatThread]()
    private let chatProvider: ChatProvider

    let attachmentRestrictions: AttachmentRestrictions
    
    weak var containerViewModel: ChatContainerViewModel?
    
    // MARK: - Init
    
    init(
        thread: ChatThread,
        containerViewModel: ChatContainerViewModel,
        onBack: (() -> Void)? = nil
    ) {
        self.thread = thread
        self.containerViewModel = containerViewModel
        self.chatProvider = containerViewModel.chatProvider
        self.attachmentRestrictions = AttachmentRestrictions.map(from: chatProvider.connection.channelConfiguration.fileRestrictions)
        self.threadName = thread.name ?? ""
        self.localization = containerViewModel.chatLocalization
        self.isInputEnabled = thread.state != .closed
        self.canEditThreadName = chatProvider.threads.preChatSurvey?.customFields.isEmpty == false

        super.init(
            left: containerViewModel.back(title: localization.commonBack, action: onBack)
        )
        
        self.content = { AnyView(ThreadView(viewModel: self)) }

        updateActionMenu()
    }

    // MARK: - Methods
    
    func onDisappear() {
        LogManager.trace("Chat view disappeared")
        
        containerViewModel?.chatProvider.remove(delegate: self)
    }
    
    func updateActionMenu() {
        var menu = [NavigationAction]()

        if isInputEnabled && canEditThreadName {
            menu += NavigationAction(title: localization.alertEditPrechatCustomFieldsTitle, image: Asset.ChatThread.editPrechatCustomFields) { [weak self] in
                guard let model = self else {
                    return
                }
                model.onEditPrechatField(title: model.localization.alertEditPrechatCustomFieldsTitle)
            }
        }

        if isInputEnabled && containerViewModel?.chatProvider.mode == .multithread {
            menu += NavigationAction(title: localization.chatMenuOptionUpdateName, image: Asset.ChatThread.editThreadName) { [weak self] in
                self?.onEditThreadName()
            }
        }

        if containerViewModel?.chatProvider.mode == .liveChat {
            menu += NavigationAction(title: localization.chatMenuOptionEndConversation, image: Asset.close) { [weak self] in
                guard let model = self else {
                    return
                }
                if model.thread.state == .closed {
                    model.onEndConversation()
                } else {
                    model.alertType = .endConversation(localization: model.localization, primaryAction: model.onEndConversation)
                }
            }
        }

        right = menu
    }
}

// MARK: - Actions

extension ThreadViewModel {
    
    func onAppear() {
        LogManager.trace("Chat view appeared")
        
        containerViewModel?.chatProvider.add(delegate: self)
        
        do {
            // Mark as read a thread that has not just been created locally
            LogManager.trace("Marking thread as read")
            
            try chatProvider.threads.markRead(thread)

            Task {
                LogManager.trace("Reporting chat window open event")
                
                try await chatProvider.analytics.chatWindowOpen()
            }
            set(title: thread.chatTitle(localization: localization))
            
            if thread.state == .loaded {
                isLoading = true

                try chatProvider.threads.load(with: thread.id)
            }

            // To be able to handle receiving new messages from different thread, it is necessary to cache current thread list
            cachedThreads = chatProvider.threads.get()

            self.messages = thread.messages.map { ChatMessageMapper.map($0, localization: localization) }
        } catch {
            containerViewModel?.show(fatal: error)
        }
    }
    
    func onDisconnectTapped() {
        LogManager.trace("Disconnecting from CXoneChat services")
        
        containerViewModel?.disconnect()
    }
    
    func onEditPrechatField(title: String) {
        LogManager.trace("Trying to edit prechat custom fields")
        
        guard let prechatCustomFields = chatProvider.threads.preChatSurvey?.customFields, !prechatCustomFields.isEmpty else {
            LogManager.error(.unableToParse("prechatCustomFields"))
            return
        }

        let customFields = prechatCustomFields.map { definition in
            FormCustomFieldTypeMapper.map(definition, with: chatProvider.threads.customFields.get(for: thread.id))
        }
        
        containerViewModel?.showForm(
            title: title,
            fields: customFields,
            onAccept: { [self] customFields in
                do {
                    try chatProvider.threads.customFields.set(customFields, for: self.thread.id)
                } catch {
                    error.logError()
                    containerViewModel?.disconnect()
                }
                containerViewModel?.currentChild = self
            },
            onCancel: {
                self.containerViewModel?.currentChild = self
            }
        )
    }

    func onEditThreadName() {
        LogManager.trace("Editing thread name")
        
        isEditingThreadName = true
    }
    
    func setThread(name: String?) {
        do {
            try chatProvider.threads.updateName(threadName, for: thread.id)
        } catch {
            containerViewModel?.show(fatal: error)
        }
   }

    func onEndConversation() {
        guard thread.state != .closed else {
            LogManager.info("Conversation has been already closed -> show end conversation view without interaction with the SDK")

            isEndConversationVisible = true
            return
        }
        
        LogManager.trace("Ending live chat conversation")
        
        do {
            try chatProvider.threads.endContact(thread)

            isLoading = true
        } catch {
            error.logError()
        }
    }
    
    @MainActor
    func onSendMessage(_ messageType: ChatMessageType, attachments: [AttachmentItem], postback: String? = nil) {
        LogManager.trace("Sending a message")
        
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
                try await chatProvider.threads.messages.send(message, for: thread)
            } catch {
                error.logError()
                
                alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
            }
            
            isProcessDialogVisible = false
        }
    }
    
    func loadMoreMessages() {
        guard thread.hasMoreMessagesToLoad else {
            return
        }
        
        LogManager.trace("Trying to load more messages")
        
        do {
            try chatProvider.threads.messages.loadMore(for: thread)
        } catch {
            error.logError()
            
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
        }
    }
    
    @MainActor
    func onRichMessageElementSelected(textToSend: String?, element: RichMessageSubElementType) {
        LogManager.trace("Did select rich content message")
        
        if let textToSend {
            onSendMessage(.text(textToSend), attachments: [], postback: element.postback)
        }
    }
    
    func onUserTyping() {
        LogManager.trace("User has \(isUserTyping ? "started" : "ended") typing")
        
        do {
            try chatProvider.threads.reportTypingStart(isUserTyping, in: thread)
        } catch {
            error.logError()
            
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
        }
    }
    
    func onEndConversationStartChatTapped() {
        LogManager.trace("Create a new live chat conversation")
        containerViewModel?.createThread {
            self.containerViewModel?.disconnect()
        } onSuccess: { thread in
            self.containerViewModel?.show(thread: thread)
        }
    }
    
    func onEndConversationBackTapped() {
        LogManager.trace("Return to the chat transcript")
        
        isEndConversationVisible = false
    }
    
    func onEndConversationCloseTapped() {
        LogManager.trace("Close the chat and return to the host application")
        isEndConversationVisible = false
        containerViewModel?.disconnect()
    }
}

// MARK: - CXoneChatDelegate

extension ThreadViewModel: CXoneChatDelegate {
    
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
        
        Task { @MainActor in
            if thread.id != updatedThread.id {
                await differentThreadHasBeenUpdated(updatedThread)
            } else {
                messages = updatedThread.messages.map { ChatMessageMapper.map($0, localization: localization) }
                set(title: updatedThread.chatTitle(localization: localization))
                hasMoreMessagesToLoad = updatedThread.hasMoreMessagesToLoad
                isInputEnabled = updatedThread.state != .closed
                
                if !isEndConversationVisible, chatProvider.mode == .liveChat, updatedThread.state == .closed {
                    if updatedThread.state != thread.state {
                        isEndConversationVisible = true
                    } else if updatedThread.assignedAgent == nil, thread.assignedAgent != nil {
                        isEndConversationVisible = false
                    }
                }
                
                canEditThreadName = chatProvider.threads.preChatSurvey?.customFields.isEmpty == false
                
                self.thread = updatedThread
                
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
        
        Task { @MainActor in
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
        
            isLoading = false
        }
    }
}

// MARK: - Private methods

private extension ThreadViewModel {
    
    @MainActor
    func differentThreadHasBeenUpdated(_ updatedThread: ChatThread) async {
        let threads = self.cachedThreads
        self.cachedThreads = chatProvider.threads.get()

        // Check if count of threads has been changed (=> new message for different thread)
        guard let cachedThread = threads.first(where: { $0.id == updatedThread.id }), cachedThread.messages.count != updatedThread.messages.count else {
            // Thread has been updated but not messages are same = no interaction needed
            LogManager.info("Thread with \(updatedThread.id) id has been updated")
            return
        }
        guard let message = updatedThread.messages.last else {
            LogManager.error("Unable to get last message for updated thread – invalid thread")
            return
        }
        
        do {
            let content = UNMutableNotificationContent()
            content.title = message.senderInfo.fullName
            content.subtitle = message.getLocalizedContentOrFallbackText(basedOn: localization, useFallback: true) ?? ""
            content.userInfo = ["messageFromDifferentThread": true]
            content.sound = .default
            
            try await UNUserNotificationCenter
                .current()
                .add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
        } catch {
            error.logError()
            
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
        }
    }
    
    func reconnect() {
        LogManager.trace("Reconnecting to the CXone chat services")
        
        Task {
            do {
                try await chatProvider.connection.connect()
            } catch {
                containerViewModel?.show(fatal: error)
            }
        }
    }
}

private extension ChatThread {
    
    func chatTitle(localization: ChatLocalization) -> String {
        let title = assignedAgent?.fullName ?? lastAssignedAgent?.fullName
        
        if let title, !title.isEmpty {
            return title
        }
        
        return localization.commonUnassignedAgent
    }
}
