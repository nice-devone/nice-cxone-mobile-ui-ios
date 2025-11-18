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

struct MesssageInputAttachmentListDocumentView: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        static let fileExtensionPDF = "pdf"
        
        enum Sizing {
            static let fileExtensionCornerRadius: CGFloat = 6
            static let fileExtensionLineLimit = 1
        }
        enum Padding {
            static let fileExtensionVertical: CGFloat = 2
            static let fileExtensionHorizontal: CGFloat = 4
            static let documentThumbnailVertical: CGFloat = 6
            static let documentThumbnailHorizontal: CGFloat = 16
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme

    @StateObject private var pdfViewModel: PDFViewModel
    
    private let displayMode: AttachmentThumbnailDisplayMode = .small
    
    let item: AttachmentItem
    
    // MARK: - Init
    
    init(item: AttachmentItem) {
        self.item = item
        
        _pdfViewModel = StateObject(wrappedValue: PDFViewModel(attachmentItem: item))
    }
    
    // MARK: - Builder
    
    @ViewBuilder
    var body: some View {
        switch UTType(mimeType: item.mimeType)?.preferredFilenameExtension {
        case Constants.fileExtensionPDF:
            pdfThumbnailView
        case let .some(fileExtension):
            documentThumbnailView(fileExtension: fileExtension)
        default:
            AttachmentLoadingView(title: localization.loadingDoc, width: displayMode.size.width, height: displayMode.size.height)
        }
    }
}

// MARK: - Subviews

private extension MesssageInputAttachmentListDocumentView {

    var pdfThumbnailView: some View {
        PDFThumbnailView(
            viewModel: pdfViewModel,
            inSelectionMode: .constant(false),
            width: displayMode.size.width - 2 * StyleGuide.Sizing.Attachment.borderWidth,
            height: displayMode.size.height - 2 * StyleGuide.Sizing.Attachment.borderWidth
        )
        .overlay(
            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
            .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
            .frame(width: displayMode.size.width, height: displayMode.size.height)
        )
    }
    
    func documentThumbnailView(fileExtension: String) -> some View {
        ZStack {
            Asset.Images.blankFile.swiftUIImage
                .resizable()
                .foregroundStyle(colors.background.surface.variant)
            
            Text(fileExtension.uppercased())
                .font(.caption2)
                .bold()
                .foregroundStyle(colors.brand.onPrimary)
                .truncationMode(.middle)
                .lineLimit(Constants.Sizing.fileExtensionLineLimit)
                .padding(.vertical, Constants.Padding.fileExtensionVertical)
                .padding(.horizontal, Constants.Padding.fileExtensionHorizontal)
                .background {
                    RoundedRectangle(cornerRadius: Constants.Sizing.fileExtensionCornerRadius)
                        .fill(colors.brand.primary)
                }
        }
        .padding(.vertical, Constants.Padding.documentThumbnailVertical)
        .padding(.horizontal, Constants.Padding.documentThumbnailHorizontal)
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
        )
        .frame(width: displayMode.size.width, height: displayMode.size.height)
    }
}

// MARK: - Previews

@available(iOS 16, *)
#Preview {
    let mimeTypes: [[AttachmentItem]] = [
        [
            MockData.audioItem,
            MockData.videoItem,
            MockData.docPreviewItem
        ],
        [
            MockData.pptPreviewItem,
            MockData.xlsPreviewItem,
            MockData.pdfPreviewItem
        ]
    ]
    
    Grid(horizontalSpacing: 10, verticalSpacing: 10) {
        ForEach(mimeTypes, id: \.self) { section in
            GridRow {
                ForEach(section, id: \.self) { item in
                    MesssageInputAttachmentListDocumentView(item: item)
                }
            }
        }
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
