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

import Combine
import SwiftUI

struct SelectableImageMessageCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Padding {
            static let selectableCircleTopTrailing: CGFloat = 10
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel
    
    @Binding private var inSelectionMode: Bool
    
    @State private var isImagePresented = false
    
    @StateObject private var viewModel: ImageMessageCellViewModel
    
    private let item: SelectableAttachment
    
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
        _viewModel = StateObject(wrappedValue: ImageMessageCellViewModel(item: attachmentItem, alertType: alertType))
        self.attachmentsViewModel = attachmentsViewModel
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
                    isImagePresented.toggle()
                } else if case .failed = viewModel.loadingState {
                    Task { @MainActor in
                        await viewModel.loadImageFromURL()
                    }
                }
            } label: {
                switch viewModel.loadingState {
                case .initial, .loading:
                    AttachmentLoadingView(
                        width: StyleGuide.Sizing.Attachment.largeWidth,
                        height: StyleGuide.Sizing.Attachment.largeHeight
                    )
                case .failed:
                    AttachmentFailedView(
                        width: StyleGuide.Sizing.Attachment.largeWidth,
                        height: StyleGuide.Sizing.Attachment.largeHeight
                    )
                case .loaded(let image):
                    Image(uiImage: image) // swiftlint:disable:this accessibility_label_for_image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: StyleGuide.Sizing.Attachment.largeWidth,
                            height: StyleGuide.Sizing.Attachment.largeHeight
                        )
                        .clipped()
                        .sheet(isPresented: $isImagePresented) {
                            ImageViewer(image: Image(uiImage: image), viewerShown: $isImagePresented)
                        }
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
        .accessibilityIdentifier(A11y.AttachmentsView.Item.Image.identifier)
        .accessibilityLabel(A11y.AttachmentsView.Item.Image.label(viewModel.item.fileName))
        .accessibilityHint(
            inSelectionMode
                ? A11y.AttachmentsView.Item.Image.Hint.select
                : A11y.AttachmentsView.Item.Image.Hint.browse
        )
        .ifNotNil(cellAccessibilityValue) { view, value in
            view.accessibilityValue(value)
        }
    }
}

// MARK: - Helpers

private extension SelectableImageMessageCell {

    var cellAccessibilityValue: String? {
        if inSelectionMode {
            return item.isSelected
                ? A11y.AttachmentsView.Item.Image.Value.selected
                : A11y.AttachmentsView.Item.Image.Value.notSelected
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
    let viewModel = AttachmentsViewModel(messageTypes: [.video(MockData.videoItem)])

    HStack(spacing: 12) {
        SelectableImageMessageCell(
            item: MockData.selectableImageAttachment,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(true),
            alertType: .constant(nil)
        )

        SelectableImageMessageCell(
            item: MockData.selectableImageAttachment,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(false),
            alertType: .constant(nil)
        )
    }
    .environmentObject(ChatStyle())
}
