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
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @StateObject private var documentStateViewModel: DocumentStateViewModel
    
    @StateObject private var pdfViewModel: PDFViewModel
    
    static private let labelCornerRadius: CGFloat = 6
    static private let fileExtensionContainerLineWidth: CGFloat = 1
    static private let minimumScaleFactor: CGFloat = 0.5
    static private let lineLimit = 1
    static private let fileExtensionVerticalPadding: CGFloat = 6
    static private let fileExtensionHorizontalPadding: CGFloat = 6
    static private let fileExtensionContainerVerticalPadding: CGFloat = 34
    static private let fileExtensionContainerHorizontalPadding: CGFloat = 16
    
    let fileExtension: String?
    let url: URL
    let isSenderAgent: Bool
    let width: CGFloat
    let height: CGFloat
    let localization: ChatLocalization
    
    // MARK: - Init
    
    init(
        attachmentItem: AttachmentItem,
        isSenderAgent: Bool,
        width: CGFloat,
        height: CGFloat,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        self.fileExtension = UTType(mimeType: attachmentItem.mimeType)?.preferredFilenameExtension
        self.url = attachmentItem.url
        self.isSenderAgent = isSenderAgent
        self.width = width
        self.height = height
        self.localization = localization
        
        self._documentStateViewModel = StateObject(wrappedValue: DocumentStateViewModel(alertType: alertType, localization: localization))
        self._pdfViewModel = StateObject(wrappedValue: PDFViewModel(attachmentItem: attachmentItem))
    }
    // MARK: - Builder
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: StyleGuide.Attachment.cornerRadius)
                    .stroke(
                        colors.customizable.background,
                        lineWidth: Self.fileExtensionContainerLineWidth
                    )
                    .background(
                        RoundedRectangle(cornerRadius: StyleGuide.Attachment.cornerRadius)
                            .fill(isSenderAgent ? colors.customizable.agentBackground : colors.customizable.customerBackground)
                    )
            )
            .frame(width: width, height: height)
            .onTapGesture {
                if documentStateViewModel.localURL != nil {
                    documentStateViewModel.isReadyToPresent = true
                } else {
                    Task {
                        await documentStateViewModel.downloadAndSaveFile(url: url)
                    }
                }
            }
            .sheet(isPresented: $documentStateViewModel.isReadyToPresent) {
                if let localURL = documentStateViewModel.localURL {
                    QuickLookPreview(url: localURL, isPresented: $documentStateViewModel.isReadyToPresent)
                }
            }
            .alert(isPresented: $documentStateViewModel.showError) {
                Alert(
                    title: Text(localization.commonError),
                    message: Text(localization.downloadingDocumentFailed),
                    dismissButton: .default(Text(localization.commonOk))
                )
            }
    }
}

// MARK: - Subviews

private extension MultipleAttachmentDocumentView {

    @ViewBuilder
    var content: some View {
        switch fileExtension {
        case "pdf":
            PDFThumbnailView(viewModel: pdfViewModel, inSelectionMode: .constant(false), width: width, height: height)
        case let .some(fileExtension):
            fileWithExtensionLabelView(fileExtension)
        default:
            AttachmentLoadingView(title: localization.loadingDoc)
                .frame(width: width, height: height)
        }
    }
    
    func fileWithExtensionLabelView(_ fileExtension: String) -> some View {
        ZStack {
            if documentStateViewModel.isDownloading {
                AttachmentLoadingView(title: localization.loadingDoc)
            } else {
                Asset.Images.blankFile.swiftUIImage
                    .resizable()
                    .foregroundStyle(colors.foreground.staticLight)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                
                Text(fileExtension.uppercased())
                    .font(.caption2)
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
                    .padding(.vertical, Self.fileExtensionContainerVerticalPadding)
                    .padding(.horizontal, Self.fileExtensionContainerHorizontalPadding)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let localization = ChatLocalization()
    let style = ChatStyle()
    
    VStack {
        MultipleAttachmentDocumentView(
            attachmentItem: MockData.docPreviewItem,
            isSenderAgent: true,
            width: StyleGuide.Attachment.largeDimension,
            height: StyleGuide.Attachment.largeDimension,
            alertType: .constant(nil),
            localization: localization
        )
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors.light.customizable.agentBackground)
        )
        
        MultipleAttachmentDocumentView(
            attachmentItem: MockData.docPreviewItem,
            isSenderAgent: true,
            width: StyleGuide.Attachment.largeDimension,
            height: StyleGuide.Attachment.largeDimension,
            alertType: .constant(nil),
            localization: localization
        )
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(style.colors.light.customizable.customerBackground)
        )
    }
    .environmentObject(style)
}
