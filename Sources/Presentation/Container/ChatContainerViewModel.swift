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

import CXoneChatSDK
import SwiftUI

@MainActor
class ChatContainerViewModel: ObservableObject, Overlayable, AlertableViewModel {

    // MARK: - Properties

    // Every overlay writer shares this one slot - loading, offline, inactivity, End Conversation and the
    // transcript form (through a binding) - and none of them knows about the satisfaction survey. The SDK
    // never re-emits a survey, so once it is installed only its own dismissal or teardown may clear it.
    var overlay: (() -> AnyView)? {
        get { overlayContent }
        set {
            guard newValue != nil || !isSatisfactionSurveyOverlayInstalled else {
                LogManager.trace("Satisfaction survey owns the overlay slot, ignoring request to hide it")
                return
            }

            overlayContent = newValue
        }
    }
    @Published private(set) var overlayContent: (() -> AnyView)?
    @Published var sheet: (() -> AnyView)?
    @Published var isSheetDismissing = false
    @Published var alertType: ChatAlertType?
    @Published var safariURL: IdentifiableURL?
    @Published var isRecoveringThread = false
    // Owned here rather than on `ThreadViewModel` - the survey can be shown while
    // `cachedThreadViewModel` is nil (e.g. on the thread list), and this container outlives
    // every `ThreadViewModel` it creates, so it is the only state that can't silently no-op.
    // Tied to `activeSatisfactionSurvey` via `didSet` so every writer - including
    // `ThreadViewModel.isShowingSatisfactionSurvey`'s forwarding setter - keeps both in sync
    // without having to remember the pairing.
    @Published var isSatisfactionSurveyActive = false {
        didSet {
            if !isSatisfactionSurveyActive {
                activeSatisfactionSurvey = nil
                isSatisfactionSurveyOverlayInstalled = false
            }
        }
    }
    // Set only while the survey's own view sits in the overlay slot, which locks the slot against
    // `overlay = nil` from anyone else. Cleared by `dismissSatisfactionSurvey()` before it hides the survey,
    // and by `isSatisfactionSurveyActive` turning false, so every teardown path releases it first.
    var isSatisfactionSurveyOverlayInstalled = false
    // Belt-and-braces only - the SDK delivers a given thread's survey once and never re-emits it,
    // so this should never actually catch anything. Compared by `==` (prompt, url and thread) rather
    // than identity since `SatisfactionSurvey` has no identifier of its own.
    var activeSatisfactionSurvey: SatisfactionSurvey?
    // The last survey `showSatisfactionSurvey(_:)` took on, kept after it is dismissed. `ThreadViewModel` reads its own
    // event stream, which can reach `.chatUpdated(.ready)` before this container's stream has handled the survey sent
    // just before it - comparing against this tells it whether a survey it received is still on its way here.
    var lastActivatedSatisfactionSurvey: SatisfactionSurvey?
    // Bumped by `tearDownSatisfactionSurvey()`, which every teardown path calls synchronously before awaiting its own
    // `hideOverlay()` - lets work started for the survey (e.g. restoring End Conversation) stop once a teardown has begun.
    var satisfactionSurveyTeardownGeneration = 0
    // The waiting part of handling the latest survey event, run off the event loop. A presentation ends on its own once
    // a teardown clears `isSatisfactionSurveyActive`, so this isn't cancelled - it is kept so the work can be awaited.
    var satisfactionSurveyTask: Task<Void, Never>?
    // Multithread only: surveys for threads the customer wasn't viewing when they arrived, keyed by thread id.
    // Each is shown once its thread is opened (`showPendingSatisfactionSurveyIfNeeded(for:)`); the SDK never
    // re-emits a survey, so this container session is the only place it survives until then.
    // Published so the thread list can mark those threads as unread.
    @Published var pendingSatisfactionSurveys = [String: SatisfactionSurvey]()

    let chatProvider: ChatProvider
    let chatConfiguration: ChatConfiguration
    let presentModally: Bool
    let onDismiss: (() -> Void)?
    /// Invoked instead of the generic connection-error alert when `connect()`'s explicit-PKCE
    /// refresh-grant recovery fails and no further automatic recovery is possible - the host app
    /// must start a new authorization flow rather than let the customer retry a rejected credential.
    let onSessionExpired: (() -> Void)?
    let satisfactionSurveyNotificationScheduler: SatisfactionSurveyNotificationScheduling

    // Used to determine if the chat should be refreshed,
    // for example after when a thread is open but client disconnect via entering background
    var shouldRefreshThread = false
    var threadToOpen: String?
    var disconnecting = false
    var processingDeeplink = false

    private(set) weak var cachedListViewModel: ThreadListViewModel?
    private(set) weak var cachedThreadViewModel: ThreadViewModel?
    // The thread view model whose inactivity popup currently holds the overlay slot - may differ from
    // `cachedThreadViewModel` after a thread switch, so a survey taking the slot must clear this one's flag.
    weak var inactivityPopupOwner: ThreadViewModel?

    // Observe notification taps to navigate to the correct thread
    private var directNavigationToken: NSObjectProtocol?
    // To be able to handle receiving new messages from different thread, it is necessary to cache current thread list
    private var cachedThreadMessageCount = [String: Int]()
    private var eventTask: Task<Void, Never>?
    // Tracks the in-flight `connect()` triggered by `willEnterForeground`, so `didEnterBackground`
    // can cancel it explicitly instead of letting it race to a self-inflicted connection error.
    private var connectTask: Task<Void, Never>?
    
    // MARK: - Init

    init(
        chatProvider: ChatProvider,
        threadToOpen: String? = nil,
        chatConfiguration: ChatConfiguration,
        presentModally: Bool,
        onDismiss: (() -> Void)? = nil,
        onSessionExpired: (() -> Void)? = nil,
        satisfactionSurveyNotificationScheduler: SatisfactionSurveyNotificationScheduling = DefaultSurveyNotificationScheduler()
    ) {
        self.chatProvider = chatProvider
        self.threadToOpen = threadToOpen
        self.chatConfiguration = chatConfiguration
        self.presentModally = presentModally
        self.onDismiss = onDismiss
        self.onSessionExpired = onSessionExpired
        self.satisfactionSurveyNotificationScheduler = satisfactionSurveyNotificationScheduler

        directNavigationToken = NotificationCenter.default.threadDeeplinkObserver { [weak self] notification in
            guard let threadId = notification.userInfo?["threadId"] as? String else {
                LogManager.error("Unable to retrieve threadId from notification")
                return
            }

            Task { @MainActor in
                LogManager.trace("ChatContainerViewModel received notification to navigate directly to thread: \(threadId)")

                if self?.chatProvider.state.isChatAvailable == false {
                    self?.threadToOpen = threadId
                } else {
                    await self?.navigateDirectlyToThread(threadId)
                }
            }
        }
    }

    // MARK: - Methods
    
    @MainActor
    func viewModel(for thread: CXoneChatUI.ChatThread?) -> ThreadViewModel {
        switch (thread, cachedThreadViewModel) {
        case let (.some(new), .some(old)) where old.thread?.id == new.id:
            // if we already have a thread view model for this thread, just use that
            return old

        case let (.none, .some(old)):
            // If we have a thread model and there's no thread requested, it *should*
            // be a recovered single or live chat thread, so use that
            return old

        default:
            // Otherwise, let's create and use a new view model
            LogManager.trace("Creating ThreadViewModel for \(thread?.id.description ?? "no thread")")
            
            let tvm = ThreadViewModel(thread: thread, containerViewModel: self)
            cachedThreadViewModel = tvm
            
            return tvm
        }
    }

    @MainActor
    func threadListViewModel() -> ThreadListViewModel {
        if let cachedListViewModel {
            return cachedListViewModel
        } else {
            LogManager.trace("Creating ThreadListViewModel")
            
            let viewModel = ThreadListViewModel(containerViewModel: self)
            cachedListViewModel = viewModel
            
            return viewModel
        }
    }

    func onAppear() {
        LogManager.trace("View did appear")
        
        guard chatProvider.state == .prepared else {
            LogManager.warning("Chat is in incorrect state (= .\(chatProvider.state)) -> unable to trigger connect")
            return
        }

        startObservingEvents()

        Task { [weak self] in
            // Force dismiss any existing overlays to start clean
            await self?.hideOverlay()

            if self?.chatProvider.state != .connected {
                await self?.connect()
            }
        }
    }

    func onDisappear() {
        LogManager.trace("View did disappear")
        
        // Force dismiss any overlays when view disappears
        Task { @MainActor in
            await self.hideOverlay()
        }

        // Multithread full screen calls this for every push to a thread - in-session navigation, not the chat closing
        // (see the early return below). An open survey stays open across it (its overlay slot is locked, so the hide
        // above leaves it), and its own dismissal later drains any recovery deferred meanwhile.
        let isFullScreenThreadNavigation = chatProvider.state.isChatAvailable
            && !presentModally
            && chatProvider.mode == .multithread
            && cachedThreadViewModel != nil

        // Otherwise the overlay is gone above, so this state must not outlive it - a stale `isSatisfactionSurveyActive`
        // would block `shouldRecover` from consuming a deeplink navigation's `shouldRefreshThread`, and a stale
        // deferral latch would be mistaken for a real one by a later, unrelated survey dismissal.
        if !isFullScreenThreadNavigation {
            tearDownSatisfactionSurvey()
        }

        // Do not continue if chat services are not available
        guard chatProvider.state.isChatAvailable else {
            return
        }
        
        // For multithread presented in full-screen, the `ChatContainerView's `onDisappear` is called when a ThreadView appears
        // and we don't want to trigger removal of the ChatContainerViewModel's delegate and disconnect from the chat services
        if isFullScreenThreadNavigation {
            return
        }
        
        releaseInactivityPopupOwnership()
        disconnecting = true

        stopObservingEvents()

        chatProvider.connection.disconnect()

        // Remove notification tap observer
        if let directNavigationToken {
            NotificationCenter.default.removeObserver(directNavigationToken)
        }

        onDismiss?()
    }
}

// MARK: - Chat Actions

extension ChatContainerViewModel {

    @MainActor
    func connect() async {
        guard chatProvider.state != .connected else {
            LogManager.trace("Skip connecting, already connected")
            return
        }
        
        LogManager.trace("Connecting to chat services")

        disconnecting = false

        do {
            try await chatProvider.connection.connect()
        } catch {
            // Backgrounding cancels this task from `didEnterBackground` while `connect()` is still
            // in flight, which surfaces here as a connection failure even though nothing is actually
            // wrong - the app just isn't in the foreground to see the result anymore. Foregrounding
            // again will trigger a fresh `connect()`, so there is nothing to recover here.
            guard !Task.isCancelled else {
                LogManager.trace("Connect cancelled, most likely by backgrounding mid-connect -> not surfacing an error")
                return
            }

            error.logError()

            // Connection failed, so any survey or inactivity popup the previous session left showing is gone with it.
            tearDownSatisfactionSurvey()
            releaseInactivityPopupOwnership()
            await hideOverlay()

            if case CXoneChatError.invalidRefreshToken = error, let onSessionExpired {
                LogManager.trace("Explicit OAuth refresh-grant recovery failed -> a new authorization flow is required")

                onSessionExpired()

                return
            }

            alertType = .connectionErrorAlert { [weak self] in
                Task {
                    await self?.disconnect()
                }
            }
        }
    }

    @MainActor
    func disconnect() async {
        LogManager.trace("Disconnecting from chat services")

        // The session is going away, so a survey or inactivity popup it was showing (or a deferral latched for one) goes with it.
        tearDownSatisfactionSurvey()
        releaseInactivityPopupOwnership()
        await hideOverlay()

        disconnecting = true

        stopObservingEvents()

        chatProvider.connection.disconnect()

        // Add a small delay to ensure any sheet dismissal completes before calling onDismiss
        // This prevents a race condition where the chat view remains visible after form cancellation
        Task { @MainActor in
            await Task.sleep(seconds: 0.1)

            self.onDismiss?()
        }
    }

    /// Creates a new chat thread asynchronously.
    ///
    /// This method hides any overlay to present either a pre-chat form or an empty thread.
    /// If a pre-chat survey is available, it presents the pre-chat form to the user and collects custom field data.
    /// If the user completes the form, a new thread is created with the provided custom fields.
    /// If no pre-chat survey is available, a new thread is created directly.
    ///
    /// - Throws: An error if the thread creation fails.
    ///
    /// - Note: The only situation when the ChatThreadProvider is `nil` is when the pre-chat form is cancelled.
    ///
    /// - Returns: An optional `ChatThreadProvider` instance representing the created thread, or `nil` if the thread creation process is interrupted.
    func createThread() async throws -> ChatThreadProvider? {
        // A new thread supersedes any survey or inactivity popup left on screen; release them before hiding the overlay
        tearDownSatisfactionSurvey()
        releaseInactivityPopupOwnership()
        // Hide overlay so a pre-chat form or empty thread can be presented
        await hideOverlay()
        
        cachedThreadViewModel?.resetStaleState()

        // Check if a pre-chat survey is available
        if let preChatSurvey = chatProvider.threads.preChatSurvey {
            LogManager.trace("Present pre-chat form before thread creation")

            let fieldEntities = preChatSurvey.customFields.map { prechatField in
                FormCustomFieldTypeMapper.map(prechatField, with: [:])
            }

            // Show the pre-chat form and wait for user input
            guard let customFields = await showPrechatSurveyForm(title: preChatSurvey.name, fields: fieldEntities) else {
                // The user cancelled the pre-chat form
                return nil
            }

            LogManager.trace("Pre-chat form completed -> create thread with custom fields")
            
            return try await createNewThread(with: customFields)
        } else {
            LogManager.trace("No pre-chat available -> create thread")
            
            return try await createNewThread()
        }
    }

    // periphery:ignore:parameters output - for inline usage in the view
    func willEnterForeground(_ output: NotificationCenter.Publisher.Output) {
        LogManager.trace("Enter foreground")
        
        guard chatProvider.state == .prepared else {
            LogManager.warning("Chat is in incorrect state (= .\(chatProvider.state)) -> unable to trigger connect")
            return
        }
        
        // Force thread reload if there is a thread already opened
        if cachedThreadViewModel != nil {
            LogManager.trace("Setting shouldRefreshThread flag to refresh thread on foreground")
            
            shouldRefreshThread = true
        } else {
            LogManager.trace("Skipping thread refresh on foreground - no active thread")
        }
        
        connectTask = Task { @MainActor in
            await self.connect()
        }
    }

    // periphery:ignore:parameters output - for inline usage in the view
    func didEnterBackground(_ output: NotificationCenter.Publisher.Output) {
        LogManager.trace("Enter background")

        // Stop inactivity popup if any is being shown to be able to present it again next time
        releaseInactivityPopupOwnership()

        // A satisfaction survey deliberately survives backgrounding - the SDK never re-emits it, so tearing
        // it down here would lose it for good. Its overlay slot is locked, so hideOverlay() below leaves it
        // in place, and the reconnect on foreground follows the same deferred path as a recovered survey.

        // Cancel a foreground-triggered connect that's still in flight so `connect()`'s catch
        // block can tell "we backgrounded mid-connect" apart from a real connection failure.
        connectTask?.cancel()
        connectTask = nil

        Task { @MainActor in
            await self.hideOverlay()
        }

        chatProvider.connection.disconnect()
    }
}

// MARK: - Overlays

extension ChatContainerViewModel {

    @MainActor
    func showLoading(file: StaticString = #file, line: UInt = #line) async {
        LogManager.trace("Showing loading overlay", file: file, line: line)

        await showOverlay({ [weak self] in
            ChatLoadingOverlay(text: L10n.Common.loading) {
                Task { @MainActor in
                    await self?.disconnect()
                }
            }
        }, file: file, line: line)
    }

    @MainActor
    func showOffline(file: StaticString = #file, line: UInt = #line) async {
        LogManager.trace("Showing offline view overlay", file: file, line: line)
        
        await showOverlay({ [weak self] in
            OfflineView {
                Task { @MainActor in
                    await self?.disconnect()
                }
            }
        }, file: file, line: line)
    }
}

// MARK: - Event Handling

private extension ChatContainerViewModel {

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
            await handleChatUpdate(state, mode: mode)

        case .threadUpdated(let thread):
            handleThreadUpdated(thread)

        case .unexpectedDisconnect:
            await handleUnexpectedDisconnect()

        case .proactiveActionReceived(let type):
            await handleProactiveActionTypeReceived(type)

        default:
            break
        }
    }
}

// MARK: - Private methods

private extension ChatContainerViewModel {
    
    @MainActor
    func handleChatUpdate(_ chatState: ChatState, mode: ChatMode) async {
        LogManager.trace("Handling chat update: \(chatState) in mode \(mode)")
        
        switch chatState {
        case .connecting:
            await self.showLoading()
        case .connected:
            do {
                LogManager.trace("Reporting chat window open event")
                
                try await self.chatProvider.analytics.chatWindowOpen()
            } catch {
                // No need to show alert here, as this is not a fatal error
                error.logError()
            }
            
            // Handle additional configuration if needed
            await handleAdditionalConfigurationIfNeeded()
        case .offline:
            // Going offline moots any survey it was showing (or a deferral latched for one), same as
            // handleUnexpectedDisconnect() - clear it before hiding the overlay so it isn't left blocking
            // recovery for the rest of the session.
            tearDownSatisfactionSurvey()
            releaseInactivityPopupOwnership()
            // Hide any existing overlays before showing the offline view
            await self.hideOverlay()
            // Show the offline view
            await self.showOffline()
        case .ready:
            // Cache to be able to handle local notifications
            self.refreshCachedThreadMessageCounts()
            
            if cachedThreadViewModel == nil {
                // The thread view is not ready yet but there is a thread to be opened so don't hide the overlay to share the loading indicator.
                // A recovered survey can also arrive before this `.ready` update (the SDK sends the proactive event first), so don't evict it either.
                if threadToOpen == nil, !isSatisfactionSurveyActive {
                    await self.hideOverlay()
                }
            } else {
                LogManager.info("Chat is ready, but some thread is active and it needs to be recovered - keep the loading overlay")
                
                if let threadToOpen {
                    // Navigate directly to the thread
                    await self.navigateDirectlyToThread(threadToOpen)
                    
                    self.threadToOpen = nil
                }
            }
        default:
            LogManager.trace("ChatCoordinatorViewModel: ignoring \(chatState)")
        }
    }

    func refreshCachedThreadMessageCounts() {
        chatProvider.threads.get().forEach { thread in
            cachedThreadMessageCount[thread.id] = thread.messages.count
        }
    }

    func handleThreadUpdated(_ chatThread: CXoneChatSDK.ChatThread) {
        guard chatProvider.mode == .multithread else {
            // Skip local notification handling for singlethread and livechat mode because it's not supported
            return
        }
        guard cachedListViewModel?.currentThread != nil else {
            // No active ThreadViewModel -> the chat is in ThreadList so we don't want to present local notification
            return
        }
        
        // Handle a local notification if the thread is not the one currently displayed one
        if cachedThreadViewModel?.thread?.id == chatThread.id {
            LogManager.trace("The thread is the currently one so it will be handled in the ThreadViewModel, just update the cache")
            
            self.refreshCachedThreadMessageCounts()
        } else if !processingDeeplink {
            LogManager.trace("The thread is not the currently displayed one = try to schedule a local notification")
            
            guard chatThread.messages.last?.isSeenByCustomer != true else {
                LogManager.trace("The message is already seen by a customer")
                return
            }
            
            // Store the previous message count before updating the cache
            let cachedThreadMessageCount = self.cachedThreadMessageCount
            // Update the cache for future thread updates
            self.refreshCachedThreadMessageCounts()
            
            // Check if count of threads has been changed (=> new message for different thread)
            guard let count = cachedThreadMessageCount[chatThread.id], count != chatThread.messages.count else {
                // Thread has been updated but no new messages are same = no interaction needed
                LogManager.info("Thread has been updated but no new messages")
                return
            }
            
            Task { [weak self] in
                await self?.createNotificationForInactiveThreadMessage(chatThread)
            }
        } else {
            // Scenario: user left thread A and tapped a notification for thread B.
            // While processing the deeplink, we switched to thread B, making thread A hidden.
            // This can cause thread A's messages to appear new, which might incorrectly trigger a notification.
            // To avoid this, we reset the deeplink flag and skip notification handling.
            processingDeeplink = false
        }
    }

    func handleUnexpectedDisconnect() async {
        guard !disconnecting else {
            return
        }

        LogManager.trace("Disconnected unexpectedly")

        // The socket just dropped, so any survey or inactivity popup it was showing (or a deferral latched for one) is moot.
        tearDownSatisfactionSurvey()
        releaseInactivityPopupOwnership()
        await hideOverlay()

        alertType = .connectionErrorAlert {
            Task { @MainActor in
                await self.disconnect()
            }
        }
    }

    @MainActor
    func createNewThread(with customFields: [String: String]? = nil) async throws -> ChatThreadProvider {
        LogManager.trace("Creating new thread")
        
        if let customFields {
            return try await chatProvider.threads.create(with: customFields)
        } else {
            return try await chatProvider.threads.create()
        }
    }
    
    func handleAdditionalConfigurationIfNeeded() async {
        do {
            if !chatConfiguration.additionalCustomerCustomFields.isEmpty {
                // Provide additional customer custom fields
                try await chatProvider.customerCustomFields.set(chatConfiguration.additionalCustomerCustomFields)
            }
        } catch {
            error.logError()
        }
    }
    
    func createNotificationForInactiveThreadMessage(_ updatedThread: CXoneChatSDK.ChatThread) async {
        guard let lastMessage = updatedThread.messages.last else {
            LogManager.error("Unable to get last message for thread \(updatedThread.id)")
            return
        }
        
        LogManager.trace("Creating notification for inactive thread: \(updatedThread.id)")
        
        do {
            try await UNUserNotificationCenter
                .current()
                .scheduleThreadNotification(lastMessage: lastMessage)
            
            LogManager.trace("Notification scheduled successfully")
        } catch {
            LogManager.error("Failed to add notification: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func navigateDirectlyToThread(_ threadId: String) async {
        LogManager.trace("Starting navigation to thread: \(threadId)")
        
        processingDeeplink = true
        
        let threads = chatProvider.threads.get()
        
        guard let thread = threads.first(where: { $0.id == threadId }) else {
            LogManager.error("Could not find thread with ID: \(threadId)")
            processingDeeplink = false
            return
        }
        
        LogManager.trace("Found thread, preparing to navigate")
        
        guard chatProvider.mode == .multithread else {
            LogManager.trace("Current chat mode is single-thread or livechat, skipping navigation - the thread will be opened in the current view")
            processingDeeplink = false
            return
        }
        
        shouldRefreshThread = true
        
        let mappedThread = ChatThreadMapper.map(from: thread)
        
        cachedThreadViewModel = viewModel(for: mappedThread)

        // `ThreadListView`'s `.navigationDestination` keys off `currentThread.id` (via `.id(...)`),
        // so reassigning here is sufficient to force `ThreadView` recreation when the user is already
        // viewing a different thread — no need to clear-then-set across separate storage.
        cachedListViewModel?.currentThread = mappedThread
        processingDeeplink = false
    }
}
