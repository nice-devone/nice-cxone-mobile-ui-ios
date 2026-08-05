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

import Combine
import CXoneChatSDK
import SwiftUI

@MainActor
class ThreadListViewModel: ObservableObject {

    // MARK: - Properties
    
    @Published var chatThreads = [CXoneChatUI.ChatThread]()
    @Published var threadStatus: ThreadStatusType = .current
    @Published var currentThread: CXoneChatUI.ChatThread?
    @Published var isEditingThreadName = false

    /// Binding that drives whether `ThreadListView` is presenting a `ThreadView`.
    ///
    /// Reads as `true` whenever `currentThread` is non-nil, and writing `false` (e.g. when SwiftUI
    /// dismisses the destination on a back swipe) clears `currentThread`. This keeps the presented
    /// thread and the navigation-destination state in sync from a single source of truth without
    /// requiring callers to manage a separate `isPresented` flag.
    ///
    /// `MainActor.assumeIsolated` is safe here: SwiftUI always evaluates `Binding` get/set on the
    /// main actor, and this view model is `@MainActor` — the closures only ever run on the main thread.
    lazy var threadDestination = Binding {
        MainActor.assumeIsolated { [weak self] in
            self?.currentThread != nil
        }
    } set: { [weak self] newValue in
        MainActor.assumeIsolated {
            guard !newValue else {
                return
            }

            self?.currentThread = nil
        }
    }

    var selectedThread: ChatThread?

    var alertType: ChatAlertType? {
        get { containerViewModel?.alertType }
        set { containerViewModel?.alertType = newValue }
    }
    
    let chatProvider: ChatProvider

    private var threadToOpen: String?
    private var eventTask: Task<Void, Never>?

    weak var containerViewModel: ChatContainerViewModel?
    
    // MARK: - Lifecycle
    
    init(containerViewModel: ChatContainerViewModel) {
        self.chatProvider = containerViewModel.chatProvider
        self.containerViewModel = containerViewModel
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
        // Defer the @Published mutation to the next run loop turn to avoid the
        // "Publishing changes from within view updates" warning on iOS 16, where
        // List+ForEach can invoke button actions during an active layout pass.
        Task { @MainActor in
            self.currentThread = thread
        }

        return self
    }
    
    func onAppear() {
        LogManager.trace("Thread list view appeared")

        startObservingEvents()

        Task { [weak self] in
            self?.updateCurrentThreads()
        }
    }

    func onDisappear() {
        LogManager.trace("Thread list view disappeared")

        stopObservingEvents()
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
            
            self.alertType = .connectionErrorAlert {
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

    @MainActor
    func onArchive(_ thread: CXoneChatUI.ChatThread) async {
        LogManager.trace("Archiving thread")
        
        do {
            let provider = try chatProvider.threads.provider(for: thread.id)
            
            try await provider.archive()
        } catch {
            error.logError()
            
            alertType = .genericError
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
            
            self.alertType = .genericError
        }
        
        self.selectedThread = nil
    }
}

// MARK: - Event Handling

private extension ThreadListViewModel {

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
        case .chatUpdated(let state, _):
            LogManager.trace("updated state = \(String(describing: state))")

            if state == .ready, let threadToOpen = self.threadToOpen,
               chatProvider.threads.get().contains(where: { $0.id == threadToOpen }) {
                LogManager.trace("Opening thread with id \(threadToOpen)")

                self.threadToOpen = nil

                NotificationCenter.default.postThreadDeeplinkNotification(threadId: threadToOpen)
            }

        case .threadsUpdated(let threads):
            LogManager.scope { self.updateCurrentThreads(with: threads) }

        case .threadUpdated(let thread):
            LogManager.scope {
                if thread.state.isLoaded {
                    LogManager.trace("Setting shouldRefreshThread flag to refresh the thread")
                    self.containerViewModel?.shouldRefreshThread = true
                } else {
                    LogManager.trace("Skipping thread refresh - the thread is not loaded")
                }

                self.updateCurrentThreads()
            }

        default:
            break
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
