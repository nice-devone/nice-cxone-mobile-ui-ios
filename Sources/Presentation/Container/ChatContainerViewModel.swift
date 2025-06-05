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
    @Published var alertType: ChatAlertType?
    @Published var chatState: ChatState
    
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

    lazy var isSheetDisplayed = Binding { [weak self] in
        self?.sheet != nil
    } set: { [weak self] _ in
        self?.sheet = nil
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
        self.chatState = chatProvider.state

        self.showLoading(message: chatLocalization.commonConnecting)
        
        directNavigationToken = NotificationCenter.default.threadDeeplinkObserver { [weak self] notification in
            guard let threadId = notification.userInfo?["threadId"] as? UUID else {
                LogManager.error("Unable to retrieve threadId from notification")
                return
            }
            
            LogManager.trace("ChatContainerViewModel received notification to navigate directly to thread: \(threadId)")
            
            // Navigate directly to the thread
            self?.navigateDirectlyToThread(threadId)
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
        // Force dismiss any existing overlays to start clean
        OverlayPresenter.shared.dismiss()
        
        LogManager.trace("View did appear")
        
        chatProvider.add(delegate: self)

        Task {
            if chatProvider.state != .connected {
                await connect()
            }
        }
    }

    func onDisappear() {
        
        // Force dismiss any overlays when view disappears
        OverlayPresenter.shared.dismiss()
        
        // Do not continue if chat services are not available
        guard chatProvider.state.isChatAvailable else {
            return
        }
        
        // For multithread presented in full-screen, the `ChatContainerView's `onDisappear` is called when a ThreadView appears
        // and we don't want to trigger removal of the ChatContainerViewModel's delegate and disconnect from the chat services
        if !presentModally, chatProvider.mode == .multithread, cachedThreadViewModel != nil {
            return
        }
        
        LogManager.trace("View did disappear")
        
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

    func connect() async {
        guard chatProvider.state != .connected else {
            LogManager.trace("Skip connecting, already connected")
            return
        }
        
        LogManager.trace("Connecting to chat services")

        disconnecting = false

        showLoading(message: chatLocalization.commonConnecting)

        do {
            try await chatProvider.connection.connect()
        } catch {
            error.logError()
            
            hideOverlay()
            
            _ = await MainActor.run { [weak self] in
                guard let self else {
                    return
                }
             
                self.alertType = .connectionErrorAlert(localization: self.chatLocalization) { [weak self] in
                    self?.disconnect()
                }
            }
        }
    }

    func disconnect() {
        LogManager.trace("Disconnecting from chat services")
        
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
        hideOverlay()
        
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
        
        Task {
            await connect()
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

    func hideSheet() {
        Task { @MainActor in
            self.sheet = nil
        }
    }

    func showForm(title: String, fields: [FormCustomFieldType]) async -> [String: String]? {
        await withCheckedContinuation { continuation in
            let formViewModel = FormViewModel(title: title, customFields: fields) { [weak self] fields in
                self?.hideSheet()
                
                continuation.resume(returning: fields)
            } onCancel: { [weak self] in
                self?.hideSheet()
                
                continuation.resume(returning: Optional<[String: String]>.none)
            }

            Task { @MainActor in
                self.sheet = {
                    AnyView(FormView(viewModel: formViewModel))
                }
            }
        }
    }
}

// MARK: - Overlays

extension ChatContainerViewModel {

    func showOverlay<Content: View>(@ViewBuilder _ overlay: @escaping () -> Content) {
        OverlayPresenter.shared.present {
            overlay()
                .environmentObject(self.chatStyle)
                .environmentObject(self.chatLocalization)
        }
    }

    func hideOverlay() {
        OverlayPresenter.shared.dismiss()
    }

    func showLoading(message: String) {
        LogManager.trace("Showing status message: \(message)")

        Task { @MainActor in
            showOverlay {
                ChatLoadingOverlay(text: message, onCancel: self.disconnect)
            }
        }
    }

    func showOffline() {
        LogManager.trace("Showing offline view")

        // Force dismiss any existing overlays first
        OverlayPresenter.shared.dismiss()
        
        Task { @MainActor in
            showOverlay {
                ChatDefaultOverlay(verticalOffset: StyleGuide.containerVerticalOffset) {
                    OfflineView(disconnectAction: self.disconnect)
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
            
            Task { @MainActor in
                self.chatState = chatState
            }
            
            switch chatState {
            case .connecting:
                showLoading(message: chatLocalization.commonConnecting)
            case .connected:
                handleAdditionalConfigurationIfNeeded()
                
                Task {
                    do {
                        LogManager.trace("Reporting chat window open event")
                        
                        try await self.chatProvider.analytics.chatWindowOpen()
                    } catch {
                        // No need to show alert here, as this is not a fatal error
                        error.logError()
                    }
                }
                
                showLoading(message: chatLocalization.commonLoading)
            case .offline:
                showOffline()
            case .ready:
                // Cache to be able to handle local notifications
                chatProvider.threads.get().forEach { [weak self] thread in
                    self?.cachedThreadMessageCount[thread.id] = thread.messages.count
                }
                
                if cachedThreadViewModel == nil {
                    hideOverlay()
                } else {
                    LogManager.info("Chat is ready, but some thread is active and it needs to be recovered - keep the loading overlay")
                }
            default:
                LogManager.trace("ChatCoordinatorViewModel: ignoring \(chatState)")
            }
        }
    }
    
    func onThreadUpdated(_ chatThread: CXoneChatSDK.ChatThread) {
        guard chatProvider.mode == .multithread else {
            // Ship local notification handling for singlethread and livechat mode because it's supported
            return
        }
        
        // Handle a local notification if the thread is not the one currently displayed one
        if cachedThreadViewModel?.thread?.id == chatThread.id {
            LogManager.trace("The thread is the currently one so it will be handled in the ThreadViewModel, just update the cache")
            
            chatProvider.threads.get().forEach { [weak self] thread in
                self?.cachedThreadMessageCount[thread.id] = thread.messages.count
            }
        } else {
            LogManager.trace("The thread is not the currently displayed one = try to schedule a local notification")
            
            // Update the cache for future thread updates
            let cachedThreadMessageCount = self.cachedThreadMessageCount
            chatProvider.threads.get().forEach { [weak self] thread in
                self?.cachedThreadMessageCount[thread.id] = thread.messages.count
            }
            
            // Check if count of threads has been changed (=> new message for different thread)
            guard let count = cachedThreadMessageCount[chatThread.id], count != chatThread.messages.count else {
                // Thread has been updated but no new messages are same = no interaction needed
                LogManager.info("Thread has been updated but no new messages")
                return
            }

            createNotificationForInactiveThreadMessage(chatThread)
        }
    }
    
    func onUnexpectedDisconnect() {
        guard !disconnecting else {
            return
        }
        
        LogManager.trace("Disconnected unexpectedly")
        
        Task { @MainActor in
            alertType = .connectionErrorAlert(localization: chatLocalization) { [weak self] in
                self?.disconnect()
            }
        }
    }
}

// MARK: - Private methods

private extension ChatContainerViewModel {
    
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
    
    func handleAdditionalConfigurationIfNeeded() {
        Task {
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
    }
    
    func createNotificationForInactiveThreadMessage(_ updatedThread: CXoneChatSDK.ChatThread) {
        guard let lastMessage = updatedThread.messages.last else {
            LogManager.error("Unable to get last message for thread \(updatedThread.id)")
            return
        }
        
        LogManager.trace("Creating notification for inactive thread: \(updatedThread.id)")
        
        Task {
            do {
                try await UNUserNotificationCenter
                    .current()
                    .scheduleThreadNotification(lastMessage: lastMessage, chatLocalization: chatLocalization)
                
                LogManager.trace("Notification scheduled successfully")
            } catch {
                LogManager.error("Failed to add notification: \(error.localizedDescription)")
            }
        }
    }
    
    func navigateDirectlyToThread(_ threadId: UUID) {
        LogManager.trace("Starting navigation to thread: \(threadId)")
        
        let threads = chatProvider.threads.get()
        
        guard let thread = threads.first(where: { $0.id == threadId }) else {
            LogManager.error("Could not find thread with ID: \(threadId)")
            return
        }
        
        LogManager.trace("Found thread, preparing to navigate")
        
        let mappedThread = ChatThreadMapper.map(from: thread)
        
        Task { @MainActor in
            cachedThreadViewModel = viewModel(for: mappedThread)
            
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
            viewModel.showOffline()
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
            viewModel.showLoading(message: "Loading...")
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
