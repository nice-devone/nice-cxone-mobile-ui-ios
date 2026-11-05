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
    
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @ObservedObject var viewModel: PDFViewModel

    @SwiftUI.Environment(\.dismiss) private var dismiss

    // MARK: - Builder

    var body: some View {
        documentView
            // Self-sufficient: the preview host builds this view model on presentation, so no caller is
            // left to kick the load off. Guarded internally against a document that is already loaded.
            .onAppear(perform: viewModel.preparePDFForViewing)
            // The viewer is presented as a full-screen cover, which has no grabber to swipe away, so
            // it has to carry its own way out. Mirrors `ImageViewer` / `VideoViewer`.
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Asset.close
                            .accessibilityHidden(true)
                    }
                    .accessibilityIdentifier(A11y.DocumentViewer.ButtonClose.identifier)
                    .accessibilityLabel(A11y.DocumentViewer.ButtonClose.label)
                    .accessibilityHint(A11y.DocumentViewer.ButtonClose.hint)
                }
            }
            .tint(colors.brand.primary)
    }
}

// MARK: - Subviews

private extension PDFViewer {

    @ViewBuilder
    var documentView: some View {
        switch viewModel.documentLoadingState {
        case .loaded(let document):
            PDFKitView(document: document)
        case .failed:
            errorView
        default:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: colors.content.primary))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colors.background.default)
        }
    }

    var errorView: some View {
        VStack(spacing: Constants.Spacing.elementsSpacing) {
            Asset.warning
                .font(.largeTitle)
                .foregroundStyle(colors.status.error)
            
            Text(L10n.Chat.Attachments.Loading.documentError)
                .padding(.top, Constants.Padding.titleTop)
                .foregroundStyle(colors.content.primary)
            
            Button(L10n.Common.tryAgain, action: viewModel.preparePDFForViewing)
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
    PDFViewer(viewModel: PDFViewModel(attachmentItem: MockData.pdfPreviewItem, alertType: .constant(nil)))
       .environmentObject(ChatStyle())
}

#Preview("Error") {
    PDFViewer(viewModel: PDFViewModel(attachmentItem: MockData.docPreviewItem, alertType: .constant(nil)))
       .environmentObject(ChatStyle())
}
