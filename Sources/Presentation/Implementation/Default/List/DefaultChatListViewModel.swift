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

import CXoneChatSDK
import SwiftUI

class DefaultChatListViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var chatThreads = [ChatThread]()
    @Published var preChatSurvey: PreChatSurvey?
    @Published var thread: ChatThread?
    @Published var threadStatus: ThreadStatusType = .current
    @Published var alertType: ChatAlertType?
    @Published var isLoading = false
    
    private let coordinator: DefaultChatCoordinator
    private let localization: ChatLocalization
    private var threadIdToOpen: UUID?
    private var isActive = true
    
    var isMultiThread: Bool { CXoneChat.shared.connection.channelConfiguration.hasMultipleThreadsPerEndUser }
    
    // MARK: - Lifecycle
    
    init(
        coordinator: DefaultChatCoordinator,
        threadIdToOpen: UUID? = nil,
        localization: ChatLocalization
    ) {
        self.coordinator = coordinator
        self.threadIdToOpen = threadIdToOpen
        self.localization = localization
    }
}

// MARK: - Actions

extension DefaultChatListViewModel {
    
    func onAppear() {
        LogManager.trace("Default chat list view appeared")
        
        CXoneChat.shared.delegate = self
        isActive = true
        
        if CXoneChat.shared.state.isChatAvailable {
            updateCurrentThreads()
                
            if let threadIdToOpen {
                navigateToThread(with: threadIdToOpen)
            }
        } else {
            reconnect()
        }
    }
    
    func onDisappear() {
        LogManager.trace("Default chat list view disappear")
        
        isActive = false
    }
    
    func onDisconnectTapped() {
        LogManager.trace("Disconnecting from CXoneChat services")

        CXoneChat.shared.delegate = nil
        
        CXoneChat.shared.connection.disconnect()
        coordinator.onFinished?()
        
        coordinator.dismiss(animated: true)
    }
    
    func onCreateNewThread() {
        LogManager.trace("Trying to create a new thread")

        if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
            let fieldEntities = preChatSurvey.customFields.map(FormCustomFieldTypeMapper.map)
            
            coordinator.presentForm(title: preChatSurvey.name, customFields: fieldEntities) { customFields in
                Task { @MainActor in
                    await self.createNewThread(with: customFields)
                }
            }
        } else {
            Task { @MainActor in
                await createNewThread()
            }
        }
    }
    
    func updateThreadStatus(_ status: ThreadStatusType) {
        LogManager.trace("Changing thread list to \(status)")
        
        threadStatus = status
        
        updateCurrentThreads()
    }
    
    func onThreadTapped(_ thread: ChatThread) {
        LogManager.trace("Opening chat window")
        
        coordinator.showThread(thread)
    }

    func onSwipeToDelete(offsets: IndexSet) {
        guard let deletedThread = offsets.compactMap({ chatThreads[safe: $0] }).first else {
            LogManager.error(.failed("Unable to get thread for archiving."))
            return
        }

        onDelete(deletedThread)
    }
    
    func onDelete(_ thread: ChatThread) {
        LogManager.trace("Archiving thread")
        
        do {
            try CXoneChat.shared.threads.archive(thread)
            
            isLoading = true
        } catch {
            error.logError()
            alertType = .genericError(localization: localization, primaryAction: onDisconnectTapped)
        }
    }
    
    func willEnterForeground(_ output: NotificationCenter.Publisher.Output) {
        guard isActive else {
            // Skipped because it is called even when the list is not active -> DefaultChatView is the current active view
            return
        }
        
        LogManager.trace("Enter foreground")
        
        reconnect()
    }
    
    func didEnterBackground(_ output: NotificationCenter.Publisher.Output) {
        guard isActive else {
            // Skipped because it is called even when the list is not active -> DefaultChatView is the current active view
            return
        }
        
        LogManager.trace("Enter background")
        
        CXoneChat.shared.connection.disconnect()
    }
}

// MARK: - CXoneChatDelegate

extension DefaultChatListViewModel: CXoneChatDelegate {

    func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
		LogManager.trace("Chat state has been updated")

        Task { @MainActor in
            switch chatState {
            case .ready:
                isLoading = false
            default:
                isLoading = true
            }
        }
    }
    
    func onThreadUpdated(_ thread: ChatThread) {
		LogManager.trace("Thread has been updated")

        Task { @MainActor in
            updateCurrentThreads()
            
            if thread.state == .pending || (CXoneChat.shared.mode == .singlethread && thread.state == .ready) {
                coordinator.showThread(thread)
            }
            
            isLoading = false
        }
    }
    
    func onThreadsUpdated(_ chatThreads: [ChatThread]) {
		LogManager.trace("Threads has been updated")

        Task { @MainActor in
            updateCurrentThreads(with: chatThreads)
            
            isLoading = false
            
            if let threadIdToOpen {
                navigateToThread(with: threadIdToOpen)
            }
        }
    }

    func onUnexpectedDisconnect() {
        LogManager.trace("Unexpected disconnect did occur")
        
        reconnect()
    }
    
    func onTokenRefreshFailed() {
        LogManager.trace("Token refresh failed")
        
        CXoneChat.shared.customer.set(nil)

        coordinator.dismiss(animated: true)
    }

    func onError(_ error: Error) {
        error.logError()
        
        Task { @MainActor in
            isLoading = false
        }
    }
}

// MARK: - Private methods

private extension DefaultChatListViewModel {
    
    func reconnect() {
        LogManager.trace("Reconnecting to the CXone chat services")
        
        CXoneChat.shared.delegate = self
        
        Task { @MainActor in
            isLoading = true
            
            do {
                try await CXoneChat.shared.connection.connect()
            } catch {
                error.logError()
                
                coordinator.dismiss(animated: true)
            }
        }
    }

    func updateCurrentThreads(with threads: [ChatThread]? = nil) {
        chatThreads = (threads ?? CXoneChat.shared.threads.get())
            .filter { (threadStatus == .current) == ($0.state != .closed) }
    }

    @MainActor
    func createNewThread(with customFields: [String: String]? = nil) async {
        LogManager.trace(customFields == nil ? "Creating new thread" : "Creating new thread with custom fields: \(String(describing: customFields))")
        
        do {
            if let customFields {
                try await CXoneChat.shared.threads.create(with: customFields)
            } else {
                try await CXoneChat.shared.threads.create()
            }
        } catch {
            error.logError()
            
            alertType = .unableToCreateThread(localization: localization)
        }
    }
    
    func navigateToThread(with id: UUID) {
        guard let thread = chatThreads.first(where: { $0.id == threadIdToOpen }) else {
            alertType = .unknownThreadFromDeeplink(localization: localization)
            return
        }
     
        threadIdToOpen = nil
            
        coordinator.showThread(thread)
    }
}
