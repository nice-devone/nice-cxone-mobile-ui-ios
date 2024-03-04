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

import Combine
import Kingfisher
import SwiftUI

struct ImageMessageCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle

    @State var isSelected: Bool = false

    private let item: AttachmentItem
    private let isMultiAttachment: Bool
    private let message: ChatMessage

    // MARK: - Init
    
    init(message: ChatMessage, item: AttachmentItem, isMultiAttachment: Bool) {
        self.message = message
        self.item = item
        self.isMultiAttachment = isMultiAttachment
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: message.user.isAgent ? .bottomLeading : .bottomTrailing) {
            LoadingImageMessageCell(item: item, isMultiAttachment: isMultiAttachment)
                .if(!isMultiAttachment) { view in
                    view.shareable(message, attachments: [item], spacerLength: 0)
                }
        }
    }
}

// MARK: - Preview

struct ImageMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            VStack(spacing: 4) {
                ImageMessageCell(message: MockData.imageMessage(user: MockData.agent), item: MockData.imageItem, isMultiAttachment: false)
                ImageMessageCell(message: MockData.imageMessage(user: MockData.customer), item: MockData.imageItem, isMultiAttachment: false)
            }
            .previewDisplayName("Light Mode")
            
            VStack(spacing: 4) {
                ImageMessageCell(message: MockData.imageMessage(user: MockData.agent), item: MockData.imageItem, isMultiAttachment: false)
                ImageMessageCell(message: MockData.imageMessage(user: MockData.customer), item: MockData.imageItem, isMultiAttachment: false)
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .padding(.horizontal, 10)
        .environmentObject(ChatStyle())
    }
}
