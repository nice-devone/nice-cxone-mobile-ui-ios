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

import SwiftUI

struct TextMessageCell: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle

    let message: ChatMessage
    let text: AttributedString
    let position: MessageGroupPosition

    // MARK: - Init

    init(message: ChatMessage, text: String, position: MessageGroupPosition) {
        self.message = message
        self.text = text.attributed
        self.position = position
    }

    // MARK: - Builder

    var body: some View {
        HStack(spacing: 0) {
            if !message.user.isAgent {
                Spacer()
            }
            
            Text(text)
                .padding(.vertical, StyleGuide.Message.paddingVertical)
                .padding(.horizontal, StyleGuide.Message.paddingHorizontal)
                .messageChatStyle(message, position: position, text: text.description)
            
            if message.user.isAgent {
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
            Log.error(.failed("Unable to initialize DataDetector to highling link/phone number"))
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
                    Log.error(.failed("Unable to get the phone number"))
                    break
                }
                
                result[range].link = url
            case .link:
                guard let url = match.url else {
                    Log.error(.failed("Unable to get the URL"))
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

struct TextMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            VStack(spacing: 4) {
                TextMessageCell(
                    message: MockData.textMessage(user: MockData.customer),
                    text: Lorem.sentence(),
                    position: .single
                )
                
                TextMessageCell(
                    message: MockData.hyperlinkMessage(user: MockData.customer),
                    text: MockData.hyperlinkContent,
                    position: .single
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
            .previewDisplayName("Light Mode")
            
            VStack(spacing: 4) {
                TextMessageCell(
                    message: MockData.textMessage(user: MockData.customer),
                    text: Lorem.sentence(),
                    position: .single
                )

                TextMessageCell(
                    message: MockData.hyperlinkMessage(user: MockData.customer),
                    text: MockData.hyperlinkContent,
                    position: .single
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
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .padding(.horizontal, 10)
        .environmentObject(ChatStyle())
    }
}
