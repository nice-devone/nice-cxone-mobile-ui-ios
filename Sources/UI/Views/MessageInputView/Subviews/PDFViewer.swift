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

// This struct wraps PDFView for use in SwiftUI
struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct PDFViewer: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var localization: ChatLocalization

    @ObservedObject var viewModel: PDFViewModel
    
    // MARK: - Builder

    var body: some View {
        if let pdfDocument = viewModel.pdfDocument {
            PDFKitView(document: pdfDocument)
        } else {
            errorView
        }
    }
}

// MARK: - SubViews

private extension PDFViewer {
    
    private var errorView: some View {
        VStack {
            Asset.warning
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(localization.loadingDocError)
                .padding(.top)
            Button(localization.commonTryAgain) {
                viewModel.preparePDFForViewing()
            }
            .padding(.top)
        }
    }
}

// MARK: - Previews

struct PDFViewerPreview: PreviewProvider {
    
    static var previews: some View {

        PDFViewer(viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem))
           .environmentObject(ChatLocalization())
            .previewDisplayName("Light Mode")
        
        PDFViewer(viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem))
            .environmentObject(ChatLocalization())
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
}
