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

import SwiftUI

struct AttachmentGalleryVideoThumbnailView: View, Themed, LayoutAware {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Padding {
            static let selectableCircleTopTrailing: CGFloat = 10
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    // `@StateObject`, not `@ObservedObject`: `VideoMessageCellViewModel.init` kicks off a
    // background pre-fetch, so a view model recreated on every re-render would re-fire that
    // download. Matches `VideoMessageCell` and `AttachmentGalleryImageThumbnailView`.
    @StateObject private var viewModel: VideoMessageCellViewModel

    @ObservedObject private var attachmentGalleryViewModel: AttachmentGalleryViewModel
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    @Environment(\.presentAttachmentPreview) private var presentAttachmentPreview

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `AttachmentThumbnailDisplayMode.size` directly, so a rotation invalidates this view and the size
    /// is resolved again.
    private var thumbnailSize: CGSize {
        attachmentSize(for: displayMode)
    }
    
    @Binding var inSelectionMode: Bool

    private let item: SelectableAttachment
    private let displayMode: AttachmentThumbnailDisplayMode = .large
    
    // MARK: - Init
    
    init?(
        item: SelectableAttachment,
        attachmentGalleryViewModel: AttachmentGalleryViewModel,
        inSelectionMode: Binding<Bool>,
        alertType: Binding<ChatAlertType?>
    ) {
        guard let attachmentItem = AttachmentItemMapper.map(item.messageType) else {
            return nil
        }
        
        self.item = item
        self.attachmentGalleryViewModel = attachmentGalleryViewModel
        self._viewModel = StateObject(wrappedValue: VideoMessageCellViewModel(item: attachmentItem, alertType: alertType))
        self._inSelectionMode = inSelectionMode
    }
    
    // MARK: - Builder

    var body: some View {
        let clipShape = RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)

        ZStack(alignment: .topTrailing) {
            Button {
                if inSelectionMode {
                    attachmentGalleryViewModel.toggleSelection(of: item, fileName: viewModel.item.fileName)
                } else if case .loaded(let url) = viewModel.loadingState {
                    presentAttachmentPreview(.video(url, name: viewModel.item.friendlyName))
                } else if case .failed = viewModel.loadingState {
                    Task { @MainActor in
                        await viewModel.cacheVideoFromURL()
                    }
                }
            } label: {
                switch viewModel.loadingState {
                case .loaded(let url):
                    VideoThumbnailView(url: url, displayMode: displayMode)
                case .failed:
                    AttachmentFailedView(size: thumbnailSize)
                default:
                    AttachmentLoadingView(size: thumbnailSize)
                }
            }
            
            if inSelectionMode {
                SelectableCircle(isSelected: item.isSelected)
                    .padding([.top, .trailing], Constants.Padding.selectableCircleTopTrailing)
                    .accessibilityHidden(true)
            }
        }
        .clippedHitArea(clipShape)
        .overlay {
            clipShape
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.AttachmentGalleryView.Item.Video.identifier)
        .accessibilityLabel(A11y.AttachmentGalleryView.Item.Video.label(viewModel.item.fileName))
        .accessibilityHint(
            inSelectionMode
                ? A11y.AttachmentGalleryView.Item.Video.Hint.select
                : A11y.AttachmentGalleryView.Item.Video.Hint.browse
        )
        .ifNotNil(cellAccessibilityValue) { view, value in
            view.accessibilityValue(value)
        }
    }
}

// MARK: - Helpers

private extension AttachmentGalleryVideoThumbnailView {
    
    var cellAccessibilityValue: String? {
        if inSelectionMode {
            return item.isSelected
                ? A11y.AttachmentGalleryView.Item.Video.Value.selected
                : A11y.AttachmentGalleryView.Item.Video.Value.notSelected
        }
        switch viewModel.loadingState {
        case .initial, .loading:
            return A11y.AttachmentGalleryView.Item.Value.loading
        case .failed:
            return A11y.AttachmentGalleryView.Item.Value.failed
        case .loaded:
            return nil
        }
    }
}

// MARK: - Preview

#Preview {
    HStack {
        AttachmentGalleryVideoThumbnailView(
            item: MockData.selectableVideoAttachment,
            attachmentGalleryViewModel: AttachmentGalleryViewModel(messageTypes: [.video(MockData.videoItem)]),
            inSelectionMode: .constant(true),
            alertType: .constant(nil)
        )

        AttachmentGalleryVideoThumbnailView(
            item: MockData.selectableVideoAttachment,
            attachmentGalleryViewModel: AttachmentGalleryViewModel(messageTypes: [.video(MockData.videoItem)]),
            inSelectionMode: .constant(false),
            alertType: .constant(nil)
        )
    }
    .environmentObject(ChatStyle())
}
