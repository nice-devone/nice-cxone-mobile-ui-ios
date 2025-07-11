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

import CXoneChatSDK
import SwiftUI

class ChatContainerViewModel: ObservableObject {

    // MARK: - Properties

    @Published var sheet: (() -> AnyView)?
    @Published var overlay: (() -> AnyView)?
    @Published var alertType: ChatAlertType?
    
    let chatProvider: ChatProvider
    let chatLocalization: ChatLocalization
    let chatStyle: ChatStyle
    let chatConfiguration: ChatConfiguration
    let presentModally: Bool
    let onDismiss: (() -> Void)?

    // Used to determine if the chat should be refreshed,
    // for example after when a thread is open but client disconnect via entering background
    var shouldRefreshThread = false
    var threadToOpen: UUID?
    var disconnecting = false
    var processingDeeplink = false
    
    lazy var isSheetDisplayed = Binding { [weak self] in
        self?.sheet != nil
    } set: { [weak self] _ in
        self?.sheet = nil
    }
    lazy var isOverlayDisplayed = Binding { [weak self] in
        self?.overlay != nil
    } set: { [weak self] _ in
        self?.overlay = nil
    }

    private weak var cachedListViewModel: ThreadListViewModel?
    private(set) weak var cachedThreadViewModel: ThreadViewModel?

    // Observe notification taps to navigate to the correct thread
    private var directNavigationToken: NSObjectProtocol?
    // To be able to handle receiving new messages from different thread, it is necessary to cache current thread list
    private var cachedThreadMessageCount = [UUID: Int]()
    
    // MARK: - Init

    init(
        chatProvider: ChatProvider,
        threadToOpen: UUID? = nil,
        chatLocalization: ChatLocalization,
        chatStyle: ChatStyle,
        chatConfiguration: ChatConfiguration,
        presentModally: Bool,
        onDismiss: (() -> Void)? = nil
    ) {
        self.chatProvider = chatProvider
        self.threadToOpen = threadToOpen
        self.chatLocalization = chatLocalization
        self.chatStyle = chatStyle
        self.chatConfiguration = chatConfiguration
        self.presentModally = presentModally
        self.onDismiss = onDismiss
        
        directNavigationToken = NotificationCenter.default.threadDeeplinkObserver { [weak self] notification in
            guard let threadId = notification.userInfo?["threadId"] as? UUID else {
                LogManager.error("Unable to retrieve threadId from notification")
                return
            }
            
            LogManager.trace("ChatContainerViewModel received notification to navigate directly to thread: \(threadId)")
            
            if !chatProvider.state.isChatAvailable {
                self?.threadToOpen = threadId
            } else {
                // Navigate directly to the thread
                Task { @MainActor in
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
        
        chatProvider.add(delegate: self)

        Task { @MainActor [weak self] in
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
        Task { @MainActor [weak self] in
            await self?.hideOverlay()
        }
        
        // Do not continue if chat services are not available
        guard chatProvider.state.isChatAvailable else {
            return
        }
        
        // For multithread presented in full-screen, the `ChatContainerView's `onDisappear` is called when a ThreadView appears
        // and we don't want to trigger removal of the ChatContainerViewModel's delegate and disconnect from the chat services
        if !presentModally, chatProvider.mode == .multithread, cachedThreadViewModel != nil {
            return
        }
        
        disconnecting = true
        
        chatProvider.remove(delegate: self)
        
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

        await showLoading(message: chatLocalization.commonConnecting)

        do {
            try await chatProvider.connection.connect()
        } catch {
            error.logError()
            
            await hideOverlay()
            
            alertType = .connectionErrorAlert(localization: self.chatLocalization) {
                Task { [weak self] in
                    await self?.disconnect()
                }
            }
        }
    }

    @MainActor
    func disconnect() async {
        LogManager.trace("Disconnecting from chat services")
        
        await hideOverlay()
        
        disconnecting = true
        
        chatProvider.remove(delegate: self)
        
        chatProvider.connection.disconnect()

        // Add a small delay to ensure any sheet dismissal completes before calling onDismiss
        // This prevents a race condition where the chat view remains visible after form cancellation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.onDismiss?()
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
    @MainActor
    func createThread() async throws -> ChatThreadProvider? {
        // Hide overlay so a pre-chat form or empty thread can be presented
        await hideOverlay()
        
        // Check if a pre-chat survey is available
        if let preChatSurvey = chatProvider.threads.preChatSurvey {
            LogManager.trace("Present pre-chat form because thread creation")

            let fieldEntities = preChatSurvey.customFields.map { prechatField in
                FormCustomFieldTypeMapper.map(prechatField, with: [:])
            }

            // Show the pre-chat form and wait for user input
            guard let customFields = await showForm(title: preChatSurvey.name, fields: fieldEntities) else {
                // The user cancelled the pre-chat form
                return nil
            }

            return try await createNewThread(with: customFields)
        } else {
            LogManager.trace("Create thread with no prechat")
            
            return try await createNewThread()
        }
    }

    // periphery:ignore:parameters output
    func willEnterForeground(_ output: NotificationCenter.Publisher.Output) {
        LogManager.trace("Enter foreground")
        
        // Force thread reload if there is a thread already opened
        if cachedThreadViewModel != nil {
            LogManager.trace("Setting shouldRefreshThread flag to refresh thread on foreground")
            
            shouldRefreshThread = true
        } else {
            LogManager.trace("Skipping thread refresh on foreground - no active thread")
        }
        
        Task { @MainActor [weak self] in
            await self?.connect()
        }
    }
    
    // periphery:ignore:parameters output
    func didEnterBackground(_ output: NotificationCenter.Publisher.Output) {
        LogManager.trace("Enter background")
        
        CXoneChat.shared.connection.disconnect()
    }
}

// MARK: - Sheets

extension ChatContainerViewModel {

    func hideSheet(file: StaticString = #file, line: UInt = #line) async {
        LogManager.trace("Hiding sheet", file: file, line: line)

        await MainActor.run { [weak self] in
            self?.sheet = nil
        }
    }
    
    @MainActor
    func showForm(title: String, fields: [FormCustomFieldType]) async -> [String: String]? {
        await withCheckedContinuation { continuation in
            let formViewModel = FormViewModel(title: title, customFields: fields) { fields in
                Task { @MainActor [weak self] in
                    await self?.hideSheet()
                }
                
                continuation.resume(returning: fields)
            } onCancel: {
                Task { @MainActor [weak self] in
                    await self?.hideSheet()
                }
                
                continuation.resume(returning: Optional<[String: String]>.none)
            }

            Task { @MainActor [weak self] in
                self?.sheet = {
                    AnyView(FormView(viewModel: formViewModel))
                }
            }
        }
    }
}

// MARK: - Overlays

extension ChatContainerViewModel {
    
    @MainActor
    func showOverlay<Content: View>(file: StaticString = #file, line: UInt = #line, @ViewBuilder _ overlay: @escaping () -> Content) async {
        guard self.overlay == nil else {
            LogManager.error("Some overlay is already being shown, cannot show another one", file: file, line: line)
            return
        }
        
        await MainActor.run { [weak self] in
            self?.overlay = {
                AnyView(overlay())
            }
        }
        // Optional delay to ensure UI updates are smooth because the overlay's fullScreenCover transition is not instant
        await Task.sleep(seconds: 0.5)
    }

    func hideOverlay(file: StaticString = #file, line: UInt = #line) async {
        guard overlay != nil else {
            // No overlay to hide
            return
        }
        
        LogManager.trace("Hiding overlay", file: file, line: line)
        
        await MainActor.run { [weak self] in
            self?.overlay = nil
        }
        // Optional delay to ensure UI updates are smooth because the overlay's fullScreenCover transition is not instant
        await Task.sleep(seconds: 0.5)
    }

    @MainActor
    func showLoading(message: String, file: StaticString = #file, line: UInt = #line) async {
        LogManager.trace("Showing loading overlay with status message: \(message)", file: file, line: line)

        await showOverlay(file: file, line: line) {
            ChatLoadingOverlay(text: message) {
                Task { @MainActor [weak self] in
                    await self?.disconnect()
                }
            }
        }
    }

    @MainActor
    func showOffline(file: StaticString = #file, line: UInt = #line) async {
        LogManager.trace("Showing offline view overlay", file: file, line: line)
        
        await showOverlay(file: file, line: line) {
            ChatDefaultOverlay(verticalOffset: StyleGuide.containerVerticalOffset) {
                OfflineView {
                    Task { @MainActor [weak self] in
                        await self?.disconnect()
                    }
                }
            }
        }
    }
}

// MARK: - CXoneChatDelegate

extension ChatContainerViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
        LogManager.scope {
            LogManager.trace("updated state = \(String(describing: chatState))")
            
            Task { [weak self] in
                guard let self else {
                    return
                }
                
                switch chatState {
                case .connecting:
                    await self.showLoading(message: self.chatLocalization.commonConnecting)
                case .connected:
                    await handleAdditionalConfigurationIfNeeded()
                    
                    do {
                        LogManager.trace("Reporting chat window open event")
                        
                        try await self.chatProvider.analytics.chatWindowOpen()
                    } catch {
                        // No need to show alert here, as this is not a fatal error
                        error.logError()
                    }
                    
                    await self.showLoading(message: self.chatLocalization.commonLoading)
                case .offline:
                    // Hide any existing overlays before showing the offline view
                    await self.hideOverlay()
                    // Show the offline view
                    await self.showOffline()
                case .ready:
                    // Cache to be able to handle local notifications
                    chatProvider.threads.get().forEach { thread in
                        self.cachedThreadMessageCount[thread.id] = thread.messages.count
                    }
                    
                    if cachedThreadViewModel == nil {
                        await self.hideOverlay()
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
        }
    }
    
    func onThreadUpdated(_ chatThread: CXoneChatSDK.ChatThread) {
        guard chatProvider.mode == .multithread else {
            // Skip local notification handling for singlethread and livechat mode because it's supported
            return
        }
        guard cachedListViewModel?.threadToShow != nil || cachedListViewModel?.hiddenThreadToShow != nil else {
            // No active ThreadViewModel -> the chat is in ThreadList so we don't want to present local notification
            return
        }
        
        // Handle a local notification if the thread is not the one currently displayed one
        if cachedThreadViewModel?.thread?.id == chatThread.id {
            LogManager.trace("The thread is the currently one so it will be handled in the ThreadViewModel, just update the cache")
            
            chatProvider.threads.get().forEach { [weak self] thread in
                self?.cachedThreadMessageCount[thread.id] = thread.messages.count
            }
        } else if !processingDeeplink {
            LogManager.trace("The thread is not the currently displayed one = try to schedule a local notification")
            
            // Store the previous message count before updating the cache
            let cachedThreadMessageCount = self.cachedThreadMessageCount
            // Update the cache for future thread updates
            chatProvider.threads.get().forEach { [weak self] thread in
                self?.cachedThreadMessageCount[thread.id] = thread.messages.count
            }
            
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
    
    func onUnexpectedDisconnect() {
        guard !disconnecting else {
            return
        }
        
        LogManager.trace("Disconnected unexpectedly")
        
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            self.alertType = .connectionErrorAlert(localization: self.chatLocalization) {
                Task { @MainActor in
                    await self.disconnect()
                }
            }
        }
    }
}

// MARK: - Private methods

private extension ChatContainerViewModel {
    
    @MainActor
    func createNewThread(with customFields: [String: String]? = nil) async throws -> ChatThreadProvider {
        if let customFields {
            return try await chatProvider.threads.create(with: customFields)
        } else {
            return try await chatProvider.threads.create()
        }
    }
}

// MARK: - Private methods

private extension ChatContainerViewModel {
    
    func handleAdditionalConfigurationIfNeeded() async {
        do {
            if !chatConfiguration.additionalCustomerCustomFields.isEmpty {
                // Provide additional customer custom fields
                try await chatProvider.customerCustomFields.set(chatConfiguration.additionalCustomerCustomFields)
            }
        } catch {
            error.logError()
            
            _ = await MainActor.run { [weak self] in
                guard let self else {
                    return
                }
                
                self.alertType = .genericError(localization: chatLocalization)
            }
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
                .scheduleThreadNotification(lastMessage: lastMessage, chatLocalization: chatLocalization)
            
            LogManager.trace("Notification scheduled successfully")
        } catch {
            LogManager.error("Failed to add notification: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func navigateDirectlyToThread(_ threadId: UUID) async {
        LogManager.trace("Starting navigation to thread: \(threadId)")
        
        processingDeeplink = true
        
        let threads = chatProvider.threads.get()
        
        guard let thread = threads.first(where: { $0.id == threadId }) else {
            LogManager.error("Could not find thread with ID: \(threadId)")
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
        
        await MainActor.run {
            if cachedListViewModel?.threadToShow != nil {
                cachedListViewModel?.hiddenThreadToShow = mappedThread
                cachedListViewModel?.threadToShow = nil
            } else {
                cachedListViewModel?.threadToShow = mappedThread
                cachedListViewModel?.hiddenThreadToShow = nil
            }
        }
    }
}

// MARK: - Previews

#Preview("Offline") {
    let localization = ChatLocalization()
    let chatStyle = ChatStyle()
    
    let viewModel = ChatContainerViewModel(
        chatProvider: CXoneChat.shared,
        chatLocalization: localization,
        chatStyle: chatStyle,
        chatConfiguration: ChatConfiguration(),
        presentModally: true
    ) {}

    return ChatContainerView(viewModel: viewModel)
        .environmentObject(chatStyle)
        .environmentObject(localization)
        .task {
            await viewModel.showOffline()
        }
}

#Preview("Loading") {
    let localization = ChatLocalization()
    let chatStyle = ChatStyle()

    let viewModel = ChatContainerViewModel(
        chatProvider: CXoneChat.shared,
        chatLocalization: localization,
        chatStyle: chatStyle,
        chatConfiguration: ChatConfiguration(),
        presentModally: true
    ) {}

    return ChatContainerView(viewModel: viewModel)
        .environmentObject(chatStyle)
        .environmentObject(localization)
        .task {
            await viewModel.showLoading(message: "Loading...")
        }
}

#Preview("Fatal") {
    let localization = ChatLocalization()
    let chatStyle = ChatStyle()

    let viewModel = ChatContainerViewModel(
        chatProvider: CXoneChat.shared,
        chatLocalization: localization,
        chatStyle: chatStyle,
        chatConfiguration: ChatConfiguration(),
        presentModally: true
    ) {}

    return ChatContainerView(viewModel: viewModel)
        .environmentObject(chatStyle)
        .environmentObject(localization)
        .task {
            viewModel.alertType = .connectionErrorAlert(localization: localization) { }
        }
}
