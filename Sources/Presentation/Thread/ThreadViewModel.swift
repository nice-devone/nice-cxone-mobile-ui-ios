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

import Combine
import CXoneChatSDK
import SwiftUI

class ThreadViewModel: ObservableObject {

    // MARK: - Properties
    
    @Published var thread: CXoneChatUI.ChatThread?
    @Published var messageGroups = [MessageGroup]()
    /// Indicator of the message input bar is disabled
    @Published var isInputEnabled = false
    /// Indicator if the message input bar is replaced with view that informs about conversation closed/archived state
    @Published var isThreadClosed = false
    @Published var hasMoreMessagesToLoad = true
    @Published var typingAgent: ChatUser?
    @Published var isUserTyping = false
    @Published var canEditCustomFields = false
    @Published var isProcessDialogVisible = false
    @Published var isEditingThreadName = false
    @Published var threadName: String = ""
    @Published var positionInQueue: Int?

    let attachmentRestrictions: AttachmentRestrictions
    
    weak var containerViewModel: ChatContainerViewModel?
    
    var alertType: ChatAlertType? {
        get { containerViewModel?.alertType }
        set { containerViewModel?.alertType = newValue }
    }
    var chatTitle: String {
        let title = thread?.assignedAgent?.fullName ?? thread?.lastAssignedAgent?.fullName

        if let title, !title.isEmpty {
            return title
        }

        return localization.commonUnassignedAgent
    }
    
    private let chatProvider: ChatProvider
    private let localization: ChatLocalization
    
    private var didSetAdditionalCustomFields = false
    private var isEndConversationShown = false
    private var isThreadPermanentlyClosed = false

    private static let groupInterval: TimeInterval = 120

    // MARK: - Init

    init(
        thread: CXoneChatUI.ChatThread?,
        containerViewModel: ChatContainerViewModel
    ) {
        self.thread = thread
        self.containerViewModel = containerViewModel
        self.chatProvider = containerViewModel.chatProvider
        self.attachmentRestrictions = AttachmentRestrictions.map(from: chatProvider.connection.channelConfiguration.fileRestrictions)
        self.localization = containerViewModel.chatLocalization
        self.canEditCustomFields = chatProvider.threads.preChatSurvey?.customFields.isEmpty == false
    }

    // MARK: - Methods
    
    func onAppear() {
        LogManager.trace("Chat view appeared")
        
        chatProvider.add(delegate: self)
        
        Task {
            do {
                _ = try await MainActor.run {
                    try updateThread(with: thread)
                }
                
                guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
                    LogManager.error("Unexpected nil thread")
                    return
                }
                
                if thread.state == .ready {
                    LogManager.trace("Marking thread as read")
                    
                    try await threadProvider.markRead()
                }
            } catch {
                error.logError()
                
                _ = await MainActor.run { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.alertType = .connectionErrorAlert(localization: self.localization) {
                        self.containerViewModel?.disconnect()
                    }
                }
            }
        }
    }

    func onDisappear() {
        LogManager.trace("Chat view disappeared")
        
        containerViewModel?.chatProvider.remove(delegate: self)
    }
}

// MARK: - Actions

extension ThreadViewModel {

    func onEditPrechatField() {
        LogManager.trace("Trying to edit prechat custom fields")
        
        guard let thread else { 
            LogManager.error("Unexpected nil thread")
            return
        }

        guard let prechatCustomFields = chatProvider.threads.preChatSurvey?.customFields, !prechatCustomFields.isEmpty else {
            LogManager.error(.unableToParse("prechatCustomFields"))
            return
        }

        let customFields = prechatCustomFields.map { definition in
            FormCustomFieldTypeMapper.map(definition, with: chatProvider.threads.customFields.get(for: thread.id))
        }
        
        Task {
            guard let answers = await containerViewModel?.showForm(title: localization.alertEditPrechatCustomFieldsTitle, fields: customFields) else {
                return
            }

            do {
                try await chatProvider.threads.customFields.set(answers, for: thread.id)
            } catch {
                error.logError()
                
                _ = await MainActor.run { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.alertType = .connectionErrorAlert(localization: self.localization) {
                        self.containerViewModel?.disconnect()
                    }
                }
            }
        }
    }

    func onEditThreadName() {
        LogManager.trace("Editing thread name")
        
        isEditingThreadName = true
    }
    
    func setThread(name: String) {
        LogManager.trace("Setting thread name to \(name) for thread \(String(describing: thread?.id))")
        
        guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }
        
        Task {
            do {
                try await threadProvider.updateName(name)
            } catch {
                _ = await MainActor.run { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.alertType = .genericError(localization: localization)
                }
            }
        }
    }
    
    func showEndConversation() {
        guard let thread else {
            LogManager.error("Unexpected nil thread")
            return
        }
        
        LogManager.trace("Showing EndConversation view")
        
        self.isEndConversationShown = true
        
        self.containerViewModel?.showOverlay {
            ChatDefaultOverlay(verticalOffset: StyleGuide.containerVerticalOffset) {
                EndConversationView(
                    onStartNewTapped: self.onEndConversationStartChatTapped,
                    onBackToConversationTapped: self.onEndConversationBackTapped,
                    onCloseChatTapped: self.onEndConversationCloseTapped,
                    thread: thread
                )
            }
        }
    }

    func onEndConversation() {
        guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }

        guard threadProvider.chatThread.state != .closed else {
            LogManager.info("Conversation has been already closed -> show end conversation view without interaction with the SDK")
            return
        }
        
        Task { @MainActor in
            LogManager.trace("Ending live chat conversation")
            
            do {
                try await threadProvider.endContact()
                
                showEndConversation()
            } catch {
                error.logError()
                
                alertType = .connectionErrorAlert(localization: localization) { [weak self] in
                    self?.containerViewModel?.disconnect()
                }
            }
        }
    }
    
    func onSendMessage(_ messageType: ChatMessageType, attachments: [AttachmentItem], postback: String? = nil) {
        LogManager.trace("Sending a message")
        
        guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }

        isProcessDialogVisible = !attachments.isEmpty
        
        let message: OutboundMessage

        switch messageType {
        case .text(let text):
            message = OutboundMessage(text: text, attachments: attachments.compactMap(AttachmentItemMapper.map), postback: postback)
        case .audio(let item):
            message = OutboundMessage(text: "", attachments: [AttachmentItemMapper.map(item)], postback: postback)
        default:
            LogManager.info("Trying to send message of unexpected type - \(messageType)")
            return
        }
        
        Task { @MainActor in
            do {
                try await threadProvider.send(message)
            } catch {
                error.logError()
                
                switch error {
                case CXoneChatError.invalidFileType:
                    alertType = .invalidAttachmentType(localization: localization)
                case CXoneChatError.invalidFileSize:
                    alertType = .invalidAttachmentSize(localization: localization)
                default:
                    alertType = .genericError(localization: localization)
                }
            }
            
            isProcessDialogVisible = false
        }
    }
    
    func loadMoreMessages() async {
        LogManager.trace("Trying to load more messages")
        
        guard let thread, thread.hasMoreMessagesToLoad, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")

            Task { @MainActor in
                hasMoreMessagesToLoad = false
            }

            return
        }
        
        do {
            try await threadProvider.loadMoreMessages()
        } catch {
            error.logError()
            
            _ = await MainActor.run { [weak self] in
                guard let self else {
                    return
                }
                
                self.alertType = .connectionErrorAlert(localization: self.localization) {
                    self.containerViewModel?.disconnect()
                }
            }
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
        
        guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }

        Task {
            do {
                try await threadProvider.reportTypingStart(isUserTyping)
            } catch {
                error.logError()
                
                _ = await MainActor.run { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.alertType = .connectionErrorAlert(localization: self.localization) {
                        self.containerViewModel?.disconnect()
                    }
                }
            }
        }
    }
    
    func onEndConversationStartChatTapped() {
        LogManager.trace("Create a new live chat conversation")

        Task { @MainActor in
            // Reset thread reference and isThreadPermanentlyClosed flag to allow proper handling of the new thread
            self.thread = nil
            isThreadPermanentlyClosed = false
            
            do {
                // Hide the end conversation view before starting a new thread
                isEndConversationShown = false
                
                // Hide any overlay before starting a new thread
                containerViewModel?.hideOverlay()
                
                // Explicitly reset thread state to allow proper initialization of a new thread
                // This prevents race conditions when quickly starting a new thread after a previous one was closed
                self.thread = nil
                
                // Show loading state while creating the new thread
                containerViewModel?.showLoading(message: localization.commonLoading)
                
                // The only situation when the ChatThreadProvider is `nil` is when the pre-chat form is cancelled.
                guard let threadProvider = try await containerViewModel?.createThread() else {
                    LogManager.trace("New thread was not created because customer cancelled a prechat survey -> disconnecting")

                    containerViewModel?.disconnect()
                    return
                }
                
                try self.updateThread(with: ChatThreadMapper.map(from: threadProvider.chatThread))
            } catch {
                error.logError()
                
                self.alertType = .connectionErrorAlert(localization: self.localization) {
                    self.containerViewModel?.disconnect()
                }
            }
        }
    }
    
    @MainActor
    func updateInputEnabledStateBasedOnThread() {
        self.isInputEnabled = thread != nil
        
        // If thread was ever closed, keep input disabled
        if isThreadPermanentlyClosed {
            self.isThreadClosed = true
            return
        }
        
        // Otherwise check current thread state
        if let thread {
            self.isThreadClosed = thread.state == .closed
        } else {
            self.isThreadClosed = false
        }
    }
    
    @MainActor
    func onEndConversationBackTapped() {
        LogManager.trace("Return to the chat transcript")
        
        // Reset flag before hiding overlay
        isEndConversationShown = false
        
        // Ensure input is disabled if needed
        updateInputEnabledStateBasedOnThread()
        
        // Hide any visible overlay if needed
        containerViewModel?.hideOverlay()
    }
    
    func onEndConversationCloseTapped() {
        LogManager.trace("Close the chat and return to the host application")
        
        // Reset flag
        isEndConversationShown = false
        
        containerViewModel?.disconnect()
    }
}

// MARK: - CXoneChatDelegate

extension ThreadViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ state: ChatState, mode: ChatMode) {
        Task { @MainActor in
            canEditCustomFields = chatProvider.mode == .multithread
                && chatProvider.threads.preChatSurvey?.customFields.isEmpty == false
            
            do {
                switch state {
                case .ready:
                    try await handleChatReadyState(for: mode)
                case .offline:
                    containerViewModel?.showOffline()
                default:
                    break
                }
            } catch {
                error.logError()
                
                alertType = .connectionErrorAlert(localization: localization) { [weak self] in
                    self?.containerViewModel?.disconnect()
                }
            }
        }
    }

    func onThreadUpdated(_ updatedThread: CXoneChatSDK.ChatThread) {
        // 1. When thread reference is nil (which happens after creating a new thread following a closed conversation),
        // we need to accept any incoming thread update to properly display the new conversation.
        // This prevents the issue where new threads weren't being displayed after closing a previous thread.
        //
        // 2. We only want to update the thread view state if the updatedThread is the one currently in use.
        guard thread == nil || thread?.id == updatedThread.id else {
            LogManager.trace("Ignoring thread update - the thread is not the current one")
            return
        }
        
        Task { @MainActor in
            do {
                try updateThread(with: ChatThreadMapper.map(from: updatedThread))
            } catch {
                error.logError()
                
                // Hide any overlay
                containerViewModel?.hideOverlay()
                
                alertType = .connectionErrorAlert(localization: localization) { [weak self] in
                    self?.containerViewModel?.disconnect()
                }
            }
        }
    }

    func onAgentTyping(_ isTyping: Bool, agent: Agent, threadId: UUID) {
        guard threadId == thread?.id else {
            return
        }
        
        LogManager.trace("Agent \(isTyping ? "started" : "ended") typing")
        
        let agent = ChatUserMapper.map(from: agent)
        
        Task { @MainActor in
            typingAgent = isTyping ? agent : nil
        }
    }
}

// MARK: - Private methods

private extension ThreadViewModel {

    @MainActor
    func updateThread(with updatedThread: CXoneChatUI.ChatThread?) throws {
        LogManager.trace("updated state = \(String(describing: updatedThread?.state))")
        
        // Record if the thread has been closed
        if updatedThread?.state == .closed {
            isThreadPermanentlyClosed = true
            LogManager.trace("Thread has been marked as closed")
        }
        
        // Trigger the load if the UI module entered the background or the thread is not loaded yet
        if let updatedThread, (containerViewModel?.shouldRefreshThread == true) || (chatProvider.mode == .multithread && updatedThread.state == .loaded) {
            containerViewModel?.shouldRefreshThread = false
            
            reloadThread(with: updatedThread.id)
        } else if chatProvider.mode == .liveChat, updatedThread?.state != .ready, updatedThread?.positionInQueue == nil {
            // Show loading before the BE sends position in queue
            containerViewModel?.showLoading(message: localization.commonLoading)
        } else if updatedThread?.state == .ready || (updatedThread?.state != .closed && updatedThread?.positionInQueue != nil) {
            // Hide the loading overlay if the thread is ready or position in queue is set and EndConversation view is not being shown
            if !isEndConversationShown {
                containerViewModel?.hideOverlay()
            }
        }
        
        self.thread = updatedThread
        self.threadName = updatedThread?.name ?? ""
        
        // Update input state now that we've potentially updated hasBeenClosed
        updateInputEnabledStateBasedOnThread()
        
        self.messageGroups = updatedThread?
            .messages
            .map { ChatMessageMapper.map($0, localization: localization) }
            .groupMessages(interval: Self.groupInterval)
        ?? []
        
        handleLivechatPositionInQueueVisibility()

        if let updatedThread {
            LogManager.trace("\(updatedThread.messages.count) grouped into \(messageGroups.count)")
            
            setAdditionalCustomFieldsIfNeeded(for: updatedThread)
        }

        hasMoreMessagesToLoad = updatedThread?.hasMoreMessagesToLoad ?? false

        if chatProvider.mode == .liveChat, updatedThread?.state == .closed {
            showEndConversation()
        }
    }
    
    func reloadThread(with id: UUID) {
        LogManager.trace("Recovering thread")
        
        containerViewModel?.showLoading(message: localization.commonLoading)
        
        Task {
            do {
                try await chatProvider.threads.load(with: id)
            } catch {
                error.logError()
                
                _ = await MainActor.run { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.alertType = .connectionErrorAlert(localization: self.localization) {
                        self.containerViewModel?.disconnect()
                    }
                }
            }
            
            containerViewModel?.hideOverlay()
        }
    }
    
    @MainActor
    func handleChatReadyState(for mode: ChatMode) async throws {
        switch mode {
        case .singlethread, .liveChat:
            try await handleSingleThreadAndLivechatReadyState()
        case .multithread:
            try await handleMultithreadReadyState()
        }
        
        if let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) {
            if thread.state == .ready {
                LogManager.trace("Marking thread as read")
                
                try await threadProvider.markRead()
            }
        } else {
            LogManager.error("Unable to mark thread as read - no thread provider available.")
        }
    }
    
    @MainActor
    func handleSingleThreadAndLivechatReadyState() async throws {
        if let thread = chatProvider.threads.get().first, thread.state != .closed {
            try updateThread(with: ChatThreadMapper.map(from: thread))
        } else if let threadProvider = try await containerViewModel?.createThread() {
            try updateThread(with: ChatThreadMapper.map(from: threadProvider.chatThread))
        } else {
            LogManager.trace("New thread was not created because customer cancelled a prechat survey -> disconnecting")
            
            containerViewModel?.disconnect()
        }
    }
    
    @MainActor
    func handleMultithreadReadyState() async throws {
        if let thread, let sdkThread = chatProvider.threads.get().first(where: { $0.id == thread.id }) {
            try updateThread(with: ChatThreadMapper.map(from: sdkThread))
        } else {
            LogManager.error("Unable to get thread")
            
            alertType = .connectionErrorAlert(localization: localization) { [weak self] in
                self?.containerViewModel?.disconnect()
            }
        }
    }
    
    func setAdditionalCustomFieldsIfNeeded(for thread: ChatThread) {
        guard let additionalFields = containerViewModel?.chatConfiguration.additionalContactCustomFields, !additionalFields.isEmpty else {
            return
        }
        guard didSetAdditionalCustomFields == false else {
            return
        }
        
        didSetAdditionalCustomFields = true
        
        Task {
            LogManager.trace("Setting additional contact custom fields")

            try await chatProvider.threads.customFields.set(additionalFields, for: thread.id)
        }
    }
    
    func handleLivechatPositionInQueueVisibility() {
        guard chatProvider.mode == .liveChat, chatProvider.state.isChatAvailable else {
            self.positionInQueue = nil
            return
        }
        guard let thread else {
            // The thread is nil so it is initializing -> can present the position in queue without information about the position in queue
            positionInQueue = .min
            return
        }
        
        if thread.state == .closed {
            self.positionInQueue = nil
        } else if let positionInQueue = thread.positionInQueue {
            self.positionInQueue = positionInQueue
        } else if thread.assignedAgent == nil && thread.lastAssignedAgent == nil {
            // No agent assigned yet -> show the position in queue without information about the position in queue
            self.positionInQueue = .min
        } else {
            self.positionInQueue = nil
        }
    }
}

// MARK: - Menu builder

extension ThreadViewModel {

    var menu: MenuBuilder {
        MenuBuilder()
            .add(
                if: !isThreadClosed && canEditCustomFields,
                name: localization.alertEditPrechatCustomFieldsTitle,
                icon: Asset.ChatThread.editPrechatCustomFields,
                action: onEditPrechatField
            )
            .add(
                if: !isThreadClosed && containerViewModel?.chatProvider.mode == .multithread,
                name: localization.chatMenuOptionUpdateName,
                icon: Asset.ChatThread.editThreadName,
                action: onEditThreadName
            )
            .add(
                if: containerViewModel?.chatProvider.mode == .liveChat,
                name: localization.chatMenuOptionEndConversation,
                icon: Asset.close
            ) { [weak self] in
                guard let self else {
                    return
                }
                
                if thread?.state == .closed {
                    showEndConversation()
                } else {
                    self.alertType = .endConversation(localization: self.localization, primaryAction: self.onEndConversation)
                }
            }
    }
}
