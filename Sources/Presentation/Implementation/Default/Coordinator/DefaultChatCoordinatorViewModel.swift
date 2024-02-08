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

class DefaultChatCoordinatorViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var showThreadList = false
    @Published var chatThread: ChatThread?
    
    let coordinator: DefaultChatCoordinator
    
    // MARK: - Init
    
    init(coordinator: DefaultChatCoordinator) {
        self.coordinator = coordinator
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
}

// MARK: - CXoneChatDelegate

extension DefaultChatCoordinatorViewModel: CXoneChatDelegate {
    
    func onChatUpdated(_ chatState: ChatState, mode: ChatMode) {
        guard [.ready, .closed].contains(chatState) else {
            return
        }
        
        Task { @MainActor in
            if mode == .multithread {
                LogManager.trace("Chat(`.multithread`) is ready to use but there are no threads -> entering chat threadl list")
                
                CXoneChat.shared.delegate = nil
                
                showThreadList = true
            } else {
                if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
                    LogManager.trace("Chat(`.singlethread`) is ready to use but there is no thread to use but firstly it is need to fill in the prechat")
                    
                    let fieldEntities = preChatSurvey.customFields.map(FormCustomFieldTypeMapper.map)

                    coordinator.presentForm(title: preChatSurvey.name, customFields: fieldEntities) { [weak self] customFields in
                        LogManager.trace("Pre-chat was filled successfully -> create a new thread")
                        
                        self?.createNewThread(with: customFields)
                    }
                } else {
                    LogManager.trace("Chat is ready to use but there is no thread to use -> chat mode = `.singlethread` -> creating a new thread")
                    
                    createNewThread()
                }
            }
        }
        
    }
    
    func onThreadUpdated(_ chatThread: ChatThread) {
        LogManager.trace("Thread was successfully recovered or created -> chat mode = `.singlethread` -> entering chat directly")
        
        Task { @MainActor in
            CXoneChat.shared.delegate = nil
            
            self.chatThread = chatThread
        }
    }
    
    func onThreadsUpdated(_ chatThreads: [ChatThread]) {
        LogManager.trace("Threads have been successfully loaded with metadata -> chat `mode = .multithread` -> entering chat thread list")
        
        Task { @MainActor in
            CXoneChat.shared.delegate = nil
            
            showThreadList = true
        }
    }
}

// MARK: - Private methods

private extension DefaultChatCoordinatorViewModel {
    
    func createNewThread(with customFields: [String: String]? = nil) {
        do {
            if let customFields {
                try CXoneChat.shared.threads.create(with: customFields)
            } else {
                try CXoneChat.shared.threads.create()
            }
        } catch {
            error.logError()
        }
    }
}
