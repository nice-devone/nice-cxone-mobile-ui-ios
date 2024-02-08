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

import SwiftUI

enum MockData {
    
    // MARK: - Properties
    
    static var imageUrl: URL {
        URL(string: "https://picsum.photos/\(Int.random(in: 1...1000))/300/300").unsafelyUnwrapped
    }
    static var imageItem: AttachmentItem {
        AttachmentItem(url: imageUrl, friendlyName: "Photo", mimeType: imageUrl.mimeType, fileName: imageUrl.lastPathComponent)
    }
    
    static let selectableVideoAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .video(videoItem))
    static let selectableImageAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .image(imageItem))
    static let selectableAudioAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .audio(audioItem))

    static let audioUrl = URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/gettysburg10.wav").unsafelyUnwrapped
    static let audioItem = AttachmentItem(url: audioUrl, friendlyName: "Gettysburg", mimeType: audioUrl.mimeType, fileName: audioUrl.lastPathComponent)
    
    static let videoUrl = URL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4").unsafelyUnwrapped
    static let videoItem = AttachmentItem(url: videoUrl, friendlyName: "Big Buck Bunny", mimeType: videoUrl.mimeType, fileName: videoUrl.lastPathComponent)
    
    static let linkPreviewUrl = URL(string: "https://www.soundczech.cz/temp/lorem-ipsum.pdf").unsafelyUnwrapped
    static let linkPreviewItem = AttachmentItem(
        url: linkPreviewUrl,
        friendlyName: "Lorem Ipsum",
        mimeType: linkPreviewUrl.mimeType,
        fileName: linkPreviewUrl.lastPathComponent
    )
    
    static let customRichMessageVariables: [String: Any] = [
        "thumbnail": imageUrl,
        "url": videoUrl,
        "buttons": [
            [
                "id": "0edc9bf6-4922-4695-a6ad-1bdb248dd42f",
                "name": "Open"
            ]
        ],
        "size": [
            "ios": "big",
            "android": "middle"
        ]
    ]
    static let menuRichMessageElements: [RichMessageSubElementType] = [
        .text(Lorem.word(), isTitle: true),
        .text(Lorem.words(), isTitle: false),
        .file(imageUrl),
        .button(RichMessageButton(title: Lorem.words(nbWords: 2)))
    ]
    static let galleryRichMessageElements: [ChatRichMessageType] = [
        .menu(menuRichMessageElements),
        .satisfactionSurvey(satisfactionSurveyItem),
        .custom(customItem),
        .richLink(richLinkItem),
        .listPicker(listPickerItem),
        .quickReplies(quickRepliesItem)
    ]
    static let listPickerItem = ListPickerItem(title: Lorem.word(), message: Lorem.sentence(), elements: richMessageOptions())
    static let quickRepliesItem = QuickRepliesItem(title: Lorem.word(), message: Lorem.sentence(), options: quickReplyOptions())
    static let richLinkItem = RichLinkItem(title: Lorem.words(), url: videoUrl, imageUrl: imageUrl)
    static let satisfactionSurveyItem = SatisfactionSurveyItem(title: Lorem.words(), message: Lorem.sentence(), buttonTitle: Lorem.word(), url: imageUrl)
    static let customItem = CustomPluginMessageItem(title: Lorem.words(), variables: customRichMessageVariables)
    
    static let customer = ChatUser(id: UUID().uuidString, userName: "Peter Parker", avatarURL: nil, isAgent: false)
    static let agent = ChatUser(id: UUID().uuidString, userName: "John Doe", avatarURL: imageUrl, isAgent: true)
    
    // MARK: - Methods
    
    static func textMessage(user: ChatUser? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(Lorem.sentence())],
            date: date,
            status: .seen
        )
    }
    
    static func emojiMessage(count: Int = .zero, user: ChatUser? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(randomEmoji(count: count).joined())],
            date: date,
            status: .seen
        )
    }
    
    static func imageMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .image(imageItem) },
            date: date,
            status: .seen
        )
    }
    
    static func videoMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .video(videoItem) },
            date: date,
            status: .seen
        )
    }
    
    static func audioMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .audio(audioItem) },
            date: date,
            status: .seen
        )
    }
    
    static func linkPreviewMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .linkPreview(linkPreviewItem) },
            date: date,
            status: .seen
        )
    }
    
    static func multiAttachmentsMessage(user: ChatUser? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [
                .image(imageItem),
                .video(videoItem),
                .image(imageItem),
                .audio(audioItem),
                .image(imageItem)
            ],
            date: date,
            status: .seen
        )
    }
    
    static func quickRepliesMessage(date: Date = Date()) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.quickReplies(quickRepliesItem))], date: date, status: .seen)
    }
    
    static func listPickerMessage(date: Date = Date()) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.listPicker(listPickerItem))], date: date, status: .seen)
    }
    
    static func richLinkMessage(date: Date = Date()) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.richLink(richLinkItem))], date: date, status: .seen)
    }
    
    static func galleryMessage(date: Date = Date()) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.gallery(galleryRichMessageElements))], date: date, status: .seen)
    }
    
    static func menuMessage(date: Date = Date()) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.menu(menuRichMessageElements))], date: date, status: .sent)
    }
    
    static func satisfactionSurveyMessage(date: Date = Date()) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.satisfactionSurvey(satisfactionSurveyItem))], date: date, status: .seen)
    }
    
    static func customMessage(date: Date = Date()) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.custom(customItem))], date: date, status: .seen)
    }
    
    static var chatHistory: [ChatMessage] = [
        textMessage(user: customer, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 30)),
        textMessage(user: customer, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 34)),
        textMessage(user: customer, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 34, second: 1)),
        textMessage(user: customer, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 39)),
        textMessage(user: customer, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 39, second: 1)),
        textMessage(user: customer, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 39, second: 2)),
        textMessage(user: agent, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 40)),
        textMessage(user: agent, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 40, second: 1)),
        textMessage(user: customer, date: Date.from(year: 2023, month: 1, day: 24, hour: 12, minute: 41)),
        textMessage(user: customer, date: Date().adding(.day, value: -1).adding(.hour, value: -1).adding(.minute, value: -2)),
        textMessage(user: agent, date: Date().adding(.day, value: -1).adding(.hour, value: -1)),
        textMessage(user: customer, date: Date().adding(.minute, value: -2)),
        textMessage(user: agent, date: Date())
    ]
}

// MARK: - Helpers

extension MockData {
    
    static func randomEmoji(count: Int) -> [String] {
        var result = [String]()
        
        for _ in 0..<(count == .zero ? Int.random(in: 1...5) : count) {
            let range = [UInt32](0x1F601...0x1F64F)
            let ascii = range[Int.random(in: 0..<range.count)]
            
            if let emoji = UnicodeScalar(ascii)?.description {
                result.append(String(emoji))
            } else {
                result.append("❓")
            }
        }
        
        return result
    }
    
    static func quickReplyOptions() -> [RichMessageButton] {
        (0..<Int.random(in: 2...5))
            .map { _ -> RichMessageButton in
                RichMessageButton(title: Lorem.words(nbWords: Int.random(in: 1..<3)), iconUrl: imageUrl)
            }
    }
    
    static func richMessageOptions() -> [RichMessageSubElementType] {
        (0..<Int.random(in: 2...5))
            .map { _ -> RichMessageSubElementType in
                .button(RichMessageButton(title: Lorem.words(nbWords: Int.random(in: 1..<3)), iconUrl: imageUrl))
            }
    }
}
