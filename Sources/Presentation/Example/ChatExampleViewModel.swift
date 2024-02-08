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

class ChatExampleViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var messages = [ChatMessage]()
    @Published var isAgentTyping = false
    @Published var isUserTyping = false
    
    // MARK: - Methods
    
    func onAppear() {
        messages.append(contentsOf: [
//            MockData.textMessage(),
//            MockData.emojiMessage(),
//            MockData.quickRepliesMessage(),
//            MockData.imageMessage(),
//            MockData.videoMessage(),
//            MockData.audioMessage(),
//            MockData.linkPreviewMessage(),
//            MockData.listPickerMessage(),
//            MockData.richLinkMessage(),
//            MockData.customMessage(),
//            MockData.galleryMessage()
        ])
        
//        setupTimer()
    }
    
    func onNewMessage(messageType: ChatMessageType, attachments: [AttachmentItem]) {
        switch messageType {
        case .text(let text):
            if !text.isEmpty {
                messages.append(ChatMessage(id: UUID(), user: MockData.customer, types: [messageType], date: Date(), status: .seen))
            }
        default:
            messages.append(ChatMessage(id: UUID(), user: MockData.customer, types: [messageType], date: Date(), status: .seen))
        }
        
        if let messageItem = attachments.messageItem {
            messages.append(messageItem)
        }
    }
    
    func onPullToRefresh(refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messages.insert(MockData.textMessage(), at: 0)
            
            refreshControl.endRefreshing()
        }
    }
    
    func onRichMessageElementSelected(textToSend: String?, element: RichMessageSubElementType) {
        guard let textToSend else {
            return
        }
        
        messages.append(ChatMessage(id: UUID(), user: MockData.customer, types: [.text(textToSend)], date: Date(), status: .seen))
    }
    
    func onReset() {
        messages.removeAll()
    }
    
    func onAdd() {
        appendRandomMessage()
    }
}

// MARK: - Private methods

private extension ChatExampleViewModel {
    
    func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: .random(in: 1..<3), repeats: true) { [weak self] _ in
            self?.appendRandomMessage()
        }
    }
    
    func appendRandomMessage() {
        if messages.count > 20 {
            // Reset history
            self.messages.removeAll()
        }
        
        let randomNumber: Int = .random(in: 1..<100)
        
        switch randomNumber {
        case 60..<65:
            messages.append(MockData.audioMessage())
        case 65..<70:
            messages.append(MockData.emojiMessage())
        case 70..<75:
            messages.append(MockData.richLinkMessage())
        case 75..<80:
            messages.append(MockData.listPickerMessage())
        case 80..<85:
            messages.append(MockData.quickRepliesMessage())
        case 90..<95:
            messages.append(MockData.imageMessage())
        case 95..<100:
            messages.append(MockData.videoMessage())
        default:
            messages.append(MockData.textMessage())
        }
    }
}

// MARK: - AttachmentItem+Mapper

extension [AttachmentItem] {
    
    var messageItem: ChatMessage? {
        guard !isEmpty else {
            return nil
        }
        
        let types = compactMap { item -> ChatMessageType in
            switch item.mimeType {
            case _ where item.mimeType.contains("image"):
                return .image(item)
            case _ where item.mimeType.contains("video"):
                return .video(item)
            case _ where item.mimeType.contains("audio"):
                return .audio(item)
            default:
                return .linkPreview(item)
            }
        }
        
        return ChatMessage(id: UUID(), user: MockData.customer, types: types, date: Date(), status: .seen)
    }
}
