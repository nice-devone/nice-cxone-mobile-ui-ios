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

import CXoneChatSDK
import SwiftUI

class DefaultChatListViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var chatThreads = [ChatThread]()
    
    @Published var presentGenericError = false
    @Published var presentUnableToCreateThreadError = false
    @Published var presentUnknownThreadFromDeeplinkError = false
    @Published var presentDisconnectAlert = false
    
    @Published var preChatSurvey: PreChatSurvey?
    @Published var thread: ChatThread?
    
    private let coordinator: DefaultChatCoordinator
    
    private var threadIdToOpen: UUID?
    
    var threadsStatus: ThreadsStatusType = .current
    var isMultiThread: Bool { CXoneChat.shared.connection.channelConfiguration.hasMultipleThreadsPerEndUser }
    var dismiss = false
    var isLoading = false
    
    // MARK: - Lifecycle
    
    init(coordinator: DefaultChatCoordinator, threadIdToOpen: UUID? = nil) {
        self.coordinator = coordinator
        self.threadIdToOpen = threadIdToOpen
    }
}

// MARK: - Actions

extension DefaultChatListViewModel {
    
    func onAppear() {
        LogManager.trace("Default chat list view appeared")
        
        CXoneChat.shared.delegate = self
        
        if CXoneChat.shared.state.isChatAvailable {
            updateCurrentThreads()
                
            if let threadIdToOpen {
                navigateToThread(with: threadIdToOpen)
            }
        } else {
            Task { @MainActor in
                isLoading = true
                
                reconnect()
            }
        }
    }
    
    func onDisconnectTapped() {
        LogManager.trace("Disconnecting from CXoneChat services")

        CXoneChat.shared.delegate = nil
        
        CXoneChat.shared.connection.disconnect()
        coordinator.onFinished?()
        
        dismiss = true
    }
    
    func onCreateNewThread() {
        LogManager.trace("Trying to create a new thread")

        if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
            let fieldEntities = preChatSurvey.customFields.map(FormCustomFieldTypeMapper.map)
            
            coordinator.presentForm(title: preChatSurvey.name, customFields: fieldEntities) { [weak self] customFields in
                self?.createNewThread(with: customFields)
            }
        } else {
            createNewThread()
        }
    }
    
    func updateThreadsStatus(_ status: ThreadsStatusType) {
        LogManager.trace("Changing thread list to \(status.rawValue)")
        
        threadsStatus = status
        
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
            
            presentGenericError = true
        }
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
        
        isLoading = true
        
        reconnect()
    }
    
    func onTokenRefreshFailed() {
        LogManager.trace("Token refresh failed")
        
        CXoneChat.shared.customer.set(nil)

        dismiss = true
    }

    func onError(_ error: Error) {
        error.logError()
        
        isLoading = false
    }
    
    func willEnterForeground() {
        reconnect()
    }
    
    func didEnterBackgroundNotification() {
        LogManager.trace("Entering background")
        
        CXoneChat.shared.connection.disconnect()
    }
}

// MARK: - Private methods

private extension DefaultChatListViewModel {
    
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

    func updateCurrentThreads(with threads: [ChatThread]? = nil) {
        chatThreads = (threads ?? CXoneChat.shared.threads.get())
            .filter { (threadsStatus == .current) == ($0.state != .closed) }
    }
    
    func createNewThread(with customFields: [String: String]? = nil) {
        LogManager.trace(customFields == nil ? "Creating new thread" : "Creating new thread with custom fields: \(String(describing: customFields))")
        
        do {
            if let customFields {
                try CXoneChat.shared.threads.create(with: customFields)
            } else {
                try CXoneChat.shared.threads.create()
            }
        } catch {
            error.logError()
            
            presentUnableToCreateThreadError = true
        }
    }
    
    func navigateToThread(with id: UUID) {
        guard let thread = chatThreads.first(where: { $0.id == threadIdToOpen }) else {
            return
        }
     
        threadIdToOpen = nil
            
        coordinator.showThread(thread)
    }
}
