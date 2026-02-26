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
    @EnvironmentObject var localization: ChatLocalization
    
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
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        guard let attachmentItem = AttachmentItemMapper.map(item.messageType) else {
            return nil
        }

        self.item = item
        _viewModel = StateObject(wrappedValue: ImageMessageCellViewModel(item: attachmentItem, alertType: alertType, localization: localization))
        self.attachmentsViewModel = attachmentsViewModel
        self._inSelectionMode = inSelectionMode
    }

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = viewModel.image.map(Image.init) {
                Button {
                    if inSelectionMode {
                        attachmentsViewModel.selectAttachment(with: item.id)
                    } else {
                        isImagePresented.toggle()
                    }
                } label: {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: StyleGuide.Sizing.Attachment.largeWidth,
                            height: StyleGuide.Sizing.Attachment.largeHeight
                        )
                        .clipped()
                }
                .sheet(isPresented: $isImagePresented) {
                    ImageViewer(image: image, viewerShown: $isImagePresented)
                }
            } else {
                AttachmentLoadingView(
                    title: localization.commonLoading,
                    width: StyleGuide.Sizing.Attachment.largeWidth,
                    height: StyleGuide.Sizing.Attachment.largeHeight
                )
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
    let viewModel = AttachmentsViewModel(messageTypes: [.video(MockData.videoItem)])
    
    HStack(spacing: 12) {
        SelectableImageMessageCell(
            item: MockData.selectableImageAttachment,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(true),
            alertType: .constant(nil),
            localization: localization
        )
        
        SelectableImageMessageCell(
            item: MockData.selectableImageAttachment,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(false),
            alertType: .constant(nil),
            localization: localization
        )
    }
    .environmentObject(ChatStyle())
    .environmentObject(localization)
}
