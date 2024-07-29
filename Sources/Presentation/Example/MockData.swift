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
import SwiftUI

enum MockData {
    
    // MARK: - Properties
    
    static var hyperlinkContent: String {
        Lorem.words(nbWords: Int.random(in: 0..<5)) + " \(imageUrl.absoluteString) " + Lorem.words(nbWords: Int.random(in: 0..<5))
    }
    static var phoneNumberContent: String {
        Lorem.words(nbWords: Int.random(in: 0..<5)) + " (123) 456-7890 " + Lorem.words(nbWords: Int.random(in: 0..<5))
    }
    static var imageUrl: URL {
        URL(string: "https://picsum.photos/id/\(Int.random(in: 1...700))/300/300").unsafelyUnwrapped
    }
    static var imageItem: AttachmentItem {
        AttachmentItem(url: imageUrl, friendlyName: "Photo", mimeType: imageUrl.mimeType, fileName: imageUrl.lastPathComponent)
    }
    
    static let selectableVideoAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .video(videoItem))
    static let selectableImageAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .image(imageItem))
    static let selectableAudioAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .audio(audioItem))

    static let audioUrl = URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/gettysburg10.wav").unsafelyUnwrapped
    static let audioItem = AttachmentItem(url: audioUrl, friendlyName: "Gettysburg", mimeType: audioUrl.mimeType, fileName: audioUrl.lastPathComponent)
    
    static let videoUrl = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4").unsafelyUnwrapped
    static let videoItem = AttachmentItem(url: videoUrl, friendlyName: "Big Buck Bunny", mimeType: videoUrl.mimeType, fileName: videoUrl.lastPathComponent)
    
    static let linkPreviewUrl = URL(string: "https://www.soundczech.cz/temp/lorem-ipsum.pdf").unsafelyUnwrapped
    static let linkPreviewItem = AttachmentItem(
        url: linkPreviewUrl,
        friendlyName: "Lorem Ipsum",
        mimeType: linkPreviewUrl.mimeType,
        fileName: linkPreviewUrl.lastPathComponent
    )
    static let listPickerItem = ListPickerItem(title: Lorem.word(), message: Lorem.sentence(), buttons: richMessageOptions())
    static let quickRepliesItem = QuickRepliesItem(title: Lorem.word(), message: Lorem.sentence(), options: quickReplyOptions())
    static let richLinkItem = RichLinkItem(title: Lorem.words(), url: videoUrl, imageUrl: imageUrl)
    
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
    
    static func hyperlinkMessage(user: ChatUser? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(hyperlinkContent)],
            date: date,
            status: .seen
        )
    }
    
    static func phoneNumberMessage(user: ChatUser? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(phoneNumberContent)],
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
    
    static func imageMessageWithText(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date()) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(Lorem.sentence()), .image(imageItem)],
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
