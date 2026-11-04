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

struct DocumentMessageCell: View, Themed, LayoutAware {

    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `AttachmentThumbnailDisplayMode.size` directly, so a rotation invalidates this view and the size
    /// is resolved again.
    private var thumbnailSize: CGSize {
        attachmentSize(for: displayMode)
    }

    @Binding private var alertType: ChatAlertType?
    
    /// `nil` if the message is part of the `MultipleAttachmentsContainer` view.
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
    }
    
    // MARK: - Builder
    
    var body: some View {
        content
            .if(messagePosition != nil) { view in
                view
                    .shareable(message, attachments: [item])
            }
    }
}

// MARK: - Subviews

private extension DocumentMessageCell {
    
    /// The thumbnail size minus the attachment border, for content drawn inside it.
    var innerThumbnailSize: CGSize {
        StyleGuide.Sizing.Attachment.innerSize(for: thumbnailSize)
    }

    @ViewBuilder
    var content: some View {
        if item.isPDF {
            if let messagePosition {
                standalonePDF(messagePosition)
            } else {
                pdfInMultipleContainer
            }
        } else if let fileExtension = item.fileExtension {
            if let messagePosition {
                standaloneDocument(fileExtension: fileExtension, position: messagePosition)
            } else {
                documentInMultipleContainer(fileExtension)
            }
        } else {
            AttachmentLoadingView(size: thumbnailSize, clipShape: messagePosition.attachmentClipShape(isUserAgent: message.isUserAgent), drawsBorder: true)
        }
    }
    
    func standalonePDF(_ position: MessageGroupPosition) -> some View {
        let unevenRoundedRectangle = position.clipShape(
            isUserAgent: message.isUserAgent,
            insetAmount: StyleGuide.Sizing.Attachment.borderWidth
        )
        
        return PDFThumbnailView(
            viewModel: PDFViewModel(attachmentItem: item, alertType: $alertType),
            inSelectionMode: .constant(false),
            width: innerThumbnailSize.width,
            height: innerThumbnailSize.height,
            clipShape: unevenRoundedRectangle
        )
        .clippedHitArea(unevenRoundedRectangle)
        .overlay {
            unevenRoundedRectangle
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
        }
    }
    
    var pdfInMultipleContainer: some View {
        let clipShape = messagePosition.attachmentClipShape(isUserAgent: message.isUserAgent)

        return clipShape
            .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
            .frame(size: thumbnailSize)
            .background {
                PDFThumbnailView(
                    viewModel: PDFViewModel(attachmentItem: item, alertType: $alertType),
                    inSelectionMode: .constant(false),
                    width: innerThumbnailSize.width,
                    height: innerThumbnailSize.height
                )
                .clippedHitArea(
                    RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.innerCornerRadius)
                )
            }
    }
    
    func standaloneDocument(fileExtension: String, position: MessageGroupPosition) -> some View {
        let unevenRoundedRectangle = position.clipShape(isUserAgent: message.isUserAgent)

        return DocumentCellDocumentThumbnailView(
            fileExtension: fileExtension,
            url: item.url,
            fileName: item.fileName,
            alertType: $alertType,
            clipShape: unevenRoundedRectangle
        )
        .background(colors.bubbleBackground(isUserAgent: message.isUserAgent))
        .clipShape(unevenRoundedRectangle)
        .overlay {
            unevenRoundedRectangle
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
        }
    }

    func documentInMultipleContainer(_ fileExtension: String) -> some View {
        let clipShape = messagePosition.attachmentClipShape(isUserAgent: message.isUserAgent)

        return DocumentCellDocumentThumbnailView(
            fileExtension: fileExtension,
            url: item.url,
            fileName: item.fileName,
            alertType: $alertType
        )
        .background(colors.bubbleBackground(isUserAgent: message.isUserAgent))
        .clipShape(clipShape)
        .overlay {
            clipShape
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
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
                alertType: .constant(nil)
            )
            
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.customer),
                item: MockData.docPreviewItem,
                position: .single,
                alertType: .constant(nil)
            )
            
            VStack(spacing: 2) {
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.agent),
                    item: MockData.docPreviewItem,
                    position: .first,
                    alertType: .constant(nil)
                )
                
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.agent),
                    item: MockData.docPreviewItem,
                    position: .inside,
                    alertType: .constant(nil)
                )
                
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.agent),
                    item: MockData.docPreviewItem,
                    position: .last,
                    alertType: .constant(nil)
                )
            }
            
            VStack(spacing: 2) {
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.customer),
                    item: MockData.docPreviewItem,
                    position: .first,
                    alertType: .constant(nil)
                )
                
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.customer),
                    item: MockData.docPreviewItem,
                    position: .inside,
                    alertType: .constant(nil)
                )
                
                DocumentMessageCell(
                    message: MockData.documentMessage(user: MockData.customer),
                    item: MockData.docPreviewItem,
                    position: .last,
                    alertType: .constant(nil)
                )
            }
        }
    }
    .padding(.horizontal, 12)
    .environmentObject(ChatStyle())
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
                alertType: .constant(nil)
            )
            
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.agent),
                item: MockData.docPreviewItem,
                alertType: .constant(nil)
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
                alertType: .constant(nil)
            )
            
            DocumentMessageCell(
                message: MockData.documentMessage(user: MockData.customer),
                item: MockData.docPreviewItem,
                alertType: .constant(nil)
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors(for: scheme).brand.primary)
        )
    }
    .environmentObject(style)
}

#Preview("PDF (single)") {
    ScrollView {
        VStack {
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.agent),
                item: MockData.pdfPreviewItem,
                position: .single,
                alertType: .constant(nil)
            )
            
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.customer),
                item: MockData.pdfPreviewItem,
                position: .single,
                alertType: .constant(nil)
            )
            
            VStack(spacing: 2) {
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.agent),
                    item: MockData.pdfPreviewItem,
                    position: .first,
                    alertType: .constant(nil)
                )
                
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.agent),
                    item: MockData.pdfPreviewItem,
                    position: .inside,
                    alertType: .constant(nil)
                )
                
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.agent),
                    item: MockData.pdfPreviewItem,
                    position: .last,
                    alertType: .constant(nil)
                )
            }
            
            VStack(spacing: 2) {
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.customer),
                    item: MockData.pdfPreviewItem,
                    position: .first,
                    alertType: .constant(nil)
                )
                
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.customer),
                    item: MockData.pdfPreviewItem,
                    position: .inside,
                    alertType: .constant(nil)
                )
                
                DocumentMessageCell(
                    message: MockData.pdfMessage(user: MockData.customer),
                    item: MockData.pdfPreviewItem,
                    position: .last,
                    alertType: .constant(nil)
                )
            }
        }
    }
    .padding(.horizontal, 12)
    .environmentObject(ChatStyle())
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
                alertType: .constant(nil)
            )
            
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.agent),
                item: MockData.pdfPreviewItem,
                alertType: .constant(nil)
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
                alertType: .constant(nil)
            )
            
            DocumentMessageCell(
                message: MockData.pdfMessage(user: MockData.customer),
                item: MockData.pdfPreviewItem,
                alertType: .constant(nil)
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors(for: scheme).brand.primary)
        )
    }
    .environmentObject(style)
}
