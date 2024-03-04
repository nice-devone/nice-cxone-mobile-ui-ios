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

struct SelectableImageMessageCell: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: ImageMessageCellViewModel
    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel

    @Binding private var inSelectionMode: Bool

    @State private var isImagePresented = false

    private let item: SelectableAttachment

    private var width: CGFloat {
        UIScreen.main.messageCellWidth
    }

    // MARK: - Init

    init?(
        item: SelectableAttachment,
        attachmentsViewModel: AttachmentsViewModel,
        inSelectionMode: Binding<Bool>
    ) {
        guard let attachmentItem = AttachmentItemMapper.map(item.messageType) else {
            return nil
        }

        self.item = item
        self.viewModel = ImageMessageCellViewModel(item: attachmentItem)
        self.attachmentsViewModel = attachmentsViewModel
        self._inSelectionMode = inSelectionMode
    }

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = viewModel.image {
                let image = Image(uiImage: uiImage)

                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: width)
                    .clipped()
                    .onTapGesture {
                        if inSelectionMode {
                            attachmentsViewModel.selectAttachment(uuid: item.id)
                        } else {
                            isImagePresented.toggle()
                        }
                    }
                    .sheet(isPresented: $isImagePresented) {
                        ImageViewer(image: image, viewerShown: $isImagePresented)
                    }
            } else {
                Asset.Attachment.placeholder
                    .frame(width: width, height: width)
                    .background(Color.gray)
                    .foregroundColor(Color.black)
            }
            
            if inSelectionMode {
                SelectableCircle(isSelected: item.isSelected)
                    .padding([.top, .trailing], 10)
            }
        }
        .cornerRadius(14)
    }
}

// MARK: - Preview

struct SelectableImageMessageCell_Previews: PreviewProvider {
    
    static let viewModel = AttachmentsViewModel(messageTypes: [])

    static var previews: some View {
        Group {
            VStack {
                SelectableImageMessageCell(item: MockData.selectableImageAttachment, attachmentsViewModel: viewModel, inSelectionMode: .constant(true))
                
                SelectableImageMessageCell(item: MockData.selectableImageAttachment, attachmentsViewModel: viewModel, inSelectionMode: .constant(false))
            }
            .previewDisplayName("Light Mode")

            VStack {
                SelectableImageMessageCell(item: MockData.selectableImageAttachment, attachmentsViewModel: viewModel, inSelectionMode: .constant(true))
                
                SelectableImageMessageCell(item: MockData.selectableImageAttachment, attachmentsViewModel: viewModel, inSelectionMode: .constant(false))
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
