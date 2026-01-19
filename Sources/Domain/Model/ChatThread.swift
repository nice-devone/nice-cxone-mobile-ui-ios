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
import Foundation

/// All information about a chat thread as well as the messages for the thread.
struct ChatThread: Identifiable {
    
    /// The unique id of the thread. Refers to the `idOnExternalPlatform`.
    let id: String
    
    /// The name given to the thread (for multi-thread channels only).
    let name: String?
    
    /// The list of messages on the thread.
    let messages: [Message]

    /// The agent assigned in the thread.
    let assignedAgent: Agent?
    
    /// The last agent that has been assigned to the thread
    ///
    /// This attribute can be used to get the previously assigned agent back to the thread after unassignment.
    let lastAssignedAgent: Agent?
    
    /// The token for the scroll position used to load more messages.
    let scrollToken: String
    
    /// The thread state
    let state: ChatThreadState

    /// The position in the queue
    let positionInQueue: Int?
    
    /// Whether there are more messages to load in the thread.
    var hasMoreMessagesToLoad: Bool {
        !messages.isEmpty && !scrollToken.isEmpty
    }
    
}

// MARK: - Equatable

extension ChatThread: Equatable {
    
    static func == (lhs: ChatThread, rhs: ChatThread) -> Bool {
        lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.messages == rhs.messages
            && lhs.assignedAgent == rhs.assignedAgent
            && lhs.lastAssignedAgent == rhs.lastAssignedAgent
            && lhs.scrollToken == rhs.scrollToken
            && lhs.state == rhs.state
            && lhs.positionInQueue == rhs.positionInQueue
    }
}
