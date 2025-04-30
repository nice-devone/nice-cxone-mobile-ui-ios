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

import PDFKit
import SwiftUI

struct PDFThumbnailView: View {
    
    // MARK: - Properties
    
    @Binding private var inSelectionMode: Bool
    
    @State private var isPresentingPDFViewer = false
    
    @StateObject private var viewModel: PDFViewModel

    @EnvironmentObject private var localization: ChatLocalization
    
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
            if let thumbnail = viewModel.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: width, height: height)
                    .cornerRadius(StyleGuide.Attachment.cornerRadius, corners: .allCorners)
                    .if(!inSelectionMode) { view in
                        view.onTapGesture {
                            viewModel.preparePDFForViewing()
                            
                            isPresentingPDFViewer = true
                        }
                    }
            } else {
                AttachmentLoadingView(title: localization.loadingDoc)
                    .frame(
                        width: width,
                        height: height
                    )
            }
        }
        .onAppear(perform: viewModel.loadThumbnail)
        .sheet(isPresented: $isPresentingPDFViewer) {
            if viewModel.isLoading {
                AttachmentLoadingView(title: localization.loadingDoc)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.pdfDocument != nil {
                PDFViewer(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Previews

#Preview("Regular") {
    PDFThumbnailView(viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem), inSelectionMode: .constant(false), width: 72, height: 72)
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}

#Preview("Large") {
    PDFThumbnailView(viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem), inSelectionMode: .constant(false), width: 112, height: 112)
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}

#Preview("Xtra Large") {
    PDFThumbnailView(viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem), inSelectionMode: .constant(false), width: 242, height: 319)
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
