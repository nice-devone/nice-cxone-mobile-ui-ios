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

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel

    @Binding private var inSelectionMode: Bool

    @State private var isImagePresented = false
    
    @StateObject private var viewModel: ImageMessageCellViewModel

    private let item: SelectableAttachment

    private var width: CGFloat {
        UIScreen.main.messageCellWidth
    }

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
                    .background(colors.foreground.subtle)
                    .foregroundColor(colors.foreground.base)
            }
            
            if inSelectionMode {
                SelectableCircle(isSelected: item.isSelected)
                    .padding([.top, .trailing], 10)
            }
        }
        .cornerRadius(StyleGuide.Attachment.cornerRadius)
    }
}

// MARK: - Preview

#Preview {
    let localization = ChatLocalization()
    let viewModel = AttachmentsViewModel(messageTypes: [])
    
    VStack {
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
}
