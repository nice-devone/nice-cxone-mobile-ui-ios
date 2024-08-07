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

import AVFoundation
import Kingfisher
import SwiftUI

struct SelectableVideoMessageCell: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    
    @ObservedObject private var viewModel: VideoMessageCellViewModel
    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel

    @Environment(\.colorScheme) var colorScheme

    @Binding var inSelectionMode: Bool
    
    @State private var isVideoSheetVisible = false

    private let item: SelectableAttachment

    private var width: CGFloat {
        UIScreen.main.messageCellWidth
    }

    // MARK: - Init

    init?(item: SelectableAttachment, attachmentsViewModel: AttachmentsViewModel, inSelectionMode: Binding<Bool>) {
        guard let attachmentItem = AttachmentItemMapper.map(item.messageType) else {
            return nil
        }

        self.viewModel = VideoMessageCellViewModel(item: attachmentItem)
        self.attachmentsViewModel = attachmentsViewModel
        self.item = item
        self._inSelectionMode = inSelectionMode
    }

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumbnail
                .scaledToFill()
                .frame(width: width, height: width)
                .clipped()
                .onTapGesture {
                    if inSelectionMode {
                        attachmentsViewModel.selectAttachment(uuid: item.id)
                    } else {
                        isVideoSheetVisible.toggle()
                    }
                }
                .overlay(
                    thumbnailOverlay
                        .imageScale(.large)
                        .foregroundColor(style.formTextColor.opacity(0.5))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(style.backgroundColor.opacity(0.5))
                        )
                )
                .sheet(isPresented: $isVideoSheetVisible) {
                    if let videoURL = viewModel.cachedVideoURL {
                        VideoPlayerContainer(videoUrl: videoURL, isPresented: $isVideoSheetVisible)
                    }
                }
            
            if inSelectionMode {
                SelectableCircle(isSelected: item.isSelected)
                    .padding([.top, .trailing], 10)
            }
        }
        .cornerRadius(StyleGuide.Message.cornerRadius)
    }
}

// MARK: - Subviews

private extension SelectableVideoMessageCell {

    @ViewBuilder
    var thumbnail: some View {
        if let thumbnail = viewModel.cachedVideoURL?.getVideoThumbnail(maximumSize: CGSize(width: width, height: MultipleAttachmentContainer.cellDimension)) {
            thumbnail
                .resizable()
                .scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: StyleGuide.Message.cornerRadius)
        }
    }

    @ViewBuilder
    var thumbnailOverlay: some View {
        if isVideoSheetVisible {
            Asset.Attachment.videoInFullScreen
        } else {
            Asset.Attachment.play
        }
    }
}

// MARK: - Preview

struct SelectableVideoMessageCell_Previews: PreviewProvider {
    static let viewModel = AttachmentsViewModel(messageTypes: [])

    static var previews: some View {
        Group {
            SelectableVideoMessageCell(item: MockData.selectableVideoAttachment, attachmentsViewModel: viewModel, inSelectionMode: .constant(false))
                .previewDisplayName("Light Mode")

            SelectableVideoMessageCell(item: MockData.selectableVideoAttachment, attachmentsViewModel: viewModel, inSelectionMode: .constant(false))
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
