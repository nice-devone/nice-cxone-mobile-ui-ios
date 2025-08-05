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

class ChatContainerViewModel: ObservableObject {
    typealias ChildViewModel = NavigationItem

    // MARK: - Properties

    @Published var currentChild: ChildViewModel
    
    let chatProvider: ChatProvider
    var threadToOpen: String?
    let chatLocalization: ChatLocalization
    let onDismiss: () -> Void

    // MARK: - Init

    init(
        chatProvider: ChatProvider,
        threadToOpen: String? = nil,
        chatLocalization: ChatLocalization,
        onDismiss: @escaping () -> Void
    ) {
        self.chatProvider = chatProvider
        self.threadToOpen = threadToOpen
        self.chatLocalization = chatLocalization
        self.onDismiss = onDismiss
        self.currentChild = ChildViewModel { AnyView(EmptyView()) }

        self.show(message: chatLocalization.commonLoading)
    }

    // MARK: - Methods

    func onAppear() {
        LogManager.trace("View did appear")

        chatProvider.add(delegate: self)
        
        Task {
            do {
                try await CXoneChat.shared.connection.connect()
            } catch {
                error.logError()
            }
        }
    }
    
    func onDisappear() {
        LogManager.trace("View did disappear")
        
        chatProvider.remove(delegate: self)
        
        chatProvider.connection.disconnect()
    }
}

// MARK: - Utilities

extension ChatContainerViewModel {
    
    func back(title: String, action: (() -> Void)?) -> NavigationAction {
        LogManager.trace("Navigating back to the previous screen")
        
        if let action = action {
            return .back(title: title, action: action)
        } else {
            return .down(title: "") { [weak self] in
                self?.onDismiss()
            }
        }
    }
}

// MARK: - Chat Actions

extension ChatContainerViewModel {
    
    func disconnect() {
        LogManager.trace("Disconnecting from chat services")
        
        chatProvider.connection.disconnect()
        
        onDismiss()
    }

    func show(message: String) {
        LogManager.trace("Showing status message: \(message)")
        
        DispatchQueue.main.async { [weak self] in
            guard let model = self else { 
                return
            }
            
            model.currentChild = StatusMessageViewModel(containerViewModel: model, message: message)
        }
    }

    func showOffline() {
        LogManager.trace("Showing offline view")
        
        DispatchQueue.main.async { [weak self] in
            guard let model = self else {
                return
            }

            model.currentChild = OfflineViewModel(containerViewModel: model, localization: model.chatLocalization)
        }
    }

    func showThreadList() {
        LogManager.trace("Showing thread list")
        
        DispatchQueue.main.async { [weak self] in
            guard let model = self else {
                return
            }
            
            model.currentChild = ThreadListViewModel(containerViewModel: model)
        }
    }

    func show(thread: ChatThread, onBack: (() -> Void)? = nil) {
        LogManager.trace("Showing thread with id: \(thread.idString)")
        
        DispatchQueue.main.async { [weak self] in
            guard let model = self else {
                return
            }
            
            model.currentChild = ThreadViewModel(thread: thread, containerViewModel: model, onBack: onBack)
        }
    }

    func showForm(title: String, fields: [FormCustomFieldType], onAccept: @escaping ([String: String]) -> Void, onCancel: @escaping () -> Void) {
        LogManager.trace("Showing form with title: \(title)")
        
        DispatchQueue.main.async { [weak self] in
            guard let model = self else {
                return
            }
            
            model.currentChild = FormViewModel(
                containerViewModel: model,
                title: title,
                customFields: fields,
                localization: model.chatLocalization, 
                onAccept: onAccept,
                onCancel: onCancel
            )
        }
    }

    func createThread(onCancel: @escaping () -> Void, onSuccess: @escaping (ChatThread) -> Void) {
        if let preChatSurvey = chatProvider.threads.preChatSurvey {
            LogManager.trace("Present pre-chat form because thread creation")
            
            let fieldEntities = preChatSurvey.customFields.map { prechatField in
                FormCustomFieldTypeMapper.map(prechatField, with: [:])
            }

            showForm(
                title: preChatSurvey.name,
                fields: fieldEntities,
                onAccept: { [weak self] customFields in
                    LogManager.trace("Pre-chat was filled successfully -> create a new thread")
                    guard let self else {
                        return
                    }
                    
                    self.show(message: self.chatLocalization.commonLoading)
                    
                    Task { [weak self] in
                        guard let self else {
                            return
                        }
                        
                        await self.createNewThread(with: customFields).map(onSuccess)
                    }
                },
                onCancel: onCancel
            )
        } else {
            LogManager.trace("Create thread with no prechat")
            
            Task {
                await createNewThread().map(onSuccess)
            }
        }
    }

    func show(fatal error: Error) {
        error.logError()
        
        show(fatal: error.localizedDescription)
    }

    func show(fatal message: String) {
        LogManager.trace("Showing fatal error status message: \(message)")
        
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            self.currentChild = StatusMessageViewModel(containerViewModel: self, title: self.chatLocalization.commonFatalError, message: message)
        }
    }
    
    func willEnterForeground(_ output: NotificationCenter.Publisher.Output) {
        LogManager.trace("Enter foreground")
        
        Task {
            LogManager.trace("Reconnecting to the CXone chat services")
            
            do {
                try await CXoneChat.shared.connection.connect()
            } catch {
                show(fatal: error)
            }
        }
    }
    
    func didEnterBackground(_ output: NotificationCenter.Publisher.Output) {
        LogManager.trace("Enter background")
        
        CXoneChat.shared.connection.disconnect()
    }
}

// MARK: - CXoneChatDelegate

extension ChatContainerViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
        LogManager.trace("ChatCoordinatorViewModel: chat state = \(chatState)")

        switch chatState {
        case .connecting:
            show(message: chatLocalization.commonConnecting)
        case .connected:
            show(message: chatLocalization.commonLoading)
        case .offline:
            showOffline()
        case .ready:
            startChat()
        default:
            LogManager.trace("ChatCoordinatorViewModel: ignoring \(chatState)")
        }

    }
    
    private func startChat() {
        LogManager.trace("Starting \(chatProvider.mode) chat")
        
        switch chatProvider.mode {
        case .multithread:
            if let uuid = threadToOpen, let thread = chatProvider.threads.get().first(where: { $0.idString == uuid }) {
                show(thread: thread, onBack: showThreadList)
            } else {
                showThreadList()
            }
            
            threadToOpen = nil

        case .singlethread, .liveChat:
            if let thread = chatProvider.threads.get().first, thread.state != .closed {
                show(thread: thread)
            } else {
                createThread(onCancel: onDismiss) { [weak self] thread in
                    self?.show(thread: thread)
                }
            }
        }
    }
}

// MARK: - Private methods

private extension ChatContainerViewModel {
    
    func createNewThread(with customFields: [String: String]? = nil) async -> ChatThread? {
        do {
            if let customFields {
                return try await chatProvider.threads.create(with: customFields)
            } else {
                return try await chatProvider.threads.create()
            }
        } catch {
            show(fatal: error)
            
            return nil
        }
    }
}
