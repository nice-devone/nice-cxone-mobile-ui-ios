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

extension Message {

    func getLocalizedContentOrFallbackText(basedOn localization: ChatLocalization, useFallback: Bool = false) -> String? {
        switch self.contentType {
        case .text(let entity):
            if !attachments.isEmpty, entity.text.isEmpty {
                return useFallback ? String(format: localization.chatFallbackMessageAttachments, attachments.count) : nil
            } else {
                return entity.text
            }
        case .richLink(let entity):
            return entity.title.nilIfEmpty() ?? (useFallback ? localization.chatFallbackMessageTORMRichlink : nil)
        case .quickReplies(let entity):
            return entity.title.nilIfEmpty() ?? (useFallback ? localization.chatFallbackMessageTORMQuickReplies : nil)
        case .listPicker(let entity):
            return entity.title.nilIfEmpty() ?? (useFallback ? localization.chatFallbackMessageTORMListPicker : nil)
        case .unknown:
            return useFallback ? localization.chatFallbackMessageUnknown : nil
        }
    }
}
