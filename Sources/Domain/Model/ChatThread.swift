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

import CXoneChatSDK
import Foundation

/// All information about a chat thread as well as the messages for the thread.
struct ChatThread: Identifiable {
    
    // MARK: - Properties
    
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

    /// The agent that owns the case — the last agent it was actually assigned to.
    ///
    /// Persists across unassignment and is used to determine that the customer has already been engaged by
    /// an agent (and is therefore no longer in the queue), notably after a thread recover.
    let ownerAssignee: Agent?

    /// The token for the scroll position used to load more messages.
    let scrollToken: String
    
    /// The thread state
    let state: ChatThreadState

    /// The position in the queue
    let positionInQueue: Int?

    /// The party currently responsible for handling the contact behind this thread.
    ///
    /// `nil` when the platform reports no handler for the channel.
    let contactHandler: ContactHandler?
    
    /// Whether there are more messages to load in the thread.
    var hasMoreMessagesToLoad: Bool {
        !messages.isEmpty && !scrollToken.isEmpty
    }
    
    // MARK: - Init

    init(
        id: String,
        name: String?,
        messages: [Message],
        assignedAgent: Agent?,
        lastAssignedAgent: Agent?,
        ownerAssignee: Agent?,
        scrollToken: String,
        state: ChatThreadState,
        positionInQueue: Int?,
        contactHandler: ContactHandler? = nil
    ) {
        self.id = id
        self.name = name
        self.messages = messages
        self.assignedAgent = assignedAgent
        self.lastAssignedAgent = lastAssignedAgent
        self.ownerAssignee = ownerAssignee
        self.scrollToken = scrollToken
        self.state = state
        self.positionInQueue = positionInQueue
        self.contactHandler = contactHandler
    }
    
    // MARK: - Computed Properties

    /// Whether the contact is currently handled by a party other than CXone - today, the Cognigy bot.
    ///
    /// `false` when the platform reports no handler at all, so channels without the capability keep behaving
    /// exactly as they did before. An unrecognized handler counts as non-CXone, so a future bot integration
    /// suppresses the queue overlay without an SDK release.
    var isHandledByNonCxone: Bool {
        guard let contactHandler else {
            return false
        }

        return contactHandler != .cxone
    }

    /// Determines the conversation title.
    ///
    /// Uses the following priority:
    /// 1. Explicit thread name (customer-provided in multi-thread scenarios)
    /// 2. Assigned agent: nickname, then full name, then a generic agent fallback
    /// 3. Last assigned agent: nickname, then full name, then a generic agent fallback
    /// 4. Owner assignee: nickname, then full name, then a generic agent fallback
    ///    (e.g. on recover, where only the owner assignee is known)
    /// 5. If no agent information is available: unassigned agent fallback
    ///
    /// - Returns: The best available title string.
    var titleForConversation: String {
        if let explicitName = name?.nilIfEmpty() {
            return explicitName
        } else if let assignedAgent {
            return assignedAgent.displayName ?? L10n.Common.agent
        } else if let lastAssignedAgent {
            return lastAssignedAgent.displayName ?? L10n.Common.agent
        } else if let ownerAssignee {
            return ownerAssignee.displayName ?? L10n.Common.agent
        }

        // No assigned or previous agent available.
        return L10n.Common.unassignedAgent
    }

    /// The most recently created message, or `nil` when the thread has no messages.
    ///
    /// When several messages share the newest `createdAt`, the one appended last wins.
    var latestMessage: Message? {
        messages.reversed().max { first, second in
            first.createdAt < second.createdAt
        }
    }

    /// The creation date of the most recent message, or `nil` when the thread has no messages.
    var latestMessageDate: Date? {
        latestMessage?.createdAt
    }

    /// Whether the conversation is currently being handled by an AI assistant.
    ///
    /// `true` when the most recent agent (outbound) message is AI-generated; turns `false` once a human agent replies.
    /// Used to drive the "AI Assistant" authorship indicator in the chat navigation bar.
    var isAiAssistant: Bool {
        messages.last { message in
            message.direction == .toClient
        }?.isAiGenerated ?? false
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
            && lhs.ownerAssignee == rhs.ownerAssignee
            && lhs.scrollToken == rhs.scrollToken
            && lhs.state == rhs.state
            && lhs.positionInQueue == rhs.positionInQueue
            && lhs.contactHandler == rhs.contactHandler
    }
}
