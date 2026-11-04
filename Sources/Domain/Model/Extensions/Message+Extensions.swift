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

extension Message {

    /// Whether the customer has already seen this message.
    var isSeenByCustomer: Bool {
        customerStatistics?.seenAt != nil
    }

    @MainActor
    func getLocalizedContentOrFallbackText(useFallback: Bool = false) -> String? {
        switch self.contentType {
        case .text(let entity):
            if !attachments.isEmpty, entity.text.isEmpty {
                return useFallback ? L10n.Chat.FallbackMessage.attachments(attachments.count) : nil
            } else {
                return entity.text
            }
        case .richLink(let entity):
            return entity.title.nilIfEmpty() ?? (useFallback ? L10n.Chat.FallbackMessage.Torm.richLink : nil)
        case .quickReplies(let entity):
            return entity.title.nilIfEmpty() ?? (useFallback ? L10n.Chat.FallbackMessage.Torm.quickReplies : nil)
        case .listPicker(let entity):
            return entity.title.nilIfEmpty() ?? (useFallback ? L10n.Chat.FallbackMessage.Torm.listPicker : nil)
        case .timePicker(let entity):
            return entity.title.nilIfEmpty() ?? (useFallback ? L10n.Chat.FallbackMessage.Torm.timePicker : nil)
        case .unknown(let fallbackText):
            return fallbackText?.nilIfEmpty() ?? (useFallback ? L10n.Chat.FallbackMessage.unknown : nil)
        }
    }
}
