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

struct MultipleAttachmentContainer: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @State private var showAttachmentsView = false

    static let cellDimension: CGFloat = 100
    
    let message: ChatMessage

    var filteredTypes = [ChatMessageType]()

    private let config = [
        GridItem(.fixed(Self.cellDimension), spacing: 4),
        GridItem(.fixed(Self.cellDimension), spacing: 0)
    ]
    
    // MARK: - Init
    
    init(_ message: ChatMessage) {
        self.message = message
        
        filteredTypes = message.types.filter {
            switch $0 {
            case .image, .video, .audio:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Builder
    
    var body: some View {
        HStack {
            LazyHGrid(rows: config) {
                ForEach(Array(filteredTypes.enumerated()), id: \.element) { index, messageType in
                    ZStack {
                        if index < 4 {
                            switch messageType {
                            case .image(let item):
                                ImageMessageCell(message: message, item: item, isMultiAttachment: true)
                                    .blur(radius: index == 3 && filteredTypes.count > 4 ? 1 : 0)
                            case .video(let item):
                                VideoMessageCell(message: message, item: item, isMultiAttachment: true)
                                    .blur(radius: index == 3 && filteredTypes.count > 4 ? 1 : 0)
                            case .audio(let item):
                                AudioMessageCell(message: message, item: item, isMultiAttachment: true)
                                    .blur(radius: index == 3 && filteredTypes.count > 4 ? 1 : 0)
                            default:
                                EmptyView()
                            }

                            if index == 3 && filteredTypes.count > 4 {
                                Color.black
                                    .opacity(0.33)
                                    .cornerRadius(14, corners: .allCorners)

                                Text("+\(filteredTypes.count - 4)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .onTapGesture {
                        showAttachmentsView.toggle()
                    }
                    .sheet(isPresented: $showAttachmentsView) {
                        AttachmentsView(message: message, messageTypes: filteredTypes)
                    }
                }
            }
        }
        .padding(4)
        .background(message.user.isAgent ? style.agentCellColor : style.customerCellColor)
        .cornerRadius(14, corners: .allCorners)
        .shareable(message, attachments: AttachmentItemMapper.map(message.types), spacerLength: 0)
    }
}

// MARK: - Preview

struct MultipleAttachContainer_Previews: PreviewProvider {
    
    static var previews: some View {
        LazyVStack {
            MultipleAttachmentContainer(MockData.multiAttachmentsMessage())
        }
        .environmentObject(ChatStyle())
    }
}
