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

enum ChatUserMapper {
    
    static func map(from agent: Agent?) -> ChatUser? {
        guard let agent else {
            return nil
        }
        
        return ChatUser(
            id: String(agent.id),
            userName: agent.displayName,
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

extension Agent {

    /// The agent's name to show in the UI: the nickname when set, otherwise the full name.
    /// A whitespace-only nickname counts as not set, matching how the full name treats whitespace-only names.
    ///
    /// `nil` when neither is available (e.g. hidden personal information); callers add their own fallback.
    var displayName: String? {
        nickname?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty() ?? fullName
    }

    /// The agent's profile photo URL, excluding the backend's generic default-avatar placeholder.
    ///
    /// Returns `nil` when the image is missing, empty, or the default `/img/user*.png` placeholder,
    /// so the UI can fall back to initials or the generic agent icon.
    var nonDefaultAvatarImageUrl: URL? {
        guard let imageUrl, imageUrl.range(of: "/img/user.*\\.png", options: .regularExpression) == nil else {
            return nil
        }
        
        return URL(string: imageUrl)
    }
}
