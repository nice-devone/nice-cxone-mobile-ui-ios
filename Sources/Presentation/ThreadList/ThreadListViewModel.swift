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

class ThreadListViewModel: ObservableObject {

    // MARK: - Properties
    
    @Published var chatThreads = [CXoneChatUI.ChatThread]()
    @Published var threadStatus: ThreadStatusType = .current
    @Published var threadToShow: CXoneChatUI.ChatThread?
    @Published var hiddenThreadToShow: CXoneChatUI.ChatThread?
    @Published var isEditingThreadName = false

    lazy var showThread = Binding { [weak self] in
        self?.threadToShow != nil
    } set: { [weak self] _ in
        self?.threadToShow = nil
    }
    lazy var showHiddenThread = Binding { [weak self] in
        self?.hiddenThreadToShow != nil
    } set: { [weak self] _ in
        self?.hiddenThreadToShow = nil
    }
    
    var selectedThread: ChatThread?

    let chatProvider: ChatProvider

    var alertType: ChatAlertType? {
        get { containerViewModel?.alertType }
        set { containerViewModel?.alertType = newValue }
    }
    
    private var localization: ChatLocalization
    private var threadToOpen: String?

    weak var containerViewModel: ChatContainerViewModel?
    
    // MARK: - Lifecycle
    
    init(containerViewModel: ChatContainerViewModel) {
        self.chatProvider = containerViewModel.chatProvider
        self.containerViewModel = containerViewModel
        self.localization = containerViewModel.chatLocalization
        self.threadToOpen = containerViewModel.threadToOpen
    }

    @MainActor
    func viewModel(for thread: CXoneChatUI.ChatThread?) -> ThreadViewModel? {
        containerViewModel?.viewModel(for: thread)
    }
}

// MARK: - Actions

extension ThreadListViewModel {
 
    @discardableResult
    func show(thread: CXoneChatUI.ChatThread?) -> ThreadListViewModel {
        threadToShow = thread
        
        return self
    }
    
    func onAppear() {
        LogManager.trace("Thread list view appeared")
        
        chatProvider.add(delegate: self)
        
        Task { @MainActor [weak self] in
            self?.updateCurrentThreads()
        }
    }
    
    func onDisappear() {
        LogManager.trace("Thread list view disappeared")
        
        containerViewModel?.chatProvider.remove(delegate: self)
    }
    
    @MainActor
    func onCreateNewThread() async {
        guard chatProvider.state.isChatAvailable else {
            LogManager.warning("Unable to create a new thread - chat is not available yet")
            return
        }
        
        LogManager.trace("Trying to create a new thread")

        do {
            guard let threadProvider = try await containerViewModel?.createThread() else {
                LogManager.trace("New thread was not created because customer cancelled a prechat survey -> disconnecting")
                await containerViewModel?.disconnect()
                return
            }
            
            show(thread: ChatThreadMapper.map(from: threadProvider.chatThread))
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
    func updateThreadStatus(_ status: ThreadStatusType) {
        LogManager.trace("Changing thread list to \(status)")

        self.threadStatus = status
        
        self.updateCurrentThreads()
    }

    func onSwipeToArchive(offsets: IndexSet) {
        guard let archivedThread = offsets.compactMap({ chatThreads[safe: $0] }).first else {
            LogManager.error(.failed("Unable to get thread for archiving."))
            return
        }

        Task { @MainActor [weak self] in
            await self?.onArchive(archivedThread)
        }
    }
    
    @MainActor
    func onArchive(_ thread: CXoneChatUI.ChatThread) async {
        LogManager.trace("Archiving thread")
        
        do {
            let provider = try chatProvider.threads.provider(for: thread.id)
            
            try await provider.archive()
        } catch {
            error.logError()
            
            alertType = .genericError(localization: localization)
        }
    }
    
    @MainActor
    func onEditThreadName(for thread: ChatThread) {
        self.isEditingThreadName = true
        self.selectedThread = thread
    }

    @MainActor
    func setThreadName(_ name: String) async {
        LogManager.trace("Setting thread name to \(name)")
        
        guard let selectedThread, let threadProvider = try? chatProvider.threads.provider(for: selectedThread.id) else {
            LogManager.error("Unexpected nil thread")
            return
        }
        
        do {
            try await threadProvider.updateName(name)
        } catch {
            error.logError()
            
            self.alertType = .genericError(localization: localization)
        }
        
        self.selectedThread = nil
    }
}

// MARK: - CXoneChatDelegate

extension ThreadListViewModel: CXoneChatDelegate {

    func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
        LogManager.scope {
            LogManager.trace("updated state = \(String(describing: chatState))")
            
            if chatState == .ready, let threadToOpen, let thread = chatProvider.threads.get().first(where: { $0.idString == threadToOpen }) {
                LogManager.trace("Opening thread with id \(thread.idString)")
                
                self.threadToOpen = nil
                
                NotificationCenter.default.postThreadDeeplinkNotification(threadId: threadToOpen)
            }
        }
    }

    func onThreadsUpdated(_ chatThreads: [CXoneChatSDK.ChatThread]) {
        LogManager.scope { [weak self] in
            Task { @MainActor in
                self?.updateCurrentThreads(with: chatThreads)
            }
        }
    }
    
    func onThreadUpdated(_ chatThread: CXoneChatSDK.ChatThread) {
        LogManager.scope { [weak self] in
            if chatThread.state.isLoaded {
                LogManager.trace("Setting shouldRefreshThread flag to refresh the thread")
                
                self?.containerViewModel?.shouldRefreshThread = true
            } else {
                LogManager.trace("Skipping thread refresh - the thread is not loaded")
            }
            
            Task { @MainActor in
                self?.updateCurrentThreads()
            }
        }
    }
}

// MARK: - Private methods

private extension ThreadListViewModel {

    @MainActor
    func updateCurrentThreads(with threads: [CXoneChatSDK.ChatThread]? = nil) {
        chatThreads = (threads ?? chatProvider.threads.get())
            .filter { (threadStatus == .current) == ($0.state != .closed) }
            .sorted { (thread1, thread2) in
                // Sort by the most recent message's createdAt field
                let latestMessage1 = thread1.messages.max { $0.createdAt < $1.createdAt }?.createdAt ?? Date.distantPast
                let latestMessage2 = thread2.messages.max { $0.createdAt < $1.createdAt }?.createdAt ?? Date.distantPast
                return latestMessage1 > latestMessage2
            }
            .compactMap(ChatThreadMapper.map)
    }
}
