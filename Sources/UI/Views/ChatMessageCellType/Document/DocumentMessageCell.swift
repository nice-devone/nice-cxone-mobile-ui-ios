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

import SwiftUI
import UniformTypeIdentifiers

struct DocumentMessageCell: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        static let fileExtensionPDF = "pdf"
        
        enum Spacing {
            static let shareButtonMinLength: CGFloat = 0
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme

    @StateObject private var pdfViewModel: PDFViewModel

    @Binding private var alertType: ChatAlertType?
    
    /// `nil` if the message is part of the `MultipleAttachmentContainer` view.
    let messagePosition: MessageGroupPosition?
    let message: ChatMessage
    let item: AttachmentItem
    
    private let displayMode: AttachmentThumbnailDisplayMode = .regular
    
    // MARK: - Init
    
    init(
        message: ChatMessage,
        item: AttachmentItem,
        position: MessageGroupPosition? = nil,
        alertType: Binding<ChatAlertType?>
    ) {
        self.messagePosition = position
        self.message = message
        self.item = item
        self._alertType = alertType
        
        _pdfViewModel = StateObject(wrappedValue: PDFViewModel(attachmentItem: item))
    }
    
    // MARK: - Builder
    
    var body: some View {
        content
            .if(messagePosition != nil) { view in
                view
                    .shareable(message, attachments: [item], spacerLength: Constants.Spacing.shareButtonMinLength)
            }
    }
}

// MARK: - Subviews

private extension DocumentMessageCell {
    
    @ViewBuilder
    var content: some View {
        switch UTType(mimeType: item.mimeType)?.preferredFilenameExtension {
        case Constants.fileExtensionPDF:
            if let messagePosition {
                standalonePDF(messagePosition)
            } else {
                pdfInMultipleContainer
            }
        case let .some(fileExtension):
            if let messagePosition {
                standaloneDocument(fileExtension: fileExtension, position: messagePosition)
            } else {
                documentInMultipleContainer(fileExtension)
            }
        default:
            AttachmentLoadingView(title: localization.loadingDoc, width: displayMode.size.width, height: displayMode.size.height)
        }
    }
    
    func standalonePDF(_ position: MessageGroupPosition) -> some View {
        let unevenRoundedRectangle = UnevenRoundedRectangle(
            topLeft: position.topLeftCornerRadius(isUserAgent: message.isUserAgent),
            topRight: position.topRightCornerRadius(isUserAgent: message.isUserAgent),
            bottomLeft: position.bottomLeftCornerRadius(isUserAgent: message.isUserAgent),
            bottomRight: position.bottomRightCornerRadius(isUserAgent: message.isUserAgent),
            insetAmount: StyleGuide.Sizing.Attachment.borderWidth
        )
        
        return PDFThumbnailView(
            viewModel: pdfViewModel,
            inSelectionMode: .constant(false),
            width: displayMode.size.width - (2 * StyleGuide.Sizing.Attachment.borderWidth),
            height: displayMode.size.height - (2 * StyleGuide.Sizing.Attachment.borderWidth)
        )
        .clipShape(unevenRoundedRectangle)
        .overlay {
            unevenRoundedRectangle
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
        }
    }
    
    var pdfInMultipleContainer: some View {
        RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
            .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
            .frame(width: displayMode.size.width, height: displayMode.size.height)
            .background {
                PDFThumbnailView(
                    viewModel: pdfViewModel,
                    inSelectionMode: .constant(false),
                    width: displayMode.size.width - (2 * StyleGuide.Sizing.Attachment.borderWidth),
                    height: displayMode.size.height - (2 * StyleGuide.Sizing.Attachment.borderWidth)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius - (2 * StyleGuide.Sizing.Attachment.borderWidth))
                )
            }
    }
    
    func standaloneDocument(fileExtension: String, position: MessageGroupPosition) -> some View {
        DocumentCellDocumentThumbnailView(
            fileExtension: fileExtension,
            url: item.url,
            alertType: $alertType,
            localization: localization
        )
        .messageChatStyle(message, position: position)
    }
    func documentInMultipleContainer(_ fileExtension: String) -> some View {
        DocumentCellDocumentThumbnailView(
            fileExtension: fileExtension,
            url: item.url,
            alertType: $alertType,
            localization: localization
        )
        .overlay {
            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                .frame(width: displayMode.size.width, height: displayMode.size.height)
        }
    }
}

// MARK: - Previews

#Preview("Document (single)") {
    ScrollView {
        VStack {
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.agent),
                item: MockData.docPreviewItem,
                position: .single,
                alertType: .constant(nil),
            )
            
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.customer),
                item: MockData.docPreviewItem,
                position: .single,
                alertType: .constant(nil),
            )
            
            VStack(spacing: 2) {
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.agent),
                    item: MockData.docPreviewItem,
                    position: .first,
                    alertType: .constant(nil),
                )
                
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.agent),
                    item: MockData.docPreviewItem,
                    position: .inside,
                    alertType: .constant(nil),
                )
                
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.agent),
                    item: MockData.docPreviewItem,
                    position: .last,
                    alertType: .constant(nil),
                )
            }
            
            VStack(spacing: 2) {
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.customer),
                    item: MockData.docPreviewItem,
                    position: .first,
                    alertType: .constant(nil),
                )
                
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.customer),
                    item: MockData.docPreviewItem,
                    position: .inside,
                    alertType: .constant(nil),
                )
                
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.customer),
                    item: MockData.docPreviewItem,
                    position: .last,
                    alertType: .constant(nil),
                )
            }
        }
    }
    .padding(.horizontal, 12)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}

@available(iOS 17.0, *)
#Preview("Document (multiple attachments)") {
    @Previewable @Environment(\.colorScheme) var scheme
    
    let style = ChatStyle()
    
    VStack {
        HStack {
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.agent),
                item: MockData.docPreviewItem,
                alertType: .constant(nil),
            )
            
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.agent),
                item: MockData.docPreviewItem,
                alertType: .constant(nil),
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors(for: scheme).background.surface.default)
        )
        HStack {
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.customer),
                item: MockData.docPreviewItem,
                alertType: .constant(nil),
            )
            
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.customer),
                item: MockData.docPreviewItem,
                alertType: .constant(nil),
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors(for: scheme).brand.primary)
        )
    }
    .environmentObject(style)
    .environmentObject(ChatLocalization())
}

#Preview("PDF (single)") {
    ScrollView {
        VStack {
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.agent),
                item: MockData.pdfPreviewItem,
                position: .single,
                alertType: .constant(nil),
            )
            
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.customer),
                item: MockData.pdfPreviewItem,
                position: .single,
                alertType: .constant(nil),
            )
            
            VStack(spacing: 2) {
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.agent),
                    item: MockData.pdfPreviewItem,
                    position: .first,
                    alertType: .constant(nil),
                )
                
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.agent),
                    item: MockData.pdfPreviewItem,
                    position: .inside,
                    alertType: .constant(nil),
                )
                
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.agent),
                    item: MockData.pdfPreviewItem,
                    position: .last,
                    alertType: .constant(nil),
                )
            }
            
            VStack(spacing: 2) {
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.customer),
                    item: MockData.pdfPreviewItem,
                    position: .first,
                    alertType: .constant(nil),
                )
                
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.customer),
                    item: MockData.pdfPreviewItem,
                    position: .inside,
                    alertType: .constant(nil),
                )
                
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.customer),
                    item: MockData.pdfPreviewItem,
                    position: .last,
                    alertType: .constant(nil),
                )
            }
        }
    }
    .padding(.horizontal, 12)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}

@available(iOS 17.0, *)
#Preview("PDF (multiple attachments)") {
    @Previewable @Environment(\.colorScheme) var scheme
    
    let style = ChatStyle()
    
    VStack {
        HStack {
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.agent),
                item: MockData.pdfPreviewItem,
                alertType: .constant(nil),
            )
            
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.agent),
                item: MockData.pdfPreviewItem,
                alertType: .constant(nil),
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors(for: scheme).background.surface.default)
        )
        HStack {
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.customer),
                item: MockData.pdfPreviewItem,
                alertType: .constant(nil),
            )
            
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.customer),
                item: MockData.pdfPreviewItem,
                alertType: .constant(nil),
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors(for: scheme).brand.primary)
        )
    }
    .environmentObject(style)
    .environmentObject(ChatLocalization())
}
