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

struct PDFThumbnailView<ClipShape: InsettableShape>: View {

    // MARK: - Properties

    @Binding private var inSelectionMode: Bool

    @Environment(\.presentAttachmentPreview) private var presentAttachmentPreview

    /// Owned here, and only here: a holder that also renders non-PDF documents must not build one, since
    /// `PDFViewModel.init` starts loading the file and rendering it as a PDF — which fails for a `.docx`,
    /// `.xlsx` or `.mp3` and raises a generic error alert.
    @StateObject private var viewModel: PDFViewModel

    let width: CGFloat
    let height: CGFloat

    /// Bubble-matched shape for cells grouped in a conversation (see `MessageGroupPosition.attachmentClipShape`);
    /// defaults to the plain attachment corner radius for standalone/gallery/composer contexts.
    /// Only the failed-loading fallback below actually needs this — see its call site.
    let clipShape: ClipShape

    // MARK: - Init

    /// - Parameter viewModel: Evaluated once, when the view's identity is first created — not on every
    ///   re-render of the caller.
    init(
        viewModel: @autoclosure @escaping () -> PDFViewModel,
        inSelectionMode: Binding<Bool>,
        width: CGFloat,
        height: CGFloat,
        clipShape: ClipShape = RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self._inSelectionMode = inSelectionMode
        self.width = width
        self.height = height
        self.clipShape = clipShape
    }

    // MARK: - Builder
    
    var body: some View {
        Group {
            switch viewModel.thumbnailLoadingState {
            case .loaded(let image):
                Button {
                    presentAttachmentPreview(.pdf(viewModel.attachmentItem))
                } label: {
                    Image(uiImage: image) // swiftlint:disable:this accessibility_label_for_image
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: width, height: height)
                .clippedHitArea(Rectangle())
                .disabled(inSelectionMode)
            case .failed:
                Button {
                    viewModel.loadThumbnail()
                } label: {
                    // `clipShape`: unlike `AttachmentLoadingView` below, `AttachmentFailedView`'s
                    // clip shape also drives an unconditional background fill, not just the
                    // border stroke — passing the wrong shape would fill a plain uniform corner
                    // while the caller's border (see `standalonePDF`) strokes a tighter
                    // grouped-position one, leaving an unpainted gap between the two arcs.
                    AttachmentFailedView(
                        width: width,
                        height: height,
                        clipShape: clipShape
                    )
                }
                .disabled(inSelectionMode)
            default:
                AttachmentLoadingView(width: width, height: height)
            }
        }
        .onAppear(perform: viewModel.loadThumbnail)
    }
}

// Previews demonstrate each fixed size deliberately and never rotate, so they read the
// orientation-derived constants directly rather than through `LayoutAware`.
// swiftlint:disable orientation_outside_layout_context
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
// swiftlint:enable orientation_outside_layout_context
