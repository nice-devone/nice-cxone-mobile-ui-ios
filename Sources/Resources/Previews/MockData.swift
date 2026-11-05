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
import SwiftUI

// swiftlint:disable:next type_body_length
enum MockData {
    
    // MARK: - Properties

    /// 2025-01-15 10:30:00 UTC — stable date for deterministic snapshot tests.
    static let fixedDate = Date(timeIntervalSince1970: 1_736_936_200)

    static var unsupportedMessageContent: String {
        Lorem.sentence() + "\nPLUGIN – SATISFACTION_SURVEY"
    }
    static var hyperlinkContent: String {
        Lorem.words(nbWords: Int.random(in: 0..<5)) + " \(imageUrl().absoluteString) " + Lorem.words(nbWords: Int.random(in: 0..<5))
    }
    static var phoneNumberContent: String {
        Lorem.words(nbWords: Int.random(in: 0..<5)) + " (123) 456-7890 " + Lorem.words(nbWords: Int.random(in: 0..<5))
    }
    
    static let selectableVideoAttachment = SelectableAttachment(
        id: LowercaseUUID().uuidString,
        isSelected: false,
        messageType: .video(videoItem)
    )
    static let selectableImageAttachment = SelectableAttachment(
        id: LowercaseUUID().uuidString,
        isSelected: false,
        messageType: .image(imageItem())
    )
    static let selectableDocumentAttachment = SelectableAttachment(
        id: LowercaseUUID().uuidString,
        isSelected: false,
        messageType: .documentPreview(docPreviewItem)
    )
    static let selectablePDFAttachment = SelectableAttachment(
        id: LowercaseUUID().uuidString,
        isSelected: false,
        messageType: .documentPreview(pdfPreviewItem)
    )

    // The previous file-examples.com fixture is served from a hashed storage path that has since
    // been rotated — it now returns 404, which left every audio preview stuck at "00:00".
    static let audioUrl = URL(string: "https://download.samplelib.com/mp3/sample-15s.mp3").unsafelyUnwrapped
    static let audioItem = AttachmentItem(
        url: audioUrl,
        friendlyName: "sample-15s",
        mimeType: audioUrl.mimeType,
        fileName: audioUrl.lastPathComponent
    )

    // 360p / 30fps H.264: small and, crucially, decodable by the iOS Simulator's
    // video decoder (the 720p 60fps source previously used here failed with
    // AVFoundation -11821 "Cannot Decode" in the Simulator / Preview canvas).
    static let videoUrl = URL(
        string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4"
    ).unsafelyUnwrapped
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
    static let timePickerItem = TimePickerItem(
        title: Lorem.words(),
        sheetTitle: Lorem.words(),
        timeSlots: timeSlotOptions()
    )
    static let customer = ChatUser(
        id: LowercaseUUID().uuidString,
        userName: "Peter Parker",
        avatarURL: nil,
        isAgent: false
    )
    static let agent = ChatUser(
        id: LowercaseUUID().uuidString,
        userName: "John Doe",
        avatarURL: nil,
        isAgent: true
    )
    static let attachmentRestrictions = AttachmentRestrictions(
        allowedFileSize: 40,
        allowedTypes: ["image/*", "video/*", "audio/*"],
        areAttachmentsEnabled: true
    )
    // periphery:ignore - used only by the test target, which Periphery does not index
    static let attachmentRestrictionsNoVoice = AttachmentRestrictions(
        allowedFileSize: 40,
        allowedTypes: ["image/*", "video/*"],
        areAttachmentsEnabled: true
    )

    // MARK: - Methods

    static func imageUrl(imageIndex: Int? = nil) -> URL {
        URL(string: "https://picsum.photos/id/\(imageIndex ?? Int.random(in: 1...700))/300/300").unsafelyUnwrapped
    }

    static func imageItem(imageIndex: Int? = nil) -> AttachmentItem {
        let imageUrl = imageUrl(imageIndex: imageIndex)
        
        return AttachmentItem(
            url: imageUrl,
            friendlyName: "\(imageUrl.lastPathComponent).jpg",
            mimeType: "image/jpg",
            fileName: "\(imageUrl.lastPathComponent).jpg"
        )
    }

    static func listPickerItem(
        title: String = Lorem.word(),
        message: String? = Lorem.sentence(),
        buttons: [RichMessageButton] = richMessageOptions()
    ) -> ListPickerItem {
        ListPickerItem(
            title: title,
            message: message,
            buttons: buttons
        )
    }
    static func quickRepliesItem(
        title: String = Lorem.sentence(),
        message: String? = Lorem.sentence(),
        options: [RichMessageButton] = quickReplyOptions()
    ) -> QuickRepliesItem {
        QuickRepliesItem(
            title: title,
            message: message,
            options: options
        )
    }
    static func richLinkItem(
        title: String = Lorem.words(),
        url richLinkUrl: URL = Self.imageUrl(),
        imageUrl: URL = Self.imageUrl()
    ) -> RichLinkItem {
        RichLinkItem(
            title: title,
            url: richLinkUrl,
            imageUrl: imageUrl
        )
    }

    static func textMessage(user: ChatUser? = nil, text: String = Lorem.sentence(), date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(text)],
            date: date,
            status: status
        )
    }
    
    static func hyperlinkMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(hyperlinkContent)],
            date: date,
            status: status
        )
    }
    
    static func phoneNumberMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(phoneNumberContent)],
            date: date,
            status: status
        )
    }
    
    static func emojiMessage(count: Int = .zero, user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: [.text(randomEmoji(count: count).joined())],
            date: date,
            status: status
        )
    }
    
    static func imageMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .image(imageItem()) },
            date: date,
            status: status
        )
    }
    
    static func imageMessageWithText(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        var content: [ChatMessageType] = [.text(Lorem.sentence())]
        content.append(contentsOf: (1...(elementsCount ?? 1)).map { _ in .image(imageItem()) })
        
        return ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: content,
            date: date,
            status: status
        )
    }
    
    static func videoMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .video(videoItem) },
            date: date,
            status: status
        )
    }
    
    static func audioMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .audio(audioItem) },
            date: date,
            status: status
        )
    }
    
    static func documentMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in
                [
                    .documentPreview(docPreviewItem),
                    .documentPreview(xlsPreviewItem),
                    .documentPreview(pptPreviewItem)
                ].random().unsafelyUnwrapped
            },
            date: date,
            status: status
        )
    }
    
    static func pdfMessage(user: ChatUser? = nil, elementsCount: Int? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: (1...(elementsCount ?? 1)).map { _ in .documentPreview(pdfPreviewItem) },
            date: date,
            status: status
        )
    }
    
    static func multipleMediaAttachmentsMessage(
            user: ChatUser? = nil,
            date: Date = Date(),
            status: MessageStatus = .seen,
            messages: [ChatMessageType]? = nil
        ) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: messages ?? [
                .text(Lorem.sentence()),
                .image(imageItem()),
                .audio(audioItem),
                .video(videoItem),
                .image(imageItem())
            ],
            date: date,
            status: status
        )
    }
    
    static func multipleDocumentAttachmentsMessage(
            user: ChatUser? = nil,
            date: Date = Date(),
            status: MessageStatus = .seen,
            messages: [ChatMessageType]? = nil
        ) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? [customer, agent].random().unsafelyUnwrapped,
            types: messages ?? [
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
    
    static func quickRepliesMessage(item: QuickRepliesItem? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(id: LowercaseUUID().uuidString, user: agent, types: [.richContent(.quickReplies(item ?? quickRepliesItem()))], date: date, status: status)
    }

    static func listPickerMessage(item: ListPickerItem? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(id: LowercaseUUID().uuidString, user: agent, types: [.richContent(.listPicker(item ?? listPickerItem()))], date: date, status: status)
    }

    static func richLinkMessage(item: RichLinkItem? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(id: LowercaseUUID().uuidString, user: agent, types: [.richContent(.richLink(item ?? richLinkItem()))], date: date, status: status)
    }

    static func timePickerMessage(item: TimePickerItem? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(id: LowercaseUUID().uuidString, user: agent, types: [.richContent(.timePicker(item ?? timePickerItem))], date: date, status: status)
    }

    // periphery:ignore - used only by the test target, which Periphery does not index
    static func multipleMediaMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? agent,
            types: [
                .image(imageItem()),
                .video(videoItem),
                .image(imageItem()),
                .video(videoItem)
            ],
            date: date,
            status: status
        )
    }

    // periphery:ignore - used only by the test target, which Periphery does not index
    static func multipleDocumentMessage(user: ChatUser? = nil, date: Date = Date(), status: MessageStatus = .seen) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: user ?? agent,
            types: [
                .documentPreview(docPreviewItem),
                .documentPreview(pdfPreviewItem),
                .documentPreview(pptPreviewItem)
            ],
            date: date,
            status: status
        )
    }

    @MainActor
    static func textFieldEntity(
        label: String = "First Name",
        ident: String = "firstName",
        isRequired: Bool = false,
        isEmail: Bool = false
    ) -> TextFieldEntity {
        TextFieldEntity(label: label, isRequired: isRequired, ident: ident, isEmail: isEmail)
    }

    @MainActor
    static func listFieldEntity(isRequired: Bool = false) -> ListFieldEntity {
        ListFieldEntity(label: "Color", isRequired: isRequired, ident: "color", options: ["blue": "Blue", "yellow": "Yellow"])
    }

    @MainActor
    static func treeFieldEntity(isRequired: Bool = false, value: String? = nil) -> TreeFieldEntity {
        TreeFieldEntity(
            label: "Devices",
            isRequired: isRequired,
            ident: "devices",
            children: treeNodeFieldEntityChildren(),
            value: value
        )
    }
    
    @MainActor
    static func treeNodeFieldEntityChildren() -> [TreeNodeFieldEntity] {
        [
            TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Mobile Phone", value: "phone", children: [
                TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Apple", value: "apple", children: [
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "iPhone 14", value: "iphone_14"),
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "iPhone 14 Pro", value: "iphone_14_pro"),
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "iPhone 15", value: "iphone_15"),
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "iPhone 15 Pro", value: "iphone_15_pro")
                ]),
                TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Android", value: "android", children: [
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Samsung", value: "samsung", children: [
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Galaxy A5", value: "samsung_galaxy_a5"),
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Galaxy A51", value: "samsung_galaxy_a51"),
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Galaxy S5", value: "samsung_galaxy_s5")
                    ]),
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Xiaomi", value: "xiaomi", children: [
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "mi 5", value: "xiaomi_mi_5"),
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "mi 6", value: "xiaomi_mi_6"),
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "mi 7", value: "xiaomi_mi_7")
                    ])
                ])
            ]),
            TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Laptop", value: "laptop", children: [
                TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Windows", value: "windows", children: [
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Acer", value: "acer", children: [
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Aspire E5", value: "acer_aspire_e5"),
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Aspire E5 Pro", value: "acer_aspire_e5_pro")
                    ]),
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Asus", value: "asus", children: [
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "ZenBook", value: "zenbook"),
                        TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "ZenBook Pro", value: "zenbook_pro")
                    ])
                ]),
                TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "MacOS", value: "macos", children: [
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "MacBook", value: "macbook"),
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "MacBook Air", value: "macbook_air"),
                    TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "MacBook Pro", value: "macbook_pro")
                ])
            ]),
            TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Other", value: "other")
        ]
    }
    
    // periphery:ignore - used only by the test target, which Periphery does not index
    static func chatMessage(
        id: String = "test-message-id",
        user: ChatUser? = nil,
        types: [ChatMessageType] = [.text("Test")],
        date: Date = Date(),
        status: MessageStatus = .seen
    ) -> ChatMessage {
        ChatMessage(id: id, user: user, types: types, date: date, status: status)
    }

    // periphery:ignore - used only by the test target, which Periphery does not index
    static func messageSequence(
        from user: ChatUser,
        count: Int,
        startDate: Date = Date(),
        interval: TimeInterval = 30
    ) -> [ChatMessage] {
        (0..<count).map { index in
            chatMessage(
                id: "msg-\(index)",
                user: user,
                date: startDate.addingTimeInterval(Double(index) * interval)
            )
        }
    }

    static func unsupportedMessage(
        text: String = Self.unsupportedMessageContent,
        date: Date = Date(),
        status: MessageStatus = .seen
    ) -> ChatMessage {
        ChatMessage(
            id: LowercaseUUID().uuidString,
            user: agent,
            types: [.unknown(text)],
            date: date,
            status: status
        )
    }
}
