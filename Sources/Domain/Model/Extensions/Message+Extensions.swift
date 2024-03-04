//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

    var message: String {
        switch self.contentType {
        case .text(let entity):
            if !attachments.isEmpty {
                return "\(attachments.count) attachment(s)"
            } else {
                return entity.text
            }
        case .plugin(let plugin):
            switch plugin.element {
            case .gallery:
                return "Gallery plugin message"
            case .menu:
                return "Menu plugin message"
            case .textAndButtons:
                return "Text and buttons plugin message"
            case .quickReplies:
                return "Quick replies plugin message"
            case .satisfactionSurvey:
                return "Satisfaction survey plugin message"
            case .custom:
                return "Custom plugin message"
            case .subElements:
                return "Sub elements plugin message"
            }
        case .richLink(let entity):
            return entity.title.nilIfEmpty() ?? "Rich link TORM message"
        case .quickReplies(let entity):
            return entity.title.nilIfEmpty() ?? "Quick replies TORM message"
        case .listPicker(let entity):
            return entity.title.nilIfEmpty() ?? "List picker TORM message"
        case .unknown:
            return "Unknown message"
        }
    }
}
