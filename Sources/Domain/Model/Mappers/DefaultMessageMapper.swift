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

enum ChatMessageMapper {
    
    static func map(_ message: Message, localization: ChatLocalization) -> ChatMessage {
        ChatMessage(
            id: message.id,
            user: message.getUser(localization: localization),
            types: ChatMessageTypeMapper.map(message, localization: localization),
            date: message.createdAt,
            status: message.status
        )
    }
}

// MARK: - Helpers

private extension Message {

    func getUser(localization: ChatLocalization) -> ChatUser {
        if self.direction == .toClient {
            return ChatUser(
                id: authorUser.map { String($0.id) } ?? UUID().uuidString,
                userName: authorUser.map(\.fullName) ?? localization.commonUnknownAgent,
                avatarURL: authorUser.map { URL(string: $0.imageUrl) } ?? nil,
                isAgent: true
            )
        } else {
            return ChatUser(
                id: authorEndUserIdentity?.id ?? UUID().uuidString,
                userName: authorEndUserIdentity?.fullName ?? "Unknown Customer",
                avatarURL: nil,
                isAgent: false
            )
        }
    }
}
