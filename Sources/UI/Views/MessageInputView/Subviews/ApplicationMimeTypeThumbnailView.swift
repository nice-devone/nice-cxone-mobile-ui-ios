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

struct ApplicationMimeTypeThumbnailView: View, Themed {

    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme

    @StateObject private var pdfViewModel: PDFViewModel

    @Binding private var alertType: ChatAlertType?
    
    let width: CGFloat
    let height: CGFloat
    let message: ChatMessage?
    let item: AttachmentItem
    
    // MARK: - Init
    
    init(item: AttachmentItem, message: ChatMessage? = nil, width: CGFloat, height: CGFloat, alertType: Binding<ChatAlertType?>) {
        self.width = width
        self.height = height
        self.message = message
        self.item = item
        self._alertType = alertType
        
        _pdfViewModel = StateObject(wrappedValue: PDFViewModel(attachmentItem: item))
    }
    
    // MARK: - Builder
    
    var body: some View {
        let fileExtension = UTType(mimeType: item.mimeType)?.preferredFilenameExtension
        
        switch fileExtension {
        case "pdf":
            PDFThumbnailView(
                viewModel: pdfViewModel,
                inSelectionMode: .constant(false),
                width: width,
                height: height
            )
            .ifNotNil(message, item) { view, message, item in
                view.shareable(message, attachments: [item], spacerLength: .zero)
            }
        case let .some(ext):
            ApplicationDocumentThumbnailView(
                fileExtension: ext,
                width: width,
                height: height,
                url: item.url,
                alertType: $alertType,
                localization: localization
            )
            .ifNotNil(message, item) { view, message, item in
                view.shareable(message, attachments: [item], spacerLength: .zero)
            }
        default:
            AttachmentLoadingView(title: localization.loadingDoc)
                .frame(width: width, height: height)
        }
    }
}

// MARK: - Previews

#Preview {
    let mimeTypes: [AttachmentItem] = [
        MockData.audioItem,
        MockData.videoItem,
        MockData.docPreviewItem,
        MockData.pptPreviewItem,
        MockData.xlsPreviewItem,
        MockData.pdfPreviewItem
    ]
    
    List(mimeTypes, id: \.self) { item in
        ApplicationMimeTypeThumbnailView(
            item: item,
            width: StyleGuide.Attachment.regularDimension,
            height: StyleGuide.Attachment.regularDimension,
            alertType: .constant(nil)
        )
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
