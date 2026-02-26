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

/// Represents a chat message within a CXoneChatUI module.
///
/// This struct encapsulates information about a chat message,
/// including its unique identifier, sender, message types, sending date and time, and delivery/read status.
public struct ChatMessage: Identifiable, Equatable {
    
    /// A unique identifier for the chat message.
    @available(*, deprecated, renamed: "idString", message: "Use `idString`. It preserves the original case-sensitive identifier from the backend.")
    public let id: UUID // swiftlint:disable:this no_uuid
    
    /// A unique identifier for the chat message.
    public let idString: String
    
    /// The sender of the chat message, conforming to the `ChatUser` protocol. Could be agent or customer.
    public let user: ChatUser?
    
    /// Types of the chat message (e.g., text, image, file).
    public var types: [ChatMessageType]
    
    /// The date and time when the message was sent.
    public let date: Date
    
    /// The delivery or read status of the message.
    public var status: MessageStatus
    
    /// System-generated messages (welcome messages, TORM content) have no sender (nil user) and should display as agent messages
    var isUserAgent: Bool {
        user?.isAgent ?? true
    }
    
    // MARK: - Init
    
    /// Initialization of the ChatMessage
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the chat message.
    ///   - user: The sender of the chat message, conforming to the `ChatUser` protocol. Could be agent or customer.
    ///   - types: Types of the chat message (e.g., text, image, file).
    ///   - date: The date and time when the message was sent.
    ///   - status: The delivery or read status of the message.
    @available(*, deprecated, message: "Due to replacement of the `id` atrribute with `idString`, this initializer will be removed in a future.")
    public init(id: UUID, user: ChatUser?, types: [ChatMessageType], date: Date, status: MessageStatus) { // swiftlint:disable:this no_uuid
        self.id = id
        self.idString = id.uuidString
        self.user = user
        self.types = types
        self.date = date
        self.status = status
    }
    
    /// Initialization of the ChatMessage
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the chat message.
    ///   - user: The sender of the chat message, conforming to the `ChatUser` protocol. Could be agent or customer.
    ///   - types: Types of the chat message (e.g., text, image, file).
    ///   - date: The date and time when the message was sent.
    ///   - status: The delivery or read status of the message.
    public init(id: String, user: ChatUser?, types: [ChatMessageType], date: Date, status: MessageStatus) {
        // swiftlint:disable:next no_uuid
        self.id = UUID() // Replaced with `idString`
        self.idString = id
        self.user = user
        self.types = types
        self.date = date
        self.status = status
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
