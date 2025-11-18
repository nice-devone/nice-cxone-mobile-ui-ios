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

struct ImageMessageCell: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let shareButtonMinLength: CGFloat = 0
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @StateObject private var viewModel: ImageMessageCellViewModel

    @Binding var alertType: ChatAlertType?

    @State private var isImagePresented = false
    
    private let message: ChatMessage
    private let position: MessageGroupPosition?
    /// `nil` if the message is part of the `MultipleAttachmentContainer` view.
    private let displayMode: AttachmentThumbnailDisplayMode = .regular
    
    // MARK: - Init
    
    init(
        message: ChatMessage,
        item: AttachmentItem,
        position: MessageGroupPosition? = nil,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        self.message = message
        self.position = position
        self._alertType = alertType
        
        _viewModel = StateObject(wrappedValue: ImageMessageCellViewModel(
            item: item,
            alertType: alertType,
            localization: localization
        ))
    }
    
    // MARK: - Builder
    
    var body: some View {
        content
            .ifNotNil(position) { view, position in
                view
                    .messageChatStyle(message, position: position)
                    .shareable(message, attachments: [viewModel.item], spacerLength: Constants.Spacing.shareButtonMinLength)
            }.if(position == nil) { view in
                view
                    .cornerRadius(StyleGuide.Sizing.Attachment.cornerRadius, corners: .allCorners)
            }
    }
}

// MARK: - Subviews

private extension ImageMessageCell {

    @ViewBuilder
    var content: some View {
        if let image = viewModel.image.map(Image.init) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: StyleGuide.Sizing.Attachment.regularDimension,
                    height: StyleGuide.Sizing.Attachment.regularDimension
                )
                .clipped()
                .contentShape(Rectangle())
                .onTapGesture {
                    isImagePresented = true
                }
                .sheet(isPresented: $isImagePresented) {
                    ImageViewer(image: image, viewerShown: $isImagePresented)
                }
        } else {
            AttachmentLoadingView(
                title: localization.commonLoading,
                width: StyleGuide.Sizing.Attachment.regularDimension,
                height: StyleGuide.Sizing.Attachment.regularDimension
            )
        }
    }
}

// MARK: - Preview

#Preview("Single") {
    ScrollView {
        VStack {
            ImageMessageCell(
                message: MockData.imageMessage(user: MockData.agent),
                item: MockData.imageItem,
                position: .single,
                alertType: .constant(nil),
                localization: ChatLocalization()
            )
            
            ImageMessageCell(
                message: MockData.imageMessage(user: MockData.customer),
                item: MockData.imageItem,
                position: .single,
                alertType: .constant(nil),
                localization: ChatLocalization()
            )
            
            VStack(spacing: 4) {
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.agent),
                    item: MockData.imageItem,
                    position: .first,
                    alertType: .constant(nil),
                    localization: ChatLocalization()
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.agent),
                    item: MockData.imageItem,
                    position: .inside,
                    alertType: .constant(nil),
                    localization: ChatLocalization()
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.agent),
                    item: MockData.imageItem,
                    position: .last,
                    alertType: .constant(nil),
                    localization: ChatLocalization()
                )
            }
            
            VStack(spacing: 4) {
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.customer),
                    item: MockData.imageItem,
                    position: .first,
                    alertType: .constant(nil),
                    localization: ChatLocalization()
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.customer),
                    item: MockData.imageItem,
                    position: .inside,
                    alertType: .constant(nil),
                    localization: ChatLocalization()
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.customer),
                    item: MockData.imageItem,
                    position: .last,
                    alertType: .constant(nil),
                    localization: ChatLocalization()
                )
            }
        }
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}

@available(iOS 17, *)
#Preview("Multiple") {
    @Previewable @Environment(\.colorScheme) var scheme
    
    let style = ChatStyle()
    let localization = ChatLocalization()
    VStack {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ImageMessageCell(
                    message: MockData.imageMessageWithText(user: MockData.agent),
                    item: MockData.imageItem,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.agent),
                    item: MockData.imageItem,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
            
            HStack(spacing: 12) {
                ImageMessageCell(
                    message: MockData.imageMessageWithText(user: MockData.agent),
                    item: MockData.imageItem,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.agent),
                    item: MockData.imageItem,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.colors(for: scheme).background.surface.default)
        )
        
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ImageMessageCell(
                    message: MockData.imageMessageWithText(user: MockData.customer),
                    item: MockData.imageItem,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.customer),
                    item: MockData.imageItem,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
            
            HStack(spacing: 12) {
                ImageMessageCell(
                    message: MockData.imageMessageWithText(user: MockData.customer),
                    item: MockData.imageItem,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                ImageMessageCell(
                    message: MockData.imageMessage(user: MockData.customer),
                    item: MockData.imageItem,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.colors(for: scheme).brand.primary)
        )
    }
    .environmentObject(style)
    .environmentObject(localization)
}
