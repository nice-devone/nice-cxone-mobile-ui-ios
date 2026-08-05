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

struct MessageGroup: Identifiable, Equatable {

    // MARK: Properties

    static let defaultGroupingInterval: TimeInterval = 120

    let id: String
    let messages: [ChatMessage]
    let shouldShowHeader: Bool
    let shouldShowFooter: Bool
    let status: MessageStatus

    // swiftlint:disable force_unwrapping
    var date: Date { messages.first!.date }
    var sender: ChatUser? { messages.first!.user }
    var shouldShowAvatar: Bool { sender?.isAgent == true }
    // swiftlint:enable force_unwrapping

    // MARK: - Initialization

    init?(messages: [ChatMessage], showHeader: Bool, showFooter: Bool) {
        guard !messages.isEmpty else {
            return nil
        }

        self.id = messages.lazy.map(\.id).joined(separator: ",")
        self.messages = messages
        self.shouldShowHeader = showHeader
        // swiftlint:disable:next force_unwrapping
        self.status = messages.last!.status
        self.shouldShowFooter = messages.first?.isUserAgent == false && (status == .seen || showFooter)
    }

    // MARK: - Methods

    func position(of message: ChatMessage) -> MessageGroupPosition {
        guard messages.count > 1 else {
            return .single
        }

        switch message {
        case messages.first:
            return .first
        case messages.last:
            return .last
        default:
            return .inside
        }
    }
}
