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
import Foundation

enum ChatMessageTypeMapper {
    
    static func map(_ entity: Message) -> [ChatMessageType] {
        if !entity.attachments.isEmpty {
            var result = [ChatMessageType]()
            
            if !entity.message.isEmpty && !entity.message.contains(pattern: "\\d+\\sattachment\\(s\\)") {
                result.append(.text(entity.message))
            }
            
            result.append(contentsOf: Attachment.map(entity.attachments))
            
            return result
        } else {
            return [handleRichMessage(entity)]
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
                return .linkPreview(attachmentItem)
            }
        }
    }
}

private extension ChatMessageTypeMapper {

    static func handleRichMessage(_ entity: Message) -> ChatMessageType {
        switch entity.contentType {
        case .plugin(let content):
            return .richContent(mapPlugin(content.element))
        case .richLink(let content):
            return .richContent(.richLink(RichLinkItem(title: content.title, url: content.url, imageUrl: content.fileUrl)))
        case .quickReplies(let content):
            let options = content.buttons.map { button in
                RichMessageButton(title: button.text, iconUrl: button.iconUrl, url: nil, postback: button.postback)
            }
            
            return .richContent(.quickReplies(QuickRepliesItem(title: content.title, message: nil, options: options)))
        case .listPicker(let content):
            let options = content.elements.map { elementType -> RichMessageSubElementType in
                switch elementType {
                case .replyButton(let button):
                    return .button(RichMessageButton(title: button.text, iconUrl: button.iconUrl, url: nil, postback: button.postback))
                }
            }
            
            return .richContent(.listPicker(ListPickerItem(title: content.title, message: content.text, elements: options)))
        default:
            return .text(entity.message)
        }
    }
    
    static func mapPlugin(_ type: PluginMessageType) -> ChatRichMessageType {
        switch type {
        case .gallery(let content):
             return .gallery(content.map { Self.mapPlugin($0) })
        case .menu(let content):
            return .menu(content.elements.map(RichMessageSubElementType.init))
        case .textAndButtons(let content):
            return .listPicker(ListPickerItem(from: content.elements))
        case .quickReplies(let content):
            return .quickReplies(QuickRepliesItem(from: content.elements))
        case .satisfactionSurvey(let content):
            return .satisfactionSurvey(SatisfactionSurveyItem(from: content.elements))
        case .custom(let content):
            return .custom(CustomPluginMessageItem(title: content.text, variables: content.variables))
        case .subElements(let elements):
            return .menu(elements.map(RichMessageSubElementType.init))
        }
    }
}

private extension RichMessageSubElementType {
    
    init(from type: PluginMessageSubElementType) {
        switch type {
        case .text(let content):
            self = .text(content.text, isTitle: false)
        case .button(let content):
            self = .button(RichMessageButton(title: content.text, url: content.url, postback: content.postback))
        case .file(let content):
            self = .file(content.url)
        case .title(let content):
            self = .text(content.text, isTitle: true)
        }
    }
}

private extension QuickRepliesItem {
    
    init(from elements: [PluginMessageSubElementType]) {
        var title = ""
        var message: String?
        var options = [RichMessageButton]()
        
        elements.forEach { element in
            switch element {
            case .title(let content):
                title = content.text
            case .text(let content):
                message = content.text
            case .button(let content):
                options.append(RichMessageButton(title: content.text, iconUrl: nil, url: content.url, postback: content.postback))
            case .file:
                // Should not happen
                break
            }
        }
        
        self.init(title: title, message: message, options: options)
    }
}

private extension ListPickerItem {
    
    init(from elements: [PluginMessageSubElementType]) {
        var title = ""
        var message: String?
        var button: RichMessageSubElementType?
        
        elements.forEach { element in
            switch element {
            case .title(let content):
                title = content.text
            case .text(let content):
                message = content.text
            case .button(let content):
                button = .button(RichMessageButton(title: content.text, url: content.url, postback: content.postback))
            case .file:
                // Should not happen
                break
            }
        }
        
        self.init(title: title, message: message, elements: [button].compactMap { $0 })
    }
}

private extension SatisfactionSurveyItem {
    
    init(from elements: [PluginMessageSubElementType]) {
        var title: String?
        var message: String?
        var buttonTitle = ""
        var url: URL?
        
        elements.forEach { element in
            switch element {
            case .title(let content):
                title = content.text
            case .text(let content):
                message = content.text
            case .button(let content):
                buttonTitle = content.text
                url = content.url
            case .file:
                // Does not happen
                break
            }
        }
        
        self.init(title: title, message: message, buttonTitle: buttonTitle, url: url)
    }
}
