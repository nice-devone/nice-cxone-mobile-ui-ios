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

import Foundation

/// Extension for NotificationCenter to handle thread deeplink notifications.
public extension NotificationCenter {
    
    // MARK: - Properties

    /// Used for internal app navigation when handling thread deeplinks.
    static let threadDeeplinkNotificationName = "NavigateDirectlyToThreadNotification"
    // MARK: - Methods
    
    /// Posts a notification to navigate directly to a thread.
    ///
    /// - Parameter threadId: The unique identifier of the thread to navigate to.
    func postThreadDeeplinkNotification(threadId: String) {
        post(
            name: Notification.Name(Self.threadDeeplinkNotificationName),
            object: nil,
            userInfo: ["threadId": threadId]
        )
    }
}

extension NotificationCenter {

    func threadDeeplinkObserver(_ action: @escaping (Notification) -> Void) -> NSObjectProtocol {
        addObserver(
            forName: Notification.Name(Self.threadDeeplinkNotificationName),
            object: nil,
            queue: .main,
            using: action
        )
    }
}
