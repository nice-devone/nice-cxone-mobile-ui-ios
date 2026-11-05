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

struct AttachmentGalleryImageThumbnailView: View, Themed, LayoutAware {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Padding {
            static let selectableCircleTopTrailing: CGFloat = 10
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    @Environment(\.presentAttachmentPreview) private var presentAttachmentPreview

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `StyleGuide.Sizing.Attachment` directly, so a rotation invalidates this view and the size is
    /// resolved again.
    private var thumbnailSize: CGSize {
        attachmentSize(for: .large)
    }
    
    @ObservedObject private var attachmentGalleryViewModel: AttachmentGalleryViewModel
    
    @Binding private var inSelectionMode: Bool

    @StateObject private var viewModel: ImageMessageCellViewModel
    
    private let item: SelectableAttachment
    
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
        _viewModel = StateObject(wrappedValue: ImageMessageCellViewModel(item: attachmentItem, alertType: alertType))
        self.attachmentGalleryViewModel = attachmentGalleryViewModel
        self._inSelectionMode = inSelectionMode
    }
    
    // MARK: - Builder

    var body: some View {
        let clipShape = RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)

        ZStack(alignment: .topTrailing) {
            Button {
                if inSelectionMode {
                    attachmentGalleryViewModel.toggleSelection(of: item, fileName: viewModel.item.fileName)
                } else if case .loaded(let image) = viewModel.loadingState {
                    presentAttachmentPreview(.image(image, name: viewModel.item.friendlyName))
                } else if case .failed = viewModel.loadingState {
                    Task { @MainActor in
                        await viewModel.loadImageFromURL()
                    }
                }
            } label: {
                switch viewModel.loadingState {
                case .initial, .loading:
                    AttachmentLoadingView(size: thumbnailSize)
                case .failed:
                    AttachmentFailedView(size: thumbnailSize)
                case .loaded(let image):
                    let image = Image(uiImage: image)

                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: thumbnailSize.width,
                            height: thumbnailSize.height
                        )
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
        .accessibilityIdentifier(A11y.AttachmentGalleryView.Item.Image.identifier)
        .accessibilityLabel(A11y.AttachmentGalleryView.Item.Image.label(viewModel.item.fileName))
        .accessibilityHint(
            inSelectionMode
                ? A11y.AttachmentGalleryView.Item.Image.Hint.select
                : A11y.AttachmentGalleryView.Item.Image.Hint.browse
        )
        .ifNotNil(cellAccessibilityValue) { view, value in
            view.accessibilityValue(value)
        }
    }
}

// MARK: - Helpers

private extension AttachmentGalleryImageThumbnailView {

    var cellAccessibilityValue: String? {
        if inSelectionMode {
            return item.isSelected
                ? A11y.AttachmentGalleryView.Item.Image.Value.selected
                : A11y.AttachmentGalleryView.Item.Image.Value.notSelected
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
    let viewModel = AttachmentGalleryViewModel(messageTypes: [.video(MockData.videoItem)])

    NavigationStack {
        HStack(spacing: 12) {
            AttachmentGalleryImageThumbnailView(
                item: MockData.selectableImageAttachment,
                attachmentGalleryViewModel: viewModel,
                inSelectionMode: .constant(true),
                alertType: .constant(nil)
            )

            AttachmentGalleryImageThumbnailView(
                item: MockData.selectableImageAttachment,
                attachmentGalleryViewModel: viewModel,
                inSelectionMode: .constant(false),
                alertType: .constant(nil)
            )
        }
        .environmentObject(ChatStyle())
    }
}
