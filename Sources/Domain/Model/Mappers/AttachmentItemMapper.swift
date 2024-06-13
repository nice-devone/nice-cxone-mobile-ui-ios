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

enum AttachmentItemMapper {
    
    static func map(_ item: AttachmentItem) -> ContentDescriptor {
        ContentDescriptor(url: item.url, mimeType: item.mimeType, fileName: item.fileName, friendlyName: item.friendlyName)
    }
    
    static func map(_ attachment: Attachment) -> AttachmentItem? {
        guard let url = URL(string: attachment.url) else {
            LogManager.error(.unableToParse("url", from: attachment.url))
            return nil
        }
        
        return AttachmentItem(url: url, friendlyName: attachment.friendlyName, mimeType: attachment.mimeType, fileName: attachment.fileName)
    }

    static func map(_ types: [ChatMessageType]) -> [AttachmentItem] {
        types.compactMap(Self.map)
    }
    
    static func map(_ type: ChatMessageType?) -> AttachmentItem? {
        switch type {
        case .image(let item):
            return item
        case .video(let item):
            return item
        case .audio(let item):
            return item
        default:
            return nil
        }
    }
}
