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

struct MultipleAttachmentDocumentView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        static let pdfFileExtension = "pdf"

        enum Sizing {
            static let fileExtensionContainerCornerRadius: CGFloat = 6
            static let fileExtensionLineLimit = 1
        }
        
        enum Padding {
            static let fileExtensionVertical: CGFloat = 6
            static let fileExtensionHorizontal: CGFloat = 8
            static let fileExtensionContainerVertical: CGFloat = 34
            static let fileExtensionContainerHorizontal: CGFloat = 16
            static let blankFileHorizontal: CGFloat = 22
            static let blankFileVertical: CGFloat = 12
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @StateObject private var documentStateViewModel: DocumentStateViewModel
    
    @StateObject private var pdfViewModel: PDFViewModel
    
    let fileExtension: String?
    let url: URL
    let isSenderAgent: Bool
    let localization: ChatLocalization
    
    private let displayMode: AttachmentThumbnailDisplayMode = .regular
    
    // MARK: - Init
    
    init(
        attachmentItem: AttachmentItem,
        isSenderAgent: Bool,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        self.fileExtension = UTType(mimeType: attachmentItem.mimeType)?.preferredFilenameExtension
        self.url = attachmentItem.url
        self.isSenderAgent = isSenderAgent
        self.localization = localization
        
        self._documentStateViewModel = StateObject(wrappedValue: DocumentStateViewModel(alertType: alertType, localization: localization))
        self._pdfViewModel = StateObject(wrappedValue: PDFViewModel(attachmentItem: attachmentItem))
    }
    // MARK: - Builder
    
    var body: some View {
        Button {
            if documentStateViewModel.localURL != nil {
                documentStateViewModel.isReadyToPresent = true
            } else {
                Task {
                    await documentStateViewModel.downloadAndSaveFile(url: url)
                }
            }
        } label: {
            content
                .background(
                    RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                        .stroke(colors.background.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                        .background(
                            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                                .fill(isSenderAgent ? colors.background.surface.default : colors.brand.primary)
                        )
                )
        }
        .frame(width: displayMode.size.width, height: displayMode.size.height)
        .sheet(isPresented: $documentStateViewModel.isReadyToPresent) {
            if let localURL = documentStateViewModel.localURL {
                QuickLookPreview(url: localURL, isPresented: $documentStateViewModel.isReadyToPresent)
            }
        }
    }
}

// MARK: - Subviews

private extension MultipleAttachmentDocumentView {

    @ViewBuilder
    var content: some View {
        switch fileExtension {
        case Constants.pdfFileExtension:
            PDFThumbnailView(
                viewModel: pdfViewModel,
                inSelectionMode: .constant(false),
                width: displayMode.size.width,
                height: displayMode.size.height
            )
        case let .some(fileExtension):
            fileWithExtensionLabelView(fileExtension)
        default:
            AttachmentLoadingView(
                title: localization.loadingDoc,
                width: displayMode.size.width,
                height: displayMode.size.height
            )
        }
    }
    
    func fileWithExtensionLabelView(_ fileExtension: String) -> some View {
        ZStack {
            if documentStateViewModel.isDownloading {
                AttachmentLoadingView(
                    title: localization.loadingDoc,
                    width: displayMode.size.width,
                    height: displayMode.size.height
                )
            } else {
                Asset.Images.blankFile.swiftUIImage
                    .resizable()
                    .foregroundStyle(colors.background.default)
                    .padding(.horizontal, Constants.Padding.blankFileHorizontal)
                    .padding(.vertical, Constants.Padding.blankFileVertical)
                
                Text(fileExtension.uppercased())
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(colors.brand.onPrimary)
                    .truncationMode(.middle)
                    .lineLimit(Constants.Sizing.fileExtensionLineLimit)
                    .padding(.vertical, Constants.Padding.fileExtensionVertical)
                    .padding(.horizontal, Constants.Padding.fileExtensionHorizontal)
                    .background {
                        RoundedRectangle(cornerRadius: Constants.Sizing.fileExtensionContainerCornerRadius)
                            .fill(colors.brand.primary)
                    }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    @Previewable @Environment(\.colorScheme) var scheme
    
    let localization = ChatLocalization()
    let style = ChatStyle()
    
    VStack {
        VStack {
            HStack {
                MultipleAttachmentDocumentView(
                    attachmentItem: MockData.docPreviewItem,
                    isSenderAgent: true,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                MultipleAttachmentDocumentView(
                    attachmentItem: MockData.xlsPreviewItem,
                    isSenderAgent: true,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
            
            HStack {
                MultipleAttachmentDocumentView(
                    attachmentItem: MockData.pptPreviewItem,
                    isSenderAgent: true,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                MultipleAttachmentDocumentView(
                    attachmentItem: MockData.pdfPreviewItem,
                    isSenderAgent: true,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors(for: scheme).background.surface.default)
        )
        
        VStack {
            HStack {
                MultipleAttachmentDocumentView(
                    attachmentItem: MockData.docPreviewItem,
                    isSenderAgent: false,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                MultipleAttachmentDocumentView(
                    attachmentItem: MockData.xlsPreviewItem,
                    isSenderAgent: false,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
            
            HStack {
                MultipleAttachmentDocumentView(
                    attachmentItem: MockData.pptPreviewItem,
                    isSenderAgent: false,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                MultipleAttachmentDocumentView(
                    attachmentItem: MockData.pdfPreviewItem,
                    isSenderAgent: false,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors(for: scheme).brand.primary)
        )
    }
    .environmentObject(style)
}
