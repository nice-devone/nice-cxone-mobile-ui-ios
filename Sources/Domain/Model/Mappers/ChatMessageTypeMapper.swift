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

enum ChatMessageTypeMapper {
    
    static func map(_ entity: Message, localization: ChatLocalization) -> [ChatMessageType] {
        let message = entity.getLocalizedContentOrFallbackText(basedOn: localization, useFallback: false)
        
        if !entity.attachments.isEmpty {
            var result = [ChatMessageType]()
            
            if let message, !message.isEmpty {
                result.append(.text(message))
            }
            
            result.append(contentsOf: Attachment.map(entity.attachments))
            
            return result
        } else if let richMessage = handleRichMessage(entity, textMessage: message) {
            return [richMessage]
        } else {
            return []
        }
    }
}

// MARK: - Helpers

private extension Attachment {

    static func map(_ attachments: [Attachment]) -> [ChatMessageType] {
        attachments.compactMap { attachment -> ChatMessageType? in
            guard let attachmentItem = AttachmentItemMapper.map(attachment) else {
                LogManager.error(.unableToParse("attachmentItem"))
                return nil
            }

            switch attachment.mimeType {
            case _ where attachment.mimeType.contains("image"):
                return .image(attachmentItem)
            case _ where attachment.mimeType.contains("video"):
                return .video(attachmentItem)
            case _ where attachment.mimeType.contains("audio"):
                return .audio(attachmentItem)
            default:
                return .documentPreview(attachmentItem)
            }
        }
    }
}

private extension ChatMessageTypeMapper {

    static func handleRichMessage(_ entity: Message, textMessage: String?) -> ChatMessageType? {
        switch entity.contentType {
        case .richLink(let content):
            return .richContent(.richLink(RichLinkItem(title: content.title, url: content.url, imageUrl: content.fileUrl)))
        case .quickReplies(let content):
            let options = content.buttons.map { button in
                RichMessageButton(title: button.text, description: button.description, iconUrl: button.iconUrl, url: nil, postback: button.postback)
            }
            
            return .richContent(.quickReplies(QuickRepliesItem(title: content.title, message: nil, options: options)))
        case .listPicker(let content):
            let richMessageButtons = content.buttons.map { type -> RichMessageButton in
                switch type {
                case .replyButton(let button):
                    return RichMessageButton(title: button.text, description: button.description, iconUrl: button.iconUrl, url: nil, postback: button.postback)
                }
            }
            
            return .richContent(.listPicker(ListPickerItem(title: content.title, message: content.text, buttons: richMessageButtons)))
        default:
            return textMessage.map(ChatMessageType.text)
        }
    }
}
