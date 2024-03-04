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

struct LoadingImageMessageCell: View {

    // MARK: - Properties

    @ObservedObject var viewModel: ImageMessageCellViewModel

    @State private var isImagePresented = false

    private let isMultiAttachment: Bool
    private var image: Image?
    
    private var width: CGFloat {
        UIScreen.main.messageCellWidth
    }

    // MARK: - Init

    init(item: AttachmentItem, isMultiAttachment: Bool) {
        self.viewModel = ImageMessageCellViewModel(item: item)
        self.isMultiAttachment = isMultiAttachment
    }

    // MARK: - Builder

    var body: some View {
        if let uiImage = viewModel.image {
            let image = Image(uiImage: uiImage)

            image
                .resizable()
                .scaledToFill()
                .frame(
                    width: isMultiAttachment ? MultipleAttachmentContainer.cellDimension : width,
                    height: isMultiAttachment ? MultipleAttachmentContainer.cellDimension : width
                )
                .clipped()
                .onTapGesture {
                    isImagePresented = true
                }
                .sheet(isPresented: $isImagePresented) {
                    ImageViewer(image: image, viewerShown: $isImagePresented)
                }
        } else {
            Asset.Attachment.placeholder
                .frame(
                    width: isMultiAttachment ? MultipleAttachmentContainer.cellDimension : width,
                    height: MultipleAttachmentContainer.cellDimension
                )
                .background(Color.gray)
                .foregroundColor(Color.black)
        }
    }
}

// MARK: - Preview

struct LoadingImageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            LoadingImageMessageCell(item: MockData.imageItem, isMultiAttachment: false)
                .previewDisplayName("Light Mode")
                .preferredColorScheme(.light)

            LoadingImageMessageCell(item: MockData.imageItem, isMultiAttachment: true)
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
    }
}
