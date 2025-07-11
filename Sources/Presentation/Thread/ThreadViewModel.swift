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
        // The thread name has higher priority in multi-thread scenarios because it's set by the customer
        thread?.name?.nilIfEmpty()
            // If the thread name is not set, or it's a single-thread or live chat, use the assigned agent's full name
            ?? thread?.assignedAgent?.fullName.nilIfEmpty()
            // If no agent is currently assigned, but one was previously, use the last assigned agent's full name
            ?? thread?.lastAssignedAgent?.fullName.nilIfEmpty()
            // If none of the above are available, use "No agent"
            ?? localization.commonUnassignedAgent
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
        
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            await self.updateThread(with: thread)
            
            do {
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
                
                self.alertType = .connectionErrorAlert(localization: self.localization) {
                    Task { @MainActor in
                        await self.containerViewModel?.disconnect()
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

    @MainActor
    func onEditPrechatField() async {
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
        
        guard let answers = await containerViewModel?.showForm(title: localization.alertEditPrechatCustomFieldsTitle, fields: customFields) else {
            return
        }

        do {
            try await chatProvider.threads.customFields.set(answers, for: thread.id)
        } catch {
            error.logError()
            
            alertType = .connectionErrorAlert(localization: localization) { [weak self] in
                Task { @MainActor in
                    await self?.containerViewModel?.disconnect()
                }
            }
        }
    }

    func onEditThreadName() {
        LogManager.trace("Editing thread name")
        
        isEditingThreadName = true
    }
    
    @MainActor
    func setThread(name: String) async {
        LogManager.trace("Setting thread name to \(name) for thread \(String(describing: thread?.id))")
        
        guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }
        
        do {
            try await threadProvider.updateName(name)
        } catch {
            error.logError()
            
            self.alertType = .genericError(localization: localization)
        }
    }
    
    @MainActor
    func showEndConversation() async {
        guard let thread else {
            LogManager.error("Unexpected nil thread")
            return
        }
        
        LogManager.trace("Showing EndConversation view")
        
        self.isEndConversationShown = true
        
        await containerViewModel?.showOverlay {
            ChatDefaultOverlay(verticalOffset: StyleGuide.containerVerticalOffset) {
                EndConversationView(
                    onStartNewTapped: {
                        Task { @MainActor [weak self] in
                            await self?.onEndConversationStartChatTapped()
                        }
                    },
                    onBackToConversationTapped: {
                        Task { @MainActor [weak self] in
                            await self?.onEndConversationBackTapped()
                        }
                    },
                    onCloseChatTapped: {
                        Task { @MainActor [weak self] in
                            await self?.onEndConversationCloseTapped()
                        }
                    },
                    thread: thread
                )
            }
        }
    }

    @MainActor
    func onEndConversation() async {
        guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }

        guard threadProvider.chatThread.state != .closed else {
            LogManager.info("Conversation has been already closed -> show end conversation view without interaction with the SDK")
            return
        }
        
        LogManager.trace("Ending live chat conversation")
        
        await containerViewModel?.hideOverlay()
        
        do {
            try await threadProvider.endContact()
            
            await showEndConversation()
        } catch {
            error.logError()
            
            alertType = .connectionErrorAlert(localization: localization) { [weak self] in
                Task { @MainActor in
                    await self?.containerViewModel?.disconnect()
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
    
    @MainActor
    func loadMoreMessages() async {
        LogManager.trace("Trying to load more messages")
        
        guard let thread, thread.hasMoreMessagesToLoad, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            hasMoreMessagesToLoad = false
            return
        }
        
        do {
            try await threadProvider.loadMoreMessages()
        } catch {
            error.logError()
            
            alertType = .connectionErrorAlert(localization: self.localization) {
                Task { @MainActor [weak self] in
                    await self?.containerViewModel?.disconnect()
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

        Task { [weak self] in
            guard let self else {
                return
            }
            
            do {
                try await threadProvider.reportTypingStart(self.isUserTyping)
            } catch {
                error.logError()
                
                _ = await MainActor.run { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.alertType = .connectionErrorAlert(localization: self.localization) {
                        Task { @MainActor in
                            await self.containerViewModel?.disconnect()
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func onEndConversationStartChatTapped() async {
        LogManager.trace("Create a new live chat conversation")

        // Explicitly reset thread state to allow proper initialization of a new thread
        // This prevents race conditions when quickly starting a new thread after a previous one was closed
        thread = nil
        isThreadPermanentlyClosed = false
        
        // Hide the end conversation view before starting a new thread
        isEndConversationShown = false
        
        // Hide any overlay before starting a new thread
        await containerViewModel?.hideOverlay()
        
        // Show loading state while creating the new thread
        await containerViewModel?.showLoading(message: localization.commonLoading)
        
        do {
            // The only situation when the ChatThreadProvider is `nil` is when the pre-chat form is cancelled.
            guard let threadProvider = try await containerViewModel?.createThread() else {
                LogManager.trace("New thread was not created because customer cancelled a prechat survey -> disconnecting")
                await containerViewModel?.disconnect()
                return
            }
            
            await self.updateThread(with: ChatThreadMapper.map(from: threadProvider.chatThread))
        } catch {
            error.logError()
            
            self.alertType = .connectionErrorAlert(localization: self.localization) {
                Task { @MainActor [weak self] in
                    await self?.containerViewModel?.disconnect()
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
    func onEndConversationBackTapped() async {
        LogManager.trace("Return to the chat transcript")
        
        // Reset flag before hiding overlay
        isEndConversationShown = false
        
        // Ensure input is disabled if needed
        updateInputEnabledStateBasedOnThread()
        
        // Hide any visible overlay if needed
        await containerViewModel?.hideOverlay()
    }
    
    @MainActor
    func onEndConversationCloseTapped() async {
        LogManager.trace("Close the chat and return to the host application")
        
        // Reset flag
        isEndConversationShown = false
        
        await containerViewModel?.disconnect()
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
                default:
                    break
                }
            } catch {
                error.logError()
                
                alertType = .connectionErrorAlert(localization: localization) {
                    Task { @MainActor [weak self] in
                        await self?.containerViewModel?.disconnect()
                    }
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
            await updateThread(with: ChatThreadMapper.map(from: updatedThread))
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
    func updateThread(with updatedThread: CXoneChatUI.ChatThread?) async {
        LogManager.trace("updated state = \(String(describing: updatedThread?.state))")
        
        // Record if the thread has been closed
        if updatedThread?.state == .closed {
            LogManager.trace("Thread has been marked as closed")
            
            isThreadPermanentlyClosed = true
        }
        
        // Update the thread reference
        self.thread = updatedThread
        
        // Prepare flag that indicates if the `updateThread(with:)` method flow can continue
        var flowContinues = true
        
        // Update the input state based on the channel configuration mode
        switch chatProvider.mode {
        case .singlethread:
            await updateSinglethreadThread(updatedThread, flowContinues: &flowContinues)
        case .multithread:
            await updateMultithreadThread(updatedThread, flowContinues: &flowContinues)
        case .liveChat:
            await updateLiveChatThread(updatedThread, flowContinues: &flowContinues)
        }
        
        // Check if the flow can continue or if it was canceled in specific configuration updated method
        guard flowContinues else {
            return
        }
        
        // Update input state now that we've potentially updated hasBeenClosed
        updateInputEnabledStateBasedOnThread()
        
        // Update the message groups for the thread
        self.messageGroups = updatedThread?
            .messages
            .map { ChatMessageMapper.map($0, localization: localization) }
            .groupMessages(interval: Self.groupInterval)
        ?? []
        
        // Log the number of messages grouped and set additional custom fields if needed
        if let updatedThread {
            LogManager.trace("\(updatedThread.messages.count) grouped into \(messageGroups.count)")
            
            await setAdditionalCustomFieldsIfNeeded(for: updatedThread)
        }
        
        // Update the state if there are more messages to load
        hasMoreMessagesToLoad = updatedThread?.hasMoreMessagesToLoad ?? false
    }
    
    @MainActor
    func updateSinglethreadThread(_ updatedThread: CXoneChatUI.ChatThread?, flowContinues: inout Bool) async {
        LogManager.trace("Updating thread for singlethread channel configuration")
        
        if let updatedThread, containerViewModel?.shouldRefreshThread == true {
            // Trigger the load if the UI module entered the background or the thread is not loaded yet
            containerViewModel?.shouldRefreshThread = false
            
            await reloadThread(with: updatedThread.id)
            // If the thread is not loaded, we don't want to update the view. It will be updated once the thread is loaded via `onThreadUpdated(_:)`.
            flowContinues = false
            return
        } else if updatedThread?.state == .ready || updatedThread?.state != .closed {
            // Hide the loading overlay if the thread is ready or not closed
            await containerViewModel?.hideOverlay()
        }
    }
    
    @MainActor
    func updateMultithreadThread(_ updatedThread: CXoneChatUI.ChatThread?, flowContinues: inout Bool) async {
        LogManager.trace("Updating thread for multithread channel configuration")
        
        if let updatedThread, (containerViewModel?.shouldRefreshThread == true) || updatedThread.state == .loaded {
            // Trigger the load if the UI module entered the background or the thread is not loaded yet
            containerViewModel?.shouldRefreshThread = false
            
            await reloadThread(with: updatedThread.id)
            // If the thread is not loaded, we don't want to update the view. It will be updated once the thread is loaded via `onThreadUpdated(_:)`.
            flowContinues = false
            return
        } else if updatedThread?.state == .ready || updatedThread?.state != .closed {
            // Hide the loading overlay if the thread is ready or not closed
            await containerViewModel?.hideOverlay()
        }
        
        // Store the thread name to be able to display it in the update thread name textfield
        self.threadName = updatedThread?.name ?? ""
    }
    
    @MainActor
    func updateLiveChatThread(_ updatedThread: CXoneChatUI.ChatThread?, flowContinues: inout Bool) async {
        LogManager.trace("Updating thread for live chat channel configuration")
        
        if !chatProvider.state.isChatAvailable {
            // If the chat is not available yet, we don't want to update the thread view at all
            flowContinues = false
            return
        } else if let updatedThread, containerViewModel?.shouldRefreshThread == true {
            // Trigger the load if the UI module entered the background or the thread is not loaded yet
            containerViewModel?.shouldRefreshThread = false
            
            await reloadThread(with: updatedThread.id)
            // If the thread is not loaded, we don't want to update the view. It will be updated once the thread is loaded via `onThreadUpdated(_:)`.
            flowContinues = false
            return
        } else if updatedThread?.state == .closed, !isEndConversationShown {
            // Show end conversation view when the state is `.closed` and only if it is not already shown
            await showEndConversation()
        } else if !isEndConversationShown, [.ready, .closed].contains(updatedThread?.state) == false, updatedThread?.positionInQueue == nil {
            // Show loading before the BE sends position in queue
            await containerViewModel?.showLoading(message: localization.commonLoading)
            // If the thread is not ready and position in queue is not set, we want to show loading overlay
            flowContinues = false
            return
        } else if updatedThread?.state == .ready || (updatedThread?.state != .closed && updatedThread?.positionInQueue != nil), !isEndConversationShown {
            // Hide the loading overlay if the thread is ready or position in queue is set and EndConversation view is not being shown
            await containerViewModel?.hideOverlay()
        }
        
        handleLivechatPositionInQueueVisibility()
    }
    
    @MainActor
    func reloadThread(with id: UUID) async {
        LogManager.trace("Recovering thread")
    
        await containerViewModel?.showLoading(message: localization.commonLoading)
        
        do {
            try await chatProvider.threads.load(with: id)
        } catch {
            error.logError()
            
            self.alertType = .connectionErrorAlert(localization: self.localization) {
                Task { @MainActor [weak self] in
                    await self?.containerViewModel?.disconnect()
                }
            }
        }
        
        await containerViewModel?.hideOverlay()
    }
    
    @MainActor
    func handleChatReadyState(for mode: ChatMode) async throws {
        switch mode {
        case .singlethread, .liveChat:
            try await handleSingleThreadAndLivechatReadyState()
        case .multithread:
            await handleMultithreadReadyState()
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
            await updateThread(with: ChatThreadMapper.map(from: thread))
        } else if let threadProvider = try await containerViewModel?.createThread() {
            await updateThread(with: ChatThreadMapper.map(from: threadProvider.chatThread))
        } else {
            LogManager.trace("New thread was not created because customer cancelled a prechat survey -> disconnecting")
            
            await containerViewModel?.disconnect()
        }
    }
    
    @MainActor
    func handleMultithreadReadyState() async {
        if let thread, let sdkThread = chatProvider.threads.get().first(where: { $0.id == thread.id }) {
            // Update the thread only if it exists and is in the `.pending` or `.loaded` state.
            // If the state is `.pending`, we want to update the with the locally created thread
            // If the state is `.loaded`, the `updateThread(with:)` triggers thread recover.
            // If the state is `.ready`, or `.closed`, it will be handled via the `onThreadUpdated(_:)` method.
            if [.pending, .loaded].contains(sdkThread.state) {
                await updateThread(with: ChatThreadMapper.map(from: sdkThread))
            }
        } else {
            LogManager.error("Unable to get thread")
            
            await containerViewModel?.hideOverlay()
            
            alertType = .connectionErrorAlert(localization: localization) {
                Task { @MainActor [weak self] in
                    await self?.containerViewModel?.disconnect()
                }
            }
        }
    }
    
    func setAdditionalCustomFieldsIfNeeded(for thread: ChatThread) async {
        guard let additionalFields = containerViewModel?.chatConfiguration.additionalContactCustomFields, !additionalFields.isEmpty else {
            return
        }
        guard didSetAdditionalCustomFields == false else {
            return
        }
        
        didSetAdditionalCustomFields = true
        
        do {
            LogManager.trace("Setting additional contact custom fields")

            try await chatProvider.threads.customFields.set(additionalFields, for: thread.id)
        } catch {
            error.logError()
        }
    }
    
    @MainActor
    func handleLivechatPositionInQueueVisibility() {
        // To be able to show numeric position in queue, chat needs to be available
        guard chatProvider.state.isChatAvailable else {
            // show the position in queue without information about the position in queue
            self.positionInQueue = .min
            return
        }
        guard let thread else {
            // The thread is `nil` so it is initializing -> can present the position in queue without information about the position in queue
            positionInQueue = .min
            return
        }
        
        if thread.state == .closed {
            // The thread is closed, don't show position in queue
            self.positionInQueue = nil
        } else if let positionInQueue = thread.positionInQueue, thread.assignedAgent == nil {
            // Set position in queue if it's set but no agent is assigned
            self.positionInQueue = positionInQueue
        } else if thread.assignedAgent == nil && thread.lastAssignedAgent == nil {
            // No agent assigned yet -> show the position in queue without information about the position in queue
            self.positionInQueue = .min
        } else {
            // An agent is assigned to the thread, hide the position in queue view
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
                icon: Asset.ChatThread.editPrechatCustomFields) {
                    Task { @MainActor [weak self] in
                        await self?.onEditPrechatField()
                    }
                }
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
            ) {
                Task { @MainActor [weak self] in
                    guard let self else {
                        return
                    }
                    
                    if thread?.state == .closed {
                        await self.showEndConversation()
                    } else {
                        self.alertType = .endConversation(localization: self.localization) {
                            Task { @MainActor in
                                await self.onEndConversation()
                            }
                        }
                    }
                }
            }
    }
}
