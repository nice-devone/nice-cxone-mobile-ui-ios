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

struct SelectableDocumentMessageCell: View, Themed {
    
    // MARK: - Properties
    
    @ObservedObject private var pdfViewModel: PDFViewModel
    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel

    @Environment(\.colorScheme) var scheme

    @EnvironmentObject var style: ChatStyle

    @Binding private var inSelectionMode: Bool

    private static var width: CGFloat {
        UIScreen.main.messageCellWidth
    }
    
    private static let selectableCirclePadding: CGFloat = 10
    private static let labelCornerRadius: CGFloat = 6
    private static let minimumScaleFactor: CGFloat = 0.5
    private static let lineLimit = 1
    private static let fileExtensionVerticalPadding: CGFloat = 10
    private static let fileExtensionHorizontalPadding: CGFloat = 10
    private static let blankFileHorizontalPadding: CGFloat = 10
    
    private var fileExtension: String? {
        attachmentItem.fileName.pathExtension?.nilIfEmpty()
            ?? attachmentItem.url.pathExtension.lowercased().nilIfEmpty()
            ?? attachmentItem.mimeType.preferredMimeTypeExtension?.nilIfEmpty()
            ?? nil
    }

    private let attachment: SelectableAttachment
    private let attachmentItem: AttachmentItem

    // MARK: - Init
    
    init(
        attachment: SelectableAttachment,
        item: AttachmentItem,
        attachmentsViewModel: AttachmentsViewModel,
        inSelectionMode: Binding<Bool>
    ) {
        self.attachment = attachment
        self.attachmentItem = item
        self.pdfViewModel = PDFViewModel(attachmentItem: item)
        self.attachmentsViewModel = attachmentsViewModel
        self._inSelectionMode = inSelectionMode
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if fileExtension == "pdf" {
                pdfView
            } else {
                documentView
            }
            
            if inSelectionMode {
                SelectableCircle(isSelected: attachment.isSelected)
                    .padding([.top, .trailing], Self.selectableCirclePadding)
            }
        }
        .onTapGesture {
            if inSelectionMode {
                attachmentsViewModel.selectAttachment(uuid: attachment.id)
            }
        }
    }
}

// MARK: - Subviews

private extension SelectableDocumentMessageCell {
    
    var pdfView: some View {
        PDFThumbnailView(viewModel: pdfViewModel, inSelectionMode: $inSelectionMode, width: Self.width, height: Self.width)
    }
    
    var documentView: some View {
        guard case .documentPreview = attachment.messageType else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            ZStack {
                Asset.Images.blankFile.swiftUIImage
                    .resizable()
                    .foregroundStyle(colors.foreground.staticLight)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .ifNotNil(fileExtension) { view, fileExtension in
                        view.overlay {
                            Text(fileExtension.uppercased())
                                .font(.callout)
                                .bold()
                                .foregroundStyle(colors.foreground.staticLight)
                                .minimumScaleFactor(Self.minimumScaleFactor)
                                .lineLimit(Self.lineLimit)
                                .padding(.vertical, Self.fileExtensionVerticalPadding)
                                .padding(.horizontal, Self.fileExtensionHorizontalPadding)
                                .background {
                                    RoundedRectangle(cornerRadius: Self.labelCornerRadius)
                                        .fill(Color(.systemBlue))
                                }
                        }
                    }
            }
            .padding(.horizontal, Self.blankFileHorizontalPadding)
            .frame(width: Self.width, height: Self.width)
        )
    }
}

// MARK: - Helper Methods

private extension String {
    
    var pathExtension: String? {
        let ext = URL(fileURLWithPath: self).pathExtension.lowercased()
        
        return ext.isEmpty ? nil : ext
    }

    var preferredMimeTypeExtension: String? {
        guard let utType = UTType(mimeType: self),
              let preferredExtension = utType.preferredFilenameExtension?.lowercased(),
              !preferredExtension.isEmpty
        else {
            return nil
       }

        return preferredExtension
   }
}

// MARK: - Previews

#Preview {
    let item: AttachmentItem = MockData.docPreviewItem
    let viewModel = AttachmentsViewModel(messageTypes: [.documentPreview(item)])
    
    VStack {
        SelectableDocumentMessageCell(
            attachment: MockData.selectableDocumentAttachment,
            item: item,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(true)
        )
        .frame(width: 160, height: 217)
        
        SelectableDocumentMessageCell(
            attachment: MockData.selectableDocumentAttachment,
            item: item,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(false)
        )
        .frame(width: 160, height: 217)
    }
    .environmentObject(ChatStyle())
}
