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

import PDFKit
import SwiftUI

struct PDFThumbnailView: View {
    
    // MARK: - Properties
    
    @Binding private var inSelectionMode: Bool
    
    @State private var isPresentingPDFViewer = false
    
    @StateObject private var viewModel: PDFViewModel
    
    let width: CGFloat
    let height: CGFloat

    // MARK: - Init

    init(viewModel: PDFViewModel, inSelectionMode: Binding<Bool>, width: CGFloat, height: CGFloat) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self._inSelectionMode = inSelectionMode
        self.width = width
        self.height = height
    }

    // MARK: - Builder
    
    var body: some View {
        Group {
            switch viewModel.thumbnailLoadingState {
            case .loaded(let image):
                Button {
                    viewModel.preparePDFForViewing()

                    isPresentingPDFViewer = true
                } label: {
                    Image(uiImage: image) // swiftlint:disable:this accessibility_label_for_image
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: width, height: height)
                .clipped()
                .disabled(inSelectionMode)
            case .failed:
                Button {
                    viewModel.loadThumbnail()
                } label: {
                    AttachmentFailedView(
                        width: width,
                        height: height
                    )
                }
                .disabled(inSelectionMode)
            default:
                AttachmentLoadingView(width: width, height: height)
            }
        }
        .onAppear(perform: viewModel.loadThumbnail)
        .sheet(isPresented: $isPresentingPDFViewer) {
            PDFViewer(viewModel: viewModel)
        }
    }
}

// MARK: - Previews

#Preview("Small") {
    PDFThumbnailView(
        viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem, alertType: .constant(nil)),
        inSelectionMode: .constant(false),
        width: StyleGuide.Sizing.Attachment.smallDimension,
        height: StyleGuide.Sizing.Attachment.smallDimension
    )
    .environmentObject(ChatStyle())
}

#Preview("Regular") {
    PDFThumbnailView(
        viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem, alertType: .constant(nil)),
        inSelectionMode: .constant(false),
        width: StyleGuide.Sizing.Attachment.regularDimension,
        height: StyleGuide.Sizing.Attachment.regularDimension
    )
    .environmentObject(ChatStyle())
}

#Preview("Large") {
    PDFThumbnailView(
        viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem, alertType: .constant(nil)),
        inSelectionMode: .constant(false),
        width: StyleGuide.Sizing.Attachment.largeWidth,
        height: StyleGuide.Sizing.Attachment.largeHeight
    )
    .environmentObject(ChatStyle())
}
