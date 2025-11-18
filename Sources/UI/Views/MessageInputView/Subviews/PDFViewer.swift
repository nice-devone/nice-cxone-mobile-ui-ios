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

struct PDFViewer: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let elementsSpacing: CGFloat = 8
        }
        
        enum Padding {
            static let titleTop: CGFloat = 10
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
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
    
    var errorView: some View {
        VStack(spacing: Constants.Spacing.elementsSpacing) {
            Asset.warning
                .font(.largeTitle)
                .foregroundStyle(colors.status.error)
            
            Text(localization.loadingDocError)
                .padding(.top, Constants.Padding.titleTop)
                .foregroundStyle(colors.content.primary)
            
            Button(localization.commonTryAgain, action: viewModel.preparePDFForViewing)
                .foregroundStyle(colors.brand.primary)
        }
        .background(colors.background.default)
    }
}

// MARK: - UIViewRepresentable

private struct PDFKitView: UIViewRepresentable {
    
    // MARK: - Properties
    
    let document: PDFDocument

    // MARK: - Methods
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) { }
}

// MARK: - Previews

#Preview("PDF") {
    PDFViewer(viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem))
       .environmentObject(ChatLocalization())
       .environmentObject(ChatStyle())
}

#Preview("Error") {
    PDFViewer(viewModel: PDFViewModel(attachmentItem: MockData.docPreviewItem))
       .environmentObject(ChatLocalization())
       .environmentObject(ChatStyle())
}
