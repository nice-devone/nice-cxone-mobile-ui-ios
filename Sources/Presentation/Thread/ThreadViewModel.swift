//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//
// swiftlint:disable file_length

import Combine
import CXoneChatSDK
import SwiftUI

@MainActor
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
    /// Attachments staged for the next message. Owned here rather than by `MessageInputView` because
    /// the strip that renders them lives in `ChatView`'s scroll content, so both need the same source.
    @Published var attachments = [AttachmentItem]()
    @Published var isSendingMessage = false
    @Published var isEditingThreadName = false
    @Published var threadName: String = ""
    @Published var positionInQueue: Int?

    let attachmentRestrictions: AttachmentRestrictions

    weak var containerViewModel: ChatContainerViewModel?

    var isShowingInactivityPopup = false

    var isLiveChat: Bool {
        chatProvider.mode == .liveChat
    }
    var isMultithread: Bool {
        chatProvider.mode == .multithread
    }
    var alertType: ChatAlertType? {
        get { containerViewModel?.alertType }
        set { containerViewModel?.alertType = newValue }
    }
    /// Forwards to the container rather than storing locally - the survey can be active
    /// while this view model doesn't exist yet (thread list) or gets replaced (switching threads),
    /// so only container-owned state survives every path that needs to observe it.
    var isShowingSatisfactionSurvey: Bool {
        get { containerViewModel?.isSatisfactionSurveyActive ?? false }
        set { containerViewModel?.isSatisfactionSurveyActive = newValue }
    }

    private let chatProvider: ChatProvider

    private var didSetAdditionalCustomFields = false
    private var isEndConversationShown = false
    /// Bumped every time `showEndConversation()` installs an overlay, even when `isEndConversationShown`
    /// was already `true` - a plain boolean can't tell "still showing what I put up" apart from
    /// "was showing something, got replaced, and a fresh one just went up" once the flag has settled
    /// back to `true` in both cases. `reloadThread(with:)` snapshots this to detect the second case.
    private var endConversationInstallGeneration = 0
    private var isThreadPermanentlyClosed = false
    /// Set only when `handleSingleThreadAndLivechatReadyState` actually skips the create-thread branch
    /// for a closed thread because a survey is active - not derived from `thread.state == .closed` alone,
    /// since a thread can also close through the ordinary CSAT flow without ever being deferred.
    private var didDeferClosedThreadRecovery = false
    /// A survey this view model's own event stream delivered, kept until the next ready state consumes it.
    ///
    /// The SDK sends a recovered survey just before `.chatUpdated(.ready)`, but the container presents it from a
    /// separate stream - so this view model can reach the ready state before `isShowingSatisfactionSurvey` is set.
    private var receivedSatisfactionSurvey: SatisfactionSurvey?
    private var eventTask: Task<Void, Never>?
    private var taskOnAppear: Task<Void, Never>?

    // MARK: - Init

    init(
        thread: CXoneChatUI.ChatThread?,
        containerViewModel: ChatContainerViewModel
    ) {
        self.thread = thread
        self.containerViewModel = containerViewModel
        self.chatProvider = containerViewModel.chatProvider
        self.attachmentRestrictions = AttachmentRestrictions.map(from: chatProvider.connection.channelConfiguration.fileRestrictions)
    }

    deinit {
        let task = eventTask
        task?.cancel()
    }

    // MARK: - Methods

    func onAppear() {
        guard taskOnAppear == nil else {
            return
        }

        self.taskOnAppear = Task { [weak self] in
            guard let self else {
                return
            }

            LogManager.trace("Chat view appeared")

            // Force clean event subscription to handle iOS 16 rapid lifecycle
            self.stopObservingEvents()
            self.startObservingEvents()

            await self.updateThread(with: self.thread)

            // Cleared before the survey below, whose presentation can wait as long as a form stays open - `onDisappear()`
            // skips its cleanup while this is set, so a thread switch meanwhile would leave this view model observing events.
            self.taskOnAppear = nil

            // A survey that arrived while another thread (or the thread list) was on screen waits for this one
            await self.containerViewModel?.showPendingSatisfactionSurveyIfNeeded(for: self.thread?.id)
        }
    }

    func onDisappear() {
        guard taskOnAppear == nil else {
            return
        }

        LogManager.trace("Chat view disappeared")

        stopObservingEvents()
    }

    func resetStaleState() {
        LogManager.trace("Resetting stale state")
        
        self.thread = nil
        self.messageGroups = []
        self.isInputEnabled = false
        self.isThreadClosed = false
        self.hasMoreMessagesToLoad = true
        self.typingAgent = nil
        self.isUserTyping = false
        self.attachments = []
        self.isSendingMessage = false
        self.isEditingThreadName = false
        self.threadName = ""
        self.positionInQueue = nil
        self.isShowingInactivityPopup = false
        // Forwards to containerViewModel.isSatisfactionSurveyActive, not a local field - safe here
        // because the only caller (createThread()) already calls hideOverlay() first.
        self.isShowingSatisfactionSurvey = false
        self.didSetAdditionalCustomFields = false
        self.isEndConversationShown = false
        self.isThreadPermanentlyClosed = false
        self.didDeferClosedThreadRecovery = false
        self.receivedSatisfactionSurvey = nil
    }
}

// MARK: - Actions

extension ThreadViewModel {

    /// Re-runs the thread update flow if a recovery was deferred while a satisfaction survey was active.
    ///
    /// A `.loaded` update arriving during an active survey latches `containerViewModel.shouldRefreshThread`
    /// rather than losing the trigger, since `.loaded` itself isn't sticky - but nothing then re-checks it
    /// until the next server-driven thread update, which may never arrive. Call this after the survey is
    /// dismissed so a deferred recovery actually runs instead of leaving the thread in a stale `.loaded` state.
    @MainActor
    func recoverPendingRefreshIfNeeded() async {
        guard containerViewModel?.shouldRefreshThread == true else {
            return
        }

        await updateThread(with: thread)
    }

    /// Re-runs the closed-thread ready-state flow deferred while a satisfaction survey kept a
    /// recovered closed thread on screen (see `handleSingleThreadAndLivechatReadyState`'s
    /// `isShowingSatisfactionSurvey` escape hatch). Live Chat has its own path via
    /// `showEndConversation()`; this covers Messaging, where dismissing the survey must still
    /// create a new conversation the way `.chatUpdated(.ready)` would have if the survey hadn't
    /// deferred it.
    ///
    /// Gated on `didDeferClosedThreadRecovery` rather than `thread.state == .closed` alone - a thread
    /// closed by the ordinary CSAT flow (agent closes the conversation, survey arrives after) reaches
    /// this same closed state without ever being deferred, and re-driving the ready-state flow for it
    /// would destructively call `createThread()` on an archived transcript the user is still reading.
    ///
    /// - Returns: `true` if a deferred recovery was actually taken over (regardless of whether it
    ///   succeeded, failed, or the user cancelled the pre-chat form) - the caller must not also run
    ///   `recoverPendingRefreshIfNeeded()` in that case. `createThread()` failing or being cancelled
    ///   still leaves the session on a screen this method chose (an error alert or a disconnect), and
    ///   `updateSinglethreadThread` has no chat-availability guard, so re-driving a load on top of that
    ///   would fire a spurious network call against a chat that may already be disconnected.
    @MainActor
    func recoverClosedThreadIfNeeded() async -> Bool {
        guard didDeferClosedThreadRecovery, thread?.state == .closed else {
            return false
        }

        didDeferClosedThreadRecovery = false
        // A `.loaded`-then-`.closed` relatch while the survey stayed active can leave this set
        // alongside the deferral - taking over here means the caller won't drain it afterwards
        // (see `- Returns` above), so an untouched flag would fire an unwanted `reloadThread()`
        // against whatever thread this recovery leaves behind, success or not.
        containerViewModel?.shouldRefreshThread = false

        do {
            try await handleChatReadyState(for: chatProvider.mode)
        } catch {
            error.logError()

            alertType = .connectionErrorAlert { [weak self] in
                Task { @MainActor in
                    await self?.containerViewModel?.disconnect()
                }
            }
        }

        return true
    }

    /// Clears a `didDeferClosedThreadRecovery` deferral that no longer applies to the thread's current
    /// state - e.g. it was latched while the thread was `.closed`, but a later update moved it to
    /// `.loaded` before this dismissal, so neither `recoverClosedThreadIfNeeded()` (needs `.closed`) nor
    /// the Live Chat branch's `clearDeferredClosedThreadRecovery()` (needs `chatProvider.mode == .liveChat`)
    /// ran to consume it. Left set, a later *ordinary* CSAT-flow closure - never actually deferred - would
    /// be mistaken for one on its own dismissal and incorrectly call `createThread()`.
    ///
    /// Deliberately narrower than `clearDeferredClosedThreadRecovery()`: it does not touch
    /// `shouldRefreshThread`, since the caller still needs that latch intact for `recoverPendingRefreshIfNeeded()`.
    @MainActor
    func clearStaleClosedThreadRecoveryDeferral() {
        didDeferClosedThreadRecovery = false
    }

    /// Drains state latched for a closed thread that Live Chat's `showEndConversation()` handles
    /// directly, without ever going through `recoverClosedThreadIfNeeded()` or `recoverPendingRefreshIfNeeded()`.
    ///
    /// Clears both: `didDeferClosedThreadRecovery`, since `handleSingleThreadAndLivechatReadyState` sets it
    /// for both singlethread and Live Chat alike and it would otherwise survive to the next survey; and
    /// `shouldRefreshThread`, since a stray `.loaded` update latched it for an unrelated reason (e.g. the app
    /// returning to the foreground) - if left set, `dismissSatisfactionSurvey()`'s unconditional trailing call
    /// to `recoverPendingRefreshIfNeeded()` would call `reloadThread(with:)` right after `showEndConversation()`,
    /// replacing the just-shown End Conversation overlay with the loading overlay.
    @MainActor
    func clearDeferredClosedThreadRecovery() {
        didDeferClosedThreadRecovery = false
        containerViewModel?.shouldRefreshThread = false
    }

    @MainActor
    func onEditPrechatField() async {
        LogManager.trace("Trying to edit prechat custom fields")

        guard let thread else { 
            LogManager.error("Unexpected nil thread")
            return
        }
        guard hasPrechatCustomFields, let prechatCustomFields = chatProvider.threads.preChatSurvey?.customFields else {
            LogManager.error(.unableToParse("prechatCustomFields"))
            return
        }

        let customFields = prechatCustomFields.map { definition in
            FormCustomFieldTypeMapper.map(definition, with: chatProvider.threads.customFields.get(for: thread.id))
        }

        guard let answers = await containerViewModel?.showPrechatSurveyForm(title: L10n.Alert.EditPrechatCustomFields.title, fields: customFields) else {
            LogManager.trace("The customer canceled the edit prechat custom fields form")
            return
        }

        do {
            try await chatProvider.threads.customFields.set(answers, for: thread.id)
        } catch {
            error.logError()
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

            self.alertType = .genericError
        }
    }

    /// Brings End Conversation back after a satisfaction survey that replaced it is dismissed.
    ///
    /// A transient overlay (e.g. a reconnect's loading overlay) can claim the slot while the survey's hide waits out its
    /// dismissal animation, and `showEndConversation()` refuses an occupied slot - so this keeps retrying until the slot
    /// is free. It stops once End Conversation is shown (here or by a later closed-thread update), a new survey takes
    /// the slot, the thread is no longer closed (e.g. replaced by a new one), the chat is disconnecting, or a teardown
    /// (disconnect, going offline, closing the chat) has begun - which may still be awaiting its own overlay hide.
    @MainActor
    func restoreEndConversation() async {
        // The survey replaced the End Conversation overlay, so its "already shown" state no longer holds
        isEndConversationShown = false

        let teardownGeneration = containerViewModel?.satisfactionSurveyTeardownGeneration

        while !isEndConversationShown,
              thread?.state == .closed,
              containerViewModel?.isSatisfactionSurveyActive == false,
              containerViewModel?.disconnecting == false,
              containerViewModel?.satisfactionSurveyTeardownGeneration == teardownGeneration {
            await showEndConversation()

            guard !isEndConversationShown else {
                return
            }

            await Task.sleep(seconds: 0.2)
        }
    }

    @MainActor
    func showEndConversation() async {
        guard let thread else {
            LogManager.error("Unexpected nil thread")
            return
        }

        // `showOverlay` rejects when the slot is taken (e.g. by `reloadThread`'s loading overlay). Bail out
        // before touching the flag and generation, which must only change for an install that happens.
        guard containerViewModel?.overlay == nil else {
            LogManager.warning("Cannot show EndConversation view: another overlay is already being displayed")
            return
        }

        LogManager.trace("Showing EndConversation view")

        self.isEndConversationShown = true
        self.endConversationInstallGeneration += 1

        let isSendTranscriptEnabled = chatProvider.connection.channelConfiguration.isSendTranscriptEnabled
        await containerViewModel?.showOverlay {
            EndConversationView(
                thread: thread,
                isSendTranscriptEnabled: isSendTranscriptEnabled,
                onStartNewChatTapped: {
                    Task { @MainActor in
                        await self.onEndConversationStartChatTapped()
                    }
                },
                onBackToConversationTapped: {
                    Task { @MainActor in
                        await self.onEndConversationBackTapped()
                    }
                },
                onSendTranscriptTapped: {
                    Task { @MainActor in
                        await self.sendTranscript(fromMenu: false)
                    }
                },
                onCloseChatTapped: {
                    Task { @MainActor in
                        await self.onEndConversationCloseTapped()
                    }
                }
            )
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

            alertType = .connectionErrorAlert { [weak self] in
                Task { @MainActor in
                    await self?.containerViewModel?.disconnect()
                }
            }
        }
    }

    func onSendMessage(_ messageType: ChatMessageType, attachments attachmentsToSend: [AttachmentItem], postback: String? = nil) {
        LogManager.trace("Sending a message")

        guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }

        Task { @MainActor in
            // Set loading state for contextual loading indicator
            self.isSendingMessage = true

            let message: OutboundMessage

            switch messageType {
            case .text(let text):
                message = OutboundMessage(text: text, attachments: attachmentsToSend.compactMap(AttachmentItemMapper.map), postback: postback)
            case .audio(let item):
                message = OutboundMessage(text: "", attachments: [AttachmentItemMapper.map(item)], postback: postback)
            default:
                LogManager.info("Trying to send message of unexpected type - \(messageType)")
                self.isSendingMessage = false
                return
            }

            do {
                try await threadProvider.send(message)

                // Clear loading state after successful send
                self.isSendingMessage = false
            } catch {
                error.logError()

                // Clear loading state on error
                self.isSendingMessage = false

                switch error {
                case CXoneChatError.invalidFileType:
                    self.alertType = .invalidAttachmentType
                case CXoneChatError.invalidFileSize:
                    self.alertType = .invalidAttachmentSize(allowedFileSize: self.attachmentRestrictions.allowedFileSize)
                default:
                    self.alertType = .genericError
                }
            }
        }
    }

    @MainActor
    func loadMoreMessages() async {
        LogManager.trace("Trying to load more messages")
        
        guard let thread else {
            LogManager.error("Unexpected nil thread")
            
            return
        }
        guard thread.hasMoreMessagesToLoad else {
            LogManager.warning("The thread does not have more messages to load")
            
            hasMoreMessagesToLoad = false
            return
        }
        guard let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unable to get the thread's provider")
            
            return
        }
        
        do {
            try await threadProvider.loadMoreMessages()
        } catch {
            error.logError()
            
            alertType = .genericError
        }
    }

    func onRichMessageElementSelected(element: RichMessageSubElementType) {
        LogManager.trace("Did select rich content message")

        let textToSend = switch element {
        case .button(let entity):
            entity.title
        case .timeSlot(let entity):
            entity.formattedDescription
        }

        onSendMessage(.text(textToSend), attachments: [], postback: element.postback)
    }

    func onUserTyping() {
        LogManager.trace("User has \(isUserTyping ? "started" : "ended") typing")

        guard let thread, let threadProvider = try? chatProvider.threads.provider(for: thread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }

        Task { @MainActor in
            do {
                try await threadProvider.reportTypingStart(self.isUserTyping)
            } catch {
                error.logError()

                self.alertType = .genericError
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
        await containerViewModel?.showLoading()
        
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
            
            self.alertType = .connectionErrorAlert { [weak self] in
                Task { @MainActor in
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
        } else if let thread {
            // Otherwise check current thread state
            self.isThreadClosed = thread.state == .closed
        } else {
            self.isThreadClosed = false
        }

        if isThreadClosed, !attachments.isEmpty {
            // A closed thread replaces the input bar with the archived-conversation notice and hides the
            // attachment strip, so anything staged would linger unreachable — impossible to send or
            // remove, and shown again if the thread ever becomes writable.
            LogManager.trace("Discarding staged attachments because the thread is closed")

            attachments.removeAll()
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
    
    @MainActor
    func sendTranscript(fromMenu: Bool) async {
        LogManager.trace("Send chat transcript")
        
        guard let thread else {
            LogManager.error("Unexpected nil thread")
            return
        }
        
        // Hide any overlay (just to be clear)
        await containerViewModel?.hideOverlay()
        
        // Present the form
        guard let sentSuccessfully = await containerViewModel?.showSendTranscriptForm(for: thread) else {
            LogManager.trace("User cancelled send transcript form")
            return
        }
        // Show alert dialog with either success or failure result
        alertType = .sendTranscript(isSuccess: sentSuccessfully) { [weak self] in
            // Don't show end conversation if the feature was triggered from navigation bar's menu
            guard !fromMenu else {
                return
            }
            
            Task { @MainActor in
                await self?.showEndConversation()
            }
        }
    }
}

// MARK: - Event Handling

private extension ThreadViewModel {

    func startObservingEvents() {
        guard eventTask == nil else {
            return
        }
        
        eventTask = Task { [weak self] in
            guard let self else {
                return
            }
            
            for await event in chatProvider.events() {
                await self.handle(event: event)
            }
        }
    }

    func stopObservingEvents() {
        eventTask?.cancel()
        eventTask = nil
    }

    @MainActor
    func handle(event: ChatEvent) async {
        switch event {
        case .chatUpdated(let state, let mode):
            do {
                switch state {
                case .ready:
                    try await handleChatReadyState(for: mode)
                default:
                    break
                }
            } catch {
                error.logError()

                alertType = .connectionErrorAlert {
                    Task { @MainActor in
                        await self.containerViewModel?.disconnect()
                    }
                }
            }

        case .threadUpdated(let updatedThread):
            // 1. When thread reference is nil (which happens after creating a new thread following a closed
            // conversation), accept any incoming thread update to properly display the new conversation.
            // 2. Only update if the incoming thread is the one currently in use.
            guard thread == nil || thread?.id == updatedThread.id else {
                LogManager.trace("Ignoring thread update - the thread is not the current one")
                return
            }
            let mappedThread = ChatThreadMapper.map(from: updatedThread)
            announceNewMessages(old: self.thread, new: mappedThread)
            
            await updateThread(with: mappedThread)

        case .agentTyping(let isTyping, let agent, let threadId):
            guard threadId == thread?.id else {
                return
            }
            LogManager.trace("Agent \(isTyping ? "started" : "ended") typing")
            typingAgent = isTyping ? ChatUserMapper.map(from: agent) : nil

        case .proactiveActionReceived(.satisfactionSurvey(let survey)) where chatProvider.mode != .multithread:
            // Presented by the container - only remembered here for the ready-state decision that may follow it
            receivedSatisfactionSurvey = survey

        default:
            break
        }
    }
}

// MARK: - Private methods

private extension ThreadViewModel {

    /// Whether the channel's pre-chat survey defines any custom fields the customer can edit.
    var hasPrechatCustomFields: Bool {
        chatProvider.threads.preChatSurvey?.customFields.isEmpty == false
    }

    /// Whether a survey is showing, or was received on this view model's stream and hasn't reached the container yet.
    ///
    /// Consumes `receivedSatisfactionSurvey`: the recovered survey precedes the ready state it belongs to, and one
    /// left over would keep a later, unrelated ready state from replacing a closed thread.
    func hasSatisfactionSurveyForReadyState() -> Bool {
        let receivedSurvey = receivedSatisfactionSurvey
        receivedSatisfactionSurvey = nil

        let isSurveyOnItsWay = receivedSurvey != nil && receivedSurvey != containerViewModel?.lastActivatedSatisfactionSurvey

        return isShowingSatisfactionSurvey || isSurveyOnItsWay
    }

    /// Whether a singlethread or multithread thread update should trigger a thread reload — the UI module returned
    /// from the background or the thread is not loaded yet — and no recovery is already in progress
    /// and no satisfaction survey is being shown.
    func shouldRecoverThread(_ updatedThread: CXoneChatUI.ChatThread?) -> Bool {
        (containerViewModel?.shouldRefreshThread == true || updatedThread?.state == .loaded)
            && containerViewModel?.isRecoveringThread == false
            && !isShowingSatisfactionSurvey
    }

    @MainActor
    func updateThread(with updatedThread: CXoneChatUI.ChatThread?) async {
        LogManager.trace("updateThread called - state: \(String(describing: updatedThread?.state)), messages: \(updatedThread?.messages.count ?? 0)")

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
            .map(ChatMessageMapper.map)
            .groupMessages(interval: MessageGroup.defaultGroupingInterval)
        ?? []

        // Log the number of messages grouped and set additional custom fields if needed
        if let updatedThread {
            LogManager.trace("Message grouping complete: \(updatedThread.messages.count) messages grouped into \(messageGroups.count) groups")
            // Set additional case custom fields for the thread
            await setAdditionalCustomFieldsIfNeeded(for: updatedThread)
            // Mark the thread as read by a customer
            do {
                try await markThreadAsReadIfNeeded(updatedThread)
            } catch {
                // This feature is not a mandatory one so we just log the error
                error.logError()
            }

        }
        // Update the state if there are more messages to load
        hasMoreMessagesToLoad = updatedThread?.hasMoreMessagesToLoad ?? false
        LogManager.trace("updateThread completed successfully")
    }
    
    @MainActor
    func updateSinglethreadThread(_ updatedThread: CXoneChatUI.ChatThread?, flowContinues: inout Bool) async {
        LogManager.trace("Updating thread for singlethread channel configuration")

        if isShowingSatisfactionSurvey, updatedThread?.state == .loaded {
            // `.loaded` is not sticky like `shouldRefreshThread` - without latching it here, skipping
            // recovery while the survey is open loses the trigger for good, since nothing re-drives it.
            containerViewModel?.shouldRefreshThread = true
        }

        if shouldRecoverThread(updatedThread), let updatedThread {
            // Trigger the load if the UI module entered the background or the thread is not loaded yet
            // Skip if recovery is already in progress to prevent duplicate recovery attempts on iOS 16
            containerViewModel?.shouldRefreshThread = false
            containerViewModel?.isRecoveringThread = true

            await reloadThread(with: updatedThread.id)
            // Note: isRecoveringThread flag is reset inside reloadThread() before triggering UI update
            // If the thread is not loaded, we don't want to update the view. It will be updated once the thread is loaded via `onThreadUpdated(_:)`.
            flowContinues = false
            return
        } else if let state = updatedThread?.state,
                  state != .closed,
                  !isShowingSatisfactionSurvey {
            // Hide the loading overlay if the thread is not closed and a satisfaction survey is not being shown
            await containerViewModel?.hideOverlay()
        }
    }

    @MainActor
    func updateMultithreadThread(_ updatedThread: CXoneChatUI.ChatThread?, flowContinues: inout Bool) async {
        LogManager.trace("Updating thread for multithread channel configuration")

        if isShowingSatisfactionSurvey, updatedThread?.state == .loaded {
            // `.loaded` is not sticky like `shouldRefreshThread` - without latching it here, skipping
            // recovery while the survey is open loses the trigger for good, since nothing re-drives it.
            containerViewModel?.shouldRefreshThread = true
        }

        if shouldRecoverThread(updatedThread), let updatedThread {
            // Trigger the load if the UI module entered the background or the thread is not loaded yet
            // Skip if recovery is already in progress to prevent duplicate recovery attempts on iOS 16
            containerViewModel?.shouldRefreshThread = false
            containerViewModel?.isRecoveringThread = true
            
            await reloadThread(with: updatedThread.id)
            // Note: isRecoveringThread flag is reset inside reloadThread() before triggering UI update
            // If the thread is not loaded, we don't want to update the view. It will be updated once the thread is loaded via `onThreadUpdated(_:)`.
            flowContinues = false
            return
        } else if let state = updatedThread?.state,
                  state != .closed,
                  !isShowingSatisfactionSurvey {
            // Hide the loading overlay if the thread is not closed and a satisfaction survey is not being shown
            await containerViewModel?.hideOverlay()
        }
        
        // Store the thread name to be able to display it in the update thread name textfield
        self.threadName = updatedThread?.name ?? ""
    }
    
    @MainActor
    func updateLiveChatThread(_ updatedThread: CXoneChatUI.ChatThread?, flowContinues: inout Bool) async {
        LogManager.trace("Updating thread for live chat channel configuration")
        
        guard chatProvider.state.isChatAvailable else {
            // If the chat is not available yet, we don't want to update the thread view at all
            flowContinues = false
            return
        }
        
        let shouldRecover = containerViewModel?.shouldRefreshThread == true
            && isShowingInactivityPopup == false
            && !isShowingSatisfactionSurvey
            && containerViewModel?.isRecoveringThread == false
        if shouldRecover, let updatedThread {
            // Trigger the load if the UI module entered the background or the thread is not loaded yet
            // Skip if recovery is already in progress to prevent duplicate recovery attempts on iOS 16
            containerViewModel?.shouldRefreshThread = false
            containerViewModel?.isRecoveringThread = true

            await reloadThread(with: updatedThread.id)
            // Note: isRecoveringThread flag is reset inside reloadThread() before triggering UI update
            // If the thread is not loaded, we don't want to update the view. It will be updated once the thread is loaded via `onThreadUpdated(_:)`.
            flowContinues = false
            return
        } else {
            switch Self.resolveLiveChatOverlay(
                for: updatedThread,
                isEndConversationShown: isEndConversationShown,
                isShowingInactivityPopup: isShowingInactivityPopup,
                isShowingSatisfactionSurvey: isShowingSatisfactionSurvey
            ) {
            case .showEndConversation:
                await showEndConversation()
            case .showLoading:
                await containerViewModel?.showLoading()
                // If the thread is not ready and position in queue is not set, we want to show loading overlay
                flowContinues = false
                return
            case .hideOverlay:
                await containerViewModel?.hideOverlay()
            case .noChange:
                break
            }
        }
        
        handleLivechatPositionInQueueVisibility()
    }
    
    @MainActor
    func reloadThread(with id: String) async {
        LogManager.trace("Recovering thread with id: \(id)")

        let endConversationGenerationBeforeReload = endConversationInstallGeneration

        await containerViewModel?.showLoading()

        do {
            try await chatProvider.threads.load(with: id)
        } catch {
            error.logError()
            self.alertType = .connectionErrorAlert { [weak self] in
                Task { @MainActor in
                    await self?.containerViewModel?.disconnect()
                }
            }
        }

        // A satisfaction survey may have arrived and taken the overlay slot during the network
        // round trip above - don't tear it down for a recovery that started before it existed.
        // `isShowingSatisfactionSurvey` alone can't see a survey that arrived *and was dismissed*
        // within this same await, since dismissing it already installed a fresh End Conversation
        // overlay before clearing the flag. A plain `isEndConversationShown` snapshot isn't enough
        // either: if it was already `true` before this call started, dismissSatisfactionSurvey()
        // installing another one during the await leaves the flag unchanged at `true == true`, so
        // comparing the boolean can't tell "still showing what I put up" from "got replaced with a
        // fresh one." Comparing `endConversationInstallGeneration` instead catches both directions -
        // any new call to `showEndConversation()` during the await bumps it regardless of the flag's
        // starting value, so this recovery only hides the overlay when nothing else has claimed it.
        if !isShowingSatisfactionSurvey && endConversationInstallGeneration == endConversationGenerationBeforeReload {
            await containerViewModel?.hideOverlay()
        }

        // Reset the recovery flag to allow future recovery attempts
        containerViewModel?.isRecoveringThread = false
    }
    
    func handleChatReadyState(for mode: ChatMode) async throws {
        switch mode {
        case .singlethread, .liveChat:
            try await handleSingleThreadAndLivechatReadyState()
        case .multithread:
            await handleMultithreadReadyState()
        }
    }
    
    func handleSingleThreadAndLivechatReadyState() async throws {
        // A recovered closed thread carrying an active survey must stay on screen so the survey can be
        // dismissed and End Conversation shown - otherwise this falls into the create-thread branch below,
        // which calls createThread() -> resetStaleState(), silently discarding the survey and the thread.
        if let thread = chatProvider.threads.get().first, thread.state != .closed || hasSatisfactionSurveyForReadyState() {
            if thread.state == .closed {
                didDeferClosedThreadRecovery = true
            }

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
            
            alertType = .connectionErrorAlert { [weak self] in
                Task { @MainActor in
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
    
    func markThreadAsReadIfNeeded(_ thread: ChatThread) async throws {
        guard thread.messages.last?.isSeenByCustomer != true else {
            // The thread is already marked as read
            return
        }
        
        let provider = try chatProvider.threads.provider(for: thread.id)
        
        LogManager.trace("Marking thread as read")
        
        try await provider.markRead()
    }
    
    @MainActor
    func handleLivechatPositionInQueueVisibility() {
        self.positionInQueue = Self.resolvePositionInQueue(
            for: thread,
            isChatAvailable: chatProvider.state.isChatAvailable
        )
    }

    func announceNewMessages(old oldThread: CXoneChatUI.ChatThread?, new newThread: CXoneChatUI.ChatThread) {
        // Get message counts
        let oldCount = oldThread?.messages.count ?? 0
        let newCount = newThread.messages.count

        // Skip if no new messages
        guard newCount > oldCount else {
            return
        }

        // Get the last message (most recent)
        guard let lastMessage = newThread.messages.last else {
            return
        }

        // Map the message
        let mappedMessage = ChatMessageMapper.map(lastMessage)

        // Only announce if it's from an agent (not user's own message)
        guard mappedMessage.isUserAgent else {
            return
        }

        // Announce with polite delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LogManager.trace("Announcing new incoming message")
            A11y.announce(A11y.Announcement.Message.incoming)
        }
    }
}

// MARK: - Menu builder

extension ThreadViewModel {

    var menu: MenuBuilder {
        MenuBuilder()
            .add(
                if: !isThreadClosed && isMultithread,
                name: L10n.Chat.MenuOption.updateName,
                icon: Asset.ChatThread.editThreadName
            ) {
                Task { @MainActor in
                    self.onEditThreadName()
                }
            }
            .add(
                if: !isThreadClosed && hasPrechatCustomFields,
                name: L10n.Alert.EditPrechatCustomFields.title,
                icon: Asset.ChatThread.editPrechatCustomFields
            ) {
                Task { @MainActor in
                    await self.onEditPrechatField()
                }
            }
            .add(
                if: thread?.state != .pending && chatProvider.connection.channelConfiguration.isSendTranscriptEnabled,
                name: L10n.Chat.MenuOption.sendTranscript,
                icon: Asset.sendTranscript
            ) {
                Task { @MainActor in
                    await self.sendTranscript(fromMenu: true)
                }
            }
            .add(
                if: isLiveChat,
                name: L10n.Chat.MenuOption.endConversation,
                icon: Asset.close,
                role: .destructive
            ) { [weak self] in
                Task { @MainActor in
                    guard let self else {
                        return
                    }
                    
                    if self.thread?.state == .closed {
                        await self.showEndConversation()
                    } else {
                        self.alertType = .endConversation { [weak self] in
                            Task { @MainActor in
                                await self?.onEndConversation()
                            }
                        }
                    }
                }
            }
    }
}

// MARK: - Overlay Visibility

extension ThreadViewModel {

    /// Decides what should happen to the live chat overlay for a thread update.
    ///
    /// A bot-held contact is checked before the loading branch and resolves to ``LiveChatOverlayAction/hideOverlay``
    /// rather than merely declining to show it. Such a contact is never queued - no `SetPositionInQueue` arrives -
    /// and stays below `.ready` until the bot's first message, so no later update would dismiss an overlay that a
    /// previous update (or the unconditional `showLoading()` before thread creation) already put up.
    ///
    /// While a satisfaction survey is shown it owns the screen: the end conversation view waits until the survey
    /// is dismissed, and the loading overlay is neither shown over it nor hidden from under it.
    nonisolated static func resolveLiveChatOverlay(
        for thread: CXoneChatUI.ChatThread?,
        isEndConversationShown: Bool,
        isShowingInactivityPopup: Bool,
        isShowingSatisfactionSurvey: Bool
    ) -> LiveChatOverlayAction {
        guard !isShowingSatisfactionSurvey else {
            // The satisfaction survey owns the screen, leave any overlay alone
            return .noChange
        }
        if thread?.state == .closed, !isEndConversationShown {
            // The conversation is over -> hand over to the end conversation view
            return .showEndConversation
        }
        guard !isEndConversationShown else {
            // The end conversation view owns the screen, leave any overlay alone
            return .noChange
        }
        if thread?.isHandledByNonCxone == true {
            // A bot is serving the customer, so neither the queue counter nor the loading overlay applies.
            // The inactivity popup is itself presented as an overlay, so it must never be dismissed from here.
            return isShowingInactivityPopup ? .noChange : .hideOverlay
        }
        if [.ready, .closed].contains(thread?.state) == false, thread?.positionInQueue == nil {
            // Show loading until the backend reports a position in queue
            return .showLoading
        }
        if thread?.state == .ready || (thread?.state != .closed && thread?.positionInQueue != nil), !isShowingInactivityPopup {
            return .hideOverlay
        }

        return .noChange
    }

    /// Resolves which position-in-queue value the overlay should display.
    ///
    /// Extracted as a pure function so the queue-visibility rules can be unit tested without standing up a full
    /// view model and chat provider. The result is `nil` to hide the overlay, `.min` to show it without a
    /// concrete number (still initializing / no position known yet), or the concrete position to display.
    ///
    /// Once the customer has been engaged by an agent they are no longer in the queue. This holds for the current
    /// inbox assignee, a previously assigned agent (after unassignment), and the case owner (e.g. restored on
    /// recover) — aligning with the Web Chat SDK behavior.
    nonisolated static func resolvePositionInQueue(for thread: CXoneChatUI.ChatThread?, isChatAvailable: Bool) -> Int? {
        // A closed thread, or one an agent is (or was) associated with, must hide the overlay regardless of
        // chat availability -> these checks take precedence over the `isChatAvailable` guard below.
        if let thread {
            if thread.state == .closed {
                // The thread is closed, don't show position in queue
                return nil
            }

            if thread.isHandledByNonCxone {
                // A bot is handling the contact, so there is no queue to report. After a handover the handler
                // becomes `.cxone` and the agent-association rules below take over, bringing the overlay back
                // until an agent is actually assigned.
                return nil
            }

            let hasAgentAssociation = thread.assignedAgent != nil
                || thread.lastAssignedAgent != nil
                || thread.ownerAssignee != nil
            if hasAgentAssociation {
                // An agent is (or was) associated with the thread, hide the overlay even if a `SetPositionInQueue`
                // event arrives after an unassignment
                return nil
            }
        }
        // To be able to show numeric position in queue, chat needs to be available
        guard isChatAvailable else {
            // Show the overlay without information about the position in queue
            return .min
        }
        guard let thread else {
            // The thread is `nil` so it is initializing -> show the overlay without a concrete position
            return .min
        }
        if let positionInQueue = thread.positionInQueue {
            // No agent has ever been assigned and a concrete position is known -> show it
            return positionInQueue
        }
        // No agent assigned yet -> show the overlay without information about the position in queue
        return .min
    }
}
