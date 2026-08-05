//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
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
        alertType: Binding<ChatAlertType?>
    ) {
        guard let attachmentItem = AttachmentItemMapper.map(item.messageType) else {
            return nil
        }
        
        self.item = item
        self.attachmentsViewModel = attachmentsViewModel
        self.viewModel = VideoMessageCellViewModel(item: attachmentItem, alertType: alertType)
        self._inSelectionMode = inSelectionMode
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                if inSelectionMode {
                    let willBeSelected = !item.isSelected
                    attachmentsViewModel.selectAttachment(with: item.id)
                    
                    A11y.announce(
                        willBeSelected
                        ? A11y.Announcement.AttachmentsView.selected(viewModel.item.fileName)
                        : A11y.Announcement.AttachmentsView.deselected(viewModel.item.fileName)
                    )
                } else if case .loaded = viewModel.loadingState {
                    isVideoSheetVisible.toggle()
                } else if case .failed = viewModel.loadingState {
                    Task { @MainActor in
                        await viewModel.cacheVideoFromURL()
                    }
                }
            } label: {
                switch viewModel.loadingState {
                case .loaded(let url):
                    VideoThumbnailView(url: url, displayMode: displayMode)
                        .sheet(isPresented: $isVideoSheetVisible) {
                            VideoPlayer(player: AVPlayer(url: url))
                                .ignoresSafeArea(.container)
                        }
                case .failed:
                    AttachmentFailedView(
                        width: displayMode.size.width,
                        height: displayMode.size.height
                    )
                default:
                    AttachmentLoadingView(
                        width: displayMode.size.width,
                        height: displayMode.size.height
                    )
                }
            }
            
            if inSelectionMode {
                SelectableCircle(isSelected: item.isSelected)
                    .padding([.top, .trailing], Constants.Padding.selectableCircleTopTrailing)
                    .accessibilityHidden(true)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.AttachmentsView.Item.Video.identifier)
        .accessibilityLabel(A11y.AttachmentsView.Item.Video.label(viewModel.item.fileName))
        .accessibilityHint(
            inSelectionMode
                ? A11y.AttachmentsView.Item.Video.Hint.select
                : A11y.AttachmentsView.Item.Video.Hint.browse
        )
        .ifNotNil(cellAccessibilityValue) { view, value in
            view.accessibilityValue(value)
        }
    }
}

// MARK: - Helpers

private extension SelectableVideoMessageCell {
    
    var cellAccessibilityValue: String? {
        if inSelectionMode {
            return item.isSelected
                ? A11y.AttachmentsView.Item.Video.Value.selected
                : A11y.AttachmentsView.Item.Video.Value.notSelected
        }
        switch viewModel.loadingState {
        case .initial, .loading:
            return A11y.AttachmentsView.Item.Value.loading
        case .failed:
            return A11y.AttachmentsView.Item.Value.failed
        case .loaded:
            return nil
        }
    }
}

// MARK: - Preview

#Preview {
    HStack {
        SelectableVideoMessageCell(
            item: MockData.selectableVideoAttachment,
            attachmentsViewModel: AttachmentsViewModel(messageTypes: [.video(MockData.videoItem)]),
            inSelectionMode: .constant(true),
            alertType: .constant(nil)
        )

        SelectableVideoMessageCell(
            item: MockData.selectableVideoAttachment,
            attachmentsViewModel: AttachmentsViewModel(messageTypes: [.video(MockData.videoItem)]),
            inSelectionMode: .constant(false),
            alertType: .constant(nil)
        )
    }
    .environmentObject(ChatStyle())
}
