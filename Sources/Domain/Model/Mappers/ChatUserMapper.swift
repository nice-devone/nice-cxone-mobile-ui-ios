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

enum ChatUserMapper {
    
    static func map(from agent: Agent?) -> ChatUser? {
        guard let agent else {
            return nil
        }
        
        return ChatUser(
            id: String(agent.id),
            userName: agent.fullName,
            avatarURL: agent.nonDefaultAvatarImageUrl,
            isAgent: true
        )
    }
    
    static func map(from customer: CustomerIdentity?) -> ChatUser? {
        guard let customer else {
            return nil
        }
        
        return ChatUser(
            id: customer.id,
            userName: customer.fullName,
            avatarURL: nil,
            isAgent: false
        )
    }
}

// MARK: - Helpers

private extension Agent {
    
    var nonDefaultAvatarImageUrl: URL? {
        guard imageUrl.range(of: "/img/user.*\\.png", options: .regularExpression) == nil else {
            return nil
        }
        
        return URL(string: imageUrl)
    }
}
