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

class ThreadListViewModel: NavigationItem {
    
    // MARK: - Properties
    
    @Published var chatThreads = [ChatThread]()
    @Published var preChatSurvey: PreChatSurvey?
    @Published var thread: ChatThread?
    @Published var threadStatus: ThreadStatusType = .current
    @Published var alertType: ChatAlertType?
    @Published var isLoading = false
    
    let chatProvider: ChatProvider
    
    private var localization: ChatLocalization
    private var cancellables = [AnyCancellable]()

    weak var containerViewModel: ChatContainerViewModel?
    
    var isMultiThread: Bool { chatProvider.connection.channelConfiguration.hasMultipleThreadsPerEndUser }
    
    // MARK: - Lifecycle
    
    init(containerViewModel: ChatContainerViewModel) {
        self.chatProvider = containerViewModel.chatProvider
        self.containerViewModel = containerViewModel
        self.localization = containerViewModel.chatLocalization

        super.init(
            left: containerViewModel.back(title: localization.commonCancel, action: nil),
            title: Text(localization.chatListTitle)
        )

        content = {
            AnyView(ThreadListView(viewModel: self))
        }
        
        $threadStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateMenuActions() }
            .store(in: &cancellables)
    }
}

// MARK: - Actions

extension ThreadListViewModel {
    
    func onAppear() {
        LogManager.trace("Thread list view appeared")
        
        chatProvider.add(delegate: self)
        
        updateCurrentThreads()
    }
    
    func onDisappear() {
        LogManager.trace("Chat list view disappeared")
        
        chatProvider.remove(delegate: self)
    }
    
    func onCreateNewThread() {
        LogManager.trace("Trying to create a new thread")
        
        containerViewModel?.createThread(
            onCancel: { [weak containerViewModel] in
                containerViewModel?.showThreadList()
            },
            onSuccess: { [weak containerViewModel] thread in
                containerViewModel?.show(thread: thread) { [weak containerViewModel] in
                    containerViewModel?.showThreadList()
                }
            }
        )
    }

    func updateThreadStatus(_ status: ThreadStatusType) {
        LogManager.trace("Changing thread list to \(status)")
        
        threadStatus = status
        
        updateCurrentThreads()
    }
    
    func onThreadTapped(_ thread: ChatThread) {
        LogManager.trace("Opening chat window")
        
        containerViewModel?.show(thread: thread) { [weak containerViewModel] in
            containerViewModel?.showThreadList()
        }
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
            try chatProvider.threads.archive(thread)

            isLoading = true
        } catch {
            error.logError()
            alertType = .genericError(localization: localization) { [weak self] in
                self?.containerViewModel?.onDismiss()
            }
        }
    }
}

// MARK: - CXoneChatDelegate

extension ThreadListViewModel: CXoneChatDelegate {

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
            
            isLoading = false
        }
    }
    
    func onThreadsUpdated(_ chatThreads: [ChatThread]) {
		LogManager.trace("Threads has been updated")

        Task { @MainActor in
            updateCurrentThreads(with: chatThreads)
            
            isLoading = false
        }
    }

    func onUnexpectedDisconnect() {
        LogManager.trace("Unexpected disconnect did occur")
        
        reconnect()
    }
    
    func onTokenRefreshFailed() {
        LogManager.trace("Token refresh failed")
        
        do {
            try chatProvider.customer.set(customer: nil)
        } catch {
            error.logError()
        }

        containerViewModel?.disconnect()
    }

    func onError(_ error: Error) {
        error.logError()
        
        Task { @MainActor in
            isLoading = false
        }
    }
}

// MARK: - Private methods

private extension ThreadListViewModel {
    
    func reconnect() {
        LogManager.trace("Reconnecting to the CXone chat services")
        
        chatProvider.add(delegate: self)
        
        Task { @MainActor in
            isLoading = true
            
            do {
                try await chatProvider.connection.connect()
            } catch {
                error.logError()
                
                containerViewModel?.disconnect()
            }
        }
    }

    func updateCurrentThreads(with threads: [ChatThread]? = nil) {
        chatThreads = (threads ?? chatProvider.threads.get())
            .filter { (threadStatus == .current) == ($0.state != .closed) }
    }

    @MainActor
    func createNewThread(with customFields: [String: String]? = nil) async {
        LogManager.trace(customFields == nil ? "Creating new thread" : "Creating new thread with custom fields: \(String(describing: customFields))")
        
        do {
            if let customFields {
                try await chatProvider.threads.create(with: customFields)
            } else {
                try await chatProvider.threads.create()
            }
        } catch {
            error.logError()
            
            alertType = .unableToCreateThread(localization: localization)
        }
    }
    
    func updateMenuActions() {
        LogManager.trace("Updating menu actions")
        
        if threadStatus == .current {
            self.right = [
                NavigationAction(title: "", image: Image(systemName: "plus")) { [weak self] in
                    self?.onCreateNewThread()
                }
            ]
        } else {
            self.right = []
        }
    }
}
