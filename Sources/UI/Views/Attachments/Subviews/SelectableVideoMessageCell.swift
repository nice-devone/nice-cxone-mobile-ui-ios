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

import AVFoundation
import AVKit
import SwiftUI

struct SelectableVideoMessageCell: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Padding {
            static let selectableCircleTopTrailing: CGFloat = 10
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @ObservedObject private var viewModel: VideoMessageCellViewModel
    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel

    @Environment(\.colorScheme) var scheme

    @Binding var inSelectionMode: Bool
    
    @State private var isVideoSheetVisible = false

    private let item: SelectableAttachment
    private let displayMode: AttachmentThumbnailDisplayMode = .large
    
    // MARK: - Init

    init?(
        item: SelectableAttachment,
        attachmentsViewModel: AttachmentsViewModel,
        inSelectionMode: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        guard let attachmentItem = AttachmentItemMapper.map(item.messageType) else {
            return nil
        }

        self.item = item
        self.attachmentsViewModel = attachmentsViewModel
        self.viewModel = VideoMessageCellViewModel(item: attachmentItem, alertType: alertType, localization: localization)
        self._inSelectionMode = inSelectionMode
    }

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                if inSelectionMode {
                    attachmentsViewModel.selectAttachment(with: item.id)
                } else {
                    isVideoSheetVisible.toggle()
                }
            } label: {
                VideoThumbnailView(url: viewModel.cachedVideoURL, displayMode: displayMode)
            }
            .sheet(isPresented: $isVideoSheetVisible) {
                if let videoURL = viewModel.cachedVideoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .ignoresSafeArea(.container)
                }
            }
            
            if inSelectionMode {
                SelectableCircle(isSelected: item.isSelected)
                    .padding([.top, .trailing], Constants.Padding.selectableCircleTopTrailing)
            }
        }
        .cornerRadius(StyleGuide.Sizing.Attachment.cornerRadius)
    }
}

// MARK: - Preview

#Preview {
    let localization = ChatLocalization()
    
    HStack {
        SelectableVideoMessageCell(
            item: MockData.selectableVideoAttachment,
            attachmentsViewModel: AttachmentsViewModel(messageTypes: [.video(MockData.videoItem)]),
            inSelectionMode: .constant(true),
            alertType: .constant(nil),
            localization: localization
        )
        
        SelectableVideoMessageCell(
            item: MockData.selectableVideoAttachment,
            attachmentsViewModel: AttachmentsViewModel(messageTypes: [.video(MockData.videoItem)]),
            inSelectionMode: .constant(false),
            alertType: .constant(nil),
            localization: localization
        )
    }
    .environmentObject(ChatStyle())
}
