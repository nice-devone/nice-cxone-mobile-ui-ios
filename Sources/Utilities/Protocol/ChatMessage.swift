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
import Foundation

/// Represents a chat message within a CXoneChatUI module.
///
/// This struct encapsulates information about a chat message,
/// including its unique identifier, sender, message types, sending date and time, and delivery/read status.
public struct ChatMessage: Identifiable {
    
    /// A unique identifier for the chat message.
    public let id: UUID
    
    /// The sender of the chat message, conforming to the `ChatUser` protocol. Could be agent or customer.
    public let user: ChatUser
    
    /// Types of the chat message (e.g., text, image, file).
    public var types: [ChatMessageType]
    
    /// The date and time when the message was sent.
    public let date: Date
    
    /// The delivery or read status of the message.
    public var status: MessageStatus
    
    // MARK: - Init
    
    /// Initialization of the ChatMessage
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the chat message.
    ///   - user: The sender of the chat message, conforming to the `ChatUser` protocol. Could be agent or customer.
    ///   - types: Types of the chat message (e.g., text, image, file).
    ///   - date: The date and time when the message was sent.
    ///   - status: The delivery or read status of the message.
    public init(id: UUID, user: ChatUser, types: [ChatMessageType], date: Date, status: MessageStatus) {
        self.id = id
        self.user = user
        self.types = types
        self.date = date
        self.status = status
    }
}

// MARK: - Equatable

extension ChatMessage: Equatable {
    
    /// Checks whether two chat messages are equal by comparing their unique identifiers.
    ///
    /// - Parameters:
    ///   - lhs: A chat message.
    ///   - rhs: Another chat message.
    /// - Returns: `true` if the chat messages have the same unique identifier; otherwise, `false`.
    public static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
            && lhs.user == rhs.user
            && lhs.types == rhs.types
            && lhs.date == rhs.date
            && lhs.status == rhs.status
    }
}

// MARK: - Helpers

extension ChatMessage {
    
    var richContentMessages: Bool {
        !types.contains {
            switch $0 {
            case .richContent:
                return false
            default:
                return true
            }
        }
    }
}
