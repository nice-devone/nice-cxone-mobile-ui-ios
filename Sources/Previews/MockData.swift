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
        AttachmentItem(url: imageUrl, friendlyName: "photo_300/300", mimeType: imageUrl.mimeType, fileName: "\(imageUrl.lastPathComponent).jpg")
    }
    
    static let selectableVideoAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .video(videoItem))
    static let selectableImageAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .image(imageItem))
    static let selectableAudioAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .audio(audioItem))
    static let selectableDocumentAttachment = SelectableAttachment(id: UUID(), isSelected: false, messageType: .documentPreview(docPreviewItem))

    static let audioUrl = URL(string: "https://file-examples.com/storage/fe11f9541a67d9f2f9b2038/2017/11/file_example_MP3_700KB.mp3").unsafelyUnwrapped
    static let audioItem = AttachmentItem(
        url: audioUrl,
        friendlyName: "file_example_MP3_700KB",
        mimeType: audioUrl.mimeType,
        fileName: audioUrl.lastPathComponent
    )
    
    static let videoUrl = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4").unsafelyUnwrapped
    static let videoItem = AttachmentItem(url: videoUrl, friendlyName: "Big Buck Bunny", mimeType: videoUrl.mimeType, fileName: videoUrl.lastPathComponent)
    
    static let pdfPreviewUrl = URL(string: "https://www.soundczech.cz/temp/lorem-ipsum.pdf").unsafelyUnwrapped
    static let pdfPreviewItem = AttachmentItem(
        url: pdfPreviewUrl,
        friendlyName: "sample PDF",
        mimeType: pdfPreviewUrl.mimeType,
        fileName: pdfPreviewUrl.lastPathComponent
    )
    static let docPreviewURL = URL(string: "https://file-examples.com/wp-content/storage/2017/02/file-sample_100kB.doc").unsafelyUnwrapped
    static let docPreviewItem = AttachmentItem(
        url: docPreviewURL, 
        friendlyName: "sample DOC",
        mimeType: docPreviewURL.mimeType,
        fileName: docPreviewURL.lastPathComponent
    )
    static let xlsPreviewURL = URL(string: "https://file-examples.com/wp-content/storage/2017/02/file_example_XLS_10.xls").unsafelyUnwrapped
    static let xlsPreviewItem = AttachmentItem(
        url: xlsPreviewURL,
        friendlyName: "sample XLS",
        mimeType: xlsPreviewURL.mimeType,
        fileName: xlsPreviewURL.lastPathComponent
    )
    static let pptPreviewURL = URL(string: "https://file-examples.com/wp-content/storage/2017/08/file_example_PPT_250kB.ppt").unsafelyUnwrapped
    static let pptPreviewItem = AttachmentItem(
        url: pptPreviewURL,
        friendlyName: "sample PPT",
        mimeType: pptPreviewURL.mimeType,
        fileName: pptPreviewURL.lastPathComponent
    )
    static let listPickerItem = ListPickerItem(title: Lorem.word(), message: Lorem.sentence(), buttons: richMessageOptions())
    static let quickRepliesItem = QuickRepliesItem(title: Lorem.sentence(), message: Lorem.sentence(), options: quickReplyOptions())
    static let richLinkItem = RichLinkItem(title: Lorem.words(), url: videoUrl, imageUrl: imageUrl)
    
    static let customer = ChatUser(id: UUID().uuidString, userName: "Peter Parker", avatarURL: nil, isAgent: false)
    static let agent = ChatUser(id: UUID().uuidString, userName: "John Doe", avatarURL: imageUrl, isAgent: true)
    
    static let attachmentResrictions = AttachmentRestrictions(
        allowedFileSize: 40,
        allowedTypes: ["image/*", "video/*", "audio/*"],
        areAttachmentsEnabled: true
    )
    
    // MARK: - Methods
    
    static func textMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(Lorem.sentence())],
            date: date,
            status: status
        )
    }
    
    static func hyperlinkMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(hyperlinkContent)],
            date: date,
            status: status
        )
    }
    
    static func phoneNumberMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(phoneNumberContent)],
            date: date,
            status: status
        )
    }
    
    static func emojiMessage(count: Int = .zero, user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(randomEmoji(count: count).joined())],
            date: date,
            status: status
        )
    }
    
    static func imageMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .image(imageItem) },
            date: date,
            status: status
        )
    }
    
    static func imageMessageWithText(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        var content: [ChatMessageType] = [.text(Lorem.sentence())]
        content.append(contentsOf: (1...(elementsCount ?? 1)).map { _ in .image(imageItem) })
        
        return ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: content,
            date: date,
            status: status
        )
    }
    
    static func videoMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .video(videoItem) },
            date: date,
            status: status
        )
    }
    
    static func audioMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .audio(audioItem) },
            date: date,
            status: status
        )
    }
    
    static func multipleMediaAttachmentsMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [
                .text(Lorem.sentence()),
                .image(imageItem),
                .documentPreview(pdfPreviewItem),
                .image(imageItem),
                .audio(audioItem),
                .image(imageItem)
            ],
            date: date,
            status: status
        )
    }
    
    static func multipleDocumentAttachmentsMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [
                .text(Lorem.sentence()),
                .documentPreview(pdfPreviewItem),
                .documentPreview(docPreviewItem),
                .documentPreview(pptPreviewItem),
                .documentPreview(xlsPreviewItem),
                .documentPreview(docPreviewItem)
            ],
            date: date,
            status: status
        )
    }
    
    static func quickRepliesMessage(date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.quickReplies(quickRepliesItem))], date: date, status: status)
    }
    
    static func listPickerMessage(date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.listPicker(listPickerItem))], date: date, status: status)
    }
    
    static func richLinkMessage(date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(id: UUID(), user: agent, types: [.richContent(.richLink(richLinkItem))], date: date, status: status)
    }

    static func textFieldEntity() -> TextFieldEntity {
        TextFieldEntity(label: "First Name", isRequired: true, ident: "firstName", isEmail: false)
    }

    static func listFieldEntity() -> ListFieldEntity {
        ListFieldEntity(label: "Color", isRequired: false, ident: "color", options: ["blue": "Blue", "yellow": "Yellow"])
    }

    static func treeFieldEntity() -> TreeFieldEntity {
        TreeFieldEntity(
            label: "Devices",
            isRequired: true,
            ident: "devices",
            children: treeNodeFieldEntityChildren(),
            value: "iphone_14"
        )
    }
    
    static func treeNodeFieldEntityChildren() -> [TreeNodeFieldEntity] {
        [
            TreeNodeFieldEntity(label: "Mobile Phone", value: "phone", children: [
                TreeNodeFieldEntity(label: "Apple", value: "apple", children: [
                    TreeNodeFieldEntity(label: "iPhone 14", value: "iphone_14"),
                    TreeNodeFieldEntity(label: "iPhone 14 Pro", value: "iphone_14_pro"),
                    TreeNodeFieldEntity(label: "iPhone 15", value: "iphone_15"),
                    TreeNodeFieldEntity(label: "iPhone 15 Pro", value: "iphone_15_pro")
                ]),
                TreeNodeFieldEntity(label: "Android", value: "android", children: [
                    TreeNodeFieldEntity(label: "Samsung", value: "samsung", children: [
                        TreeNodeFieldEntity(label: "Galaxy A5", value: "samsung_galaxy_a5"),
                        TreeNodeFieldEntity(label: "Galaxy A51", value: "samsung_galaxy_a51"),
                        TreeNodeFieldEntity(label: "Galaxy S5", value: "samsung_galaxy_s5")
                    ]),
                    TreeNodeFieldEntity(label: "Xiaomi", value: "xiaomi", children: [
                        TreeNodeFieldEntity(label: "mi 5", value: "xiaomi_mi_5"),
                        TreeNodeFieldEntity(label: "mi 6", value: "xiaomi_mi_6"),
                        TreeNodeFieldEntity(label: "mi 7", value: "xiaomi_mi_7")
                    ])
                ])
            ]),
            TreeNodeFieldEntity(label: "Laptop", value: "laptop", children: [
                TreeNodeFieldEntity(label: "Windows", value: "windows", children: [
                    TreeNodeFieldEntity(label: "Acer", value: "acer", children: [
                        TreeNodeFieldEntity(label: "Aspire E5", value: "acer_aspire_e5"),
                        TreeNodeFieldEntity(label: "Aspire E5 Pro", value: "acer_aspire_e5_pro")
                    ]),
                    TreeNodeFieldEntity(label: "Asus", value: "asus", children: [
                        TreeNodeFieldEntity(label: "ZenBook", value: "zenbook"),
                        TreeNodeFieldEntity(label: "ZenBook Pro", value: "zenbook_pro")
                    ])
                ]),
                TreeNodeFieldEntity(label: "MacOS", value: "macos", children: [
                    TreeNodeFieldEntity(label: "MacBook", value: "macbook"),
                    TreeNodeFieldEntity(label: "MacBook Air", value: "macbook_air"),
                    TreeNodeFieldEntity(label: "MacBook Pro", value: "macbook_pro")
                ])
            ]),
            TreeNodeFieldEntity(label: "Other", value: "other")
        ]
    }
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
                RichMessageButton(title: Lorem.words(nbWords: Int.random(in: 1..<3)), iconUrl: nil)
            }
    }
    
    static func richMessageOptions() -> [RichMessageButton] {
        (0..<Int.random(in: 2...5))
            .map { _ -> RichMessageButton in
                RichMessageButton(
                    title: Lorem.words(nbWords: Int.random(in: 1..<3)),
                    description: Bool.random() ? Lorem.sentence() : nil,
                    iconUrl: Bool.random() ? imageUrl : nil
                )
            }
    }
}
