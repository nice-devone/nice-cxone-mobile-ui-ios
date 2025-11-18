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

import SwiftUI

struct TextMessageCell: View {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Padding {
            static let LargeEmojiVertical: CGFloat = 6
            static let largeEmojiHorizontal: CGFloat = 0
        }
    }
    
    // MARK: - Properties

    private let message: ChatMessage
    private let attributedText: AttributedString
    private let text: String
    private let position: MessageGroupPosition
    
    // MARK: - Init

    init(message: ChatMessage, text: String, position: MessageGroupPosition) {
        self.message = message
        self.text = text
        self.attributedText = text.attributed
        self.position = position
    }

    // MARK: - Builder

    var body: some View {
        HStack(spacing: 0) {
            let isLargeEmojiText = text.isLargeEmoji
            
            if !message.isUserAgent {
                Spacer()
            }
            
            Text(attributedText)
                .padding(.vertical, isLargeEmojiText ? Constants.Padding.LargeEmojiVertical : StyleGuide.Padding.Message.contentVertical)
                .padding(.horizontal, isLargeEmojiText ? Constants.Padding.largeEmojiHorizontal : StyleGuide.Padding.Message.contentHorizontal)
                .messageChatStyle(message, position: position, text: text)
            
            if message.isUserAgent {
                Spacer()
            }
        }
    }
}

// MARK: - Helpers

private extension String {
    
    var attributed: AttributedString {
        var result = AttributedString(self)
        
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType(arrayLiteral: .link, .phoneNumber).rawValue) else {
            LogManager.error(.failed("Unable to initialize DataDetector to highling link/phone number"))
            return result
        }
        
        let attributes = AttributeContainer([
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        
        for match in detector.matches(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) {
            guard let range = Range(match.range, in: result) else {
                continue
            }
            
            result[range].setAttributes(attributes)
            
            switch match.resultType {
            case .phoneNumber:
                guard let phoneNumber = match.phoneNumber, let url = URL(string: "tel://\(phoneNumber)") else {
                    LogManager.error(.failed("Unable to get the phone number"))
                    break
                }
                
                result[range].link = url
            case .link:
                guard let url = match.url else {
                    LogManager.error(.failed("Unable to get the URL"))
                    break
                }
                
                result[range].link = url
            default:
                break
            }
        }
        
        return result
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 2) {
        TextMessageCell(
            message: MockData.textMessage(user: MockData.customer),
            text: Lorem.sentence(),
            position: .first
        )

        TextMessageCell(
            message: MockData.hyperlinkMessage(user: MockData.customer),
            text: MockData.hyperlinkContent,
            position: .last
        )
        
        TextMessageCell(
            message: MockData.textMessage(user: MockData.agent),
            text: Lorem.sentence(),
            position: .single
        )
        
        TextMessageCell(
            message: MockData.phoneNumberMessage(user: MockData.customer),
            text: MockData.phoneNumberContent,
            position: .single
        )
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
}
