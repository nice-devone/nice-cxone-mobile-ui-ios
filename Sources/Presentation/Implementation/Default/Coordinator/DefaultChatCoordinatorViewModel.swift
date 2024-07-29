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

class DefaultChatCoordinatorViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var showOfflineLiveChat = false
    @Published var showThreadList = false
    @Published var chatThread: ChatThread?
    
    @Published var chatViewModel: DefaultChatViewModel?
    @Published var chatListViewModel: DefaultChatListViewModel?
    
    let coordinator: DefaultChatCoordinator
    
    // MARK: - Init
    
    init(coordinator: DefaultChatCoordinator) {
        self.coordinator = coordinator
    }
    
    func initializeViewModels(localization: ChatLocalization) {
        self.chatViewModel = DefaultChatViewModel(thread: self.chatThread, coordinator: self.coordinator, localization: localization)
        self.chatListViewModel = DefaultChatListViewModel(coordinator: self.coordinator, localization: localization)
    }
    
    // MARK: - Methods
    
    func onAppear() {
        CXoneChat.shared.delegate = self
        
        Task {
            do {
                try await CXoneChat.shared.connection.connect()
            } catch {
                error.logError()
            }
        }
    }
    
    func onBackButtonTapped() {
        LogManager.trace("Disconnecting from chat services")

        CXoneChat.shared.delegate = nil
        CXoneChat.shared.connection.disconnect()
        
        coordinator.dismiss(animated: true)
    }
}

// MARK: - CXoneChatDelegate

extension DefaultChatCoordinatorViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
        guard [.offline, .ready, .closed].contains(chatState) else {
            LogManager.trace("Ignoring chat state `.\(chatState)`")
            return
        }
        
        Task { @MainActor in
            if mode == .liveChat, chatState == .offline {
                LogManager.trace("Chat(`.liveChat`) but also offline -> show offline view")
                
                showOfflineLiveChat = true
            } else if mode == .multithread {
                LogManager.trace("Chat(`.multithread`) is ready to use but there are no threads -> enter chat thread list")
                
                CXoneChat.shared.delegate = nil
                
                showThreadList = true
            } else {
                if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
                    let chatMode = mode == .liveChat ? ".liveChat" : ".singlethread"
                    LogManager.trace("Chat(\(chatMode)) is ready to use but there is no thread to use but firstly it is need to fill in the prechat")
                    
                    let fieldEntities = preChatSurvey.customFields.map { prechatField in
                        FormCustomFieldTypeMapper.map(prechatField, with: [:])
                    }

                    coordinator.presentForm(
                        title: preChatSurvey.name,
                        customFields: fieldEntities,
                        onFinished: { customFields in
                            LogManager.trace("Pre-chat was filled successfully -> create a new thread")
                            
                            Task { @MainActor in
                                await self.createNewThread(with: customFields)
                            }
                        }, 
                        onCancel: { [weak self] in
                            LogManager.trace("Disconnecting from chat services")

                            CXoneChat.shared.delegate = nil
                            CXoneChat.shared.connection.disconnect()
                            
                            self?.coordinator.dismiss(animated: true)
                        }
                    )
                } else {
                    LogManager.trace("Chat is ready to use but there is no thread to use -> chat mode = `.singlethread` -> creat a new thread")
                    
                    await createNewThread()
                }
            }
        }
        
    }
    
    func onThreadUpdated(_ chatThread: ChatThread) {
        LogManager.trace("Thread was successfully recovered or created -> chat mode = `.singlethread` -> enter chat directly")
        
        Task { @MainActor in
            self.chatThread = chatThread
            self.chatViewModel?.thread = chatThread
            
            CXoneChat.shared.delegate = self.chatViewModel
        }
    }
    
    func onThreadsUpdated(_ chatThreads: [ChatThread]) {
        LogManager.trace("Threads have been successfully loaded with metadata -> chat `mode = .multithread` -> enter chat thread list")
        
        Task { @MainActor in
            CXoneChat.shared.delegate = nil
            
            showThreadList = true
        }
    }
}

// MARK: - Private methods

private extension DefaultChatCoordinatorViewModel {
    
    @MainActor
    func createNewThread(with customFields: [String: String]? = nil) async {
        do {
            if let customFields {
                try await CXoneChat.shared.threads.create(with: customFields)
            } else {
                try await CXoneChat.shared.threads.create()
            }
        } catch {
            error.logError()
        }
    }
}
