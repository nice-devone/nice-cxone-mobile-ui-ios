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

import SwiftUI

class ChatManager {

    // MARK: - Properties

    let messages: [ChatMessage]

    private static let groupInterval: TimeInterval = 120
    
    // MARK: - Init

    init(messages: [ChatMessage]) {
        self.messages = messages
    }

    // MARK: - Methods

    func groupMessages() -> [MessageGroup] {
        messages
            .group { last, current in
                !current.richContentMessages
                    && !last.richContentMessages
                    && current.user.id == last.user.id
                    && abs(last.date.timeIntervalSince(current.date)) <= Self.groupInterval
            }
            .compactMap(MessageGroup.init)
    }
}

// MARK: - Helpers

extension ChatMessage {

    var isMultiAttachment: Bool {
        types.count > 1
    }
}
