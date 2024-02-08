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

struct TextMessageCell: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle

    let message: ChatMessage
    let text: String
    let position: MessageGroupPosition

    // MARK: - Init

    init(message: ChatMessage, text: String, position: MessageGroupPosition) {
        self.message = message
        self.text = text
        self.position = position
    }

    // MARK: - Builder

    var body: some View {
        HStack(spacing: 0) {
            if !message.user.isAgent {
                Spacer()
            }
            
            Text(text)
                .messageChatTextStyle(message, text: text, position: position)
            
            if message.user.isAgent {
                Spacer()
            }
        }
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
                    position: .first
                )
                TextMessageCell(
                    message: MockData.textMessage(user: MockData.agent),
                    text: Lorem.sentence(),
                    position: .first
                )
            }
            .previewDisplayName("Light Mode")
            
            VStack(spacing: 4) {
                TextMessageCell(
                    message: MockData.textMessage(user: MockData.customer),
                    text: Lorem.sentence(),
                    position: .first
                )

                TextMessageCell(
                    message: MockData.textMessage(user: MockData.agent),
                    text: Lorem.sentence(),
                    position: .first
                )
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .padding(.horizontal, 10)
        .environmentObject(ChatStyle())
    }
}
