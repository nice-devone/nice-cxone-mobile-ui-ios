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

import SwiftUI

struct AttachmentGalleryDocumentThumbnailView: View, Themed, LayoutAware {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let fileExtensionCornerRadius: CGFloat = 8
            static let fileExtensionLineLimit = 1
        }
        
        enum Padding {
            static let selectableCircleTopTrailing: CGFloat = 10
            static let fileExtensionTextVertical: CGFloat = 4
            static let fileExtensionTextHorizontal: CGFloat = 8
            static let documentBlankHorizontal: CGFloat = 22
            static let documentBlankVertical: CGFloat = 26
        }
    }
    
    // MARK: - Properties
    
    // `@StateObject`: `DocumentStateViewModel.init` starts a download, so an `@ObservedObject`
    // recreated on every re-render would re-fire it. A PDF's `PDFViewModel` is owned by
    // `PDFThumbnailView`, so none is built for a non-PDF document.
    @StateObject private var documentStateViewModel: DocumentStateViewModel

    @ObservedObject private var attachmentGalleryViewModel: AttachmentGalleryViewModel

    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    @Environment(\.presentAttachmentPreview) private var presentAttachmentPreview

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `AttachmentThumbnailDisplayMode.size` directly, so a rotation invalidates this view and the size
    /// is resolved again.
    private var thumbnailSize: CGSize {
        attachmentSize(for: displayMode)
    }

    @EnvironmentObject var style: ChatStyle

    @Binding private var inSelectionMode: Bool
    @Binding private var alertType: ChatAlertType?

    private let attachment: SelectableAttachment
    private let attachmentItem: AttachmentItem
    private let displayMode: AttachmentThumbnailDisplayMode = .large
    
    // MARK: - Init
    
    init(
        attachment: SelectableAttachment,
        item: AttachmentItem,
        attachmentGalleryViewModel: AttachmentGalleryViewModel,
        inSelectionMode: Binding<Bool>,
        alertType: Binding<ChatAlertType?>
    ) {
        self.attachment = attachment
        self.attachmentItem = item
        self.attachmentGalleryViewModel = attachmentGalleryViewModel
        // Wire the same warm-cache path as `DocumentCellDocumentThumbnailView` (via
        // `@StateObject` + url/fileName), so an already-downloaded document resolves from
        // disk instead of re-downloading (and erroring offline) when opened from the
        // attachments overview. PDFs are rendered/cached by `PDFThumbnailView`'s view model, so they pass
        // `nil` here to avoid downloading the same file twice.
        self._documentStateViewModel = StateObject(
            wrappedValue: DocumentStateViewModel(
                alertType: alertType,
                url: item.isPDF ? nil : item.url,
                fileName: item.isPDF ? nil : item.fileName
            )
        )
        self._inSelectionMode = inSelectionMode
        self._alertType = alertType
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                if inSelectionMode {
                    attachmentGalleryViewModel.toggleSelection(of: attachment, fileName: attachmentItem.fileName)
                } else if !attachmentItem.isPDF {
                    // Only non-PDF documents go through `DocumentStateViewModel`'s warm-cache
                    // + QuickLook path. PDFs preview via `PDFThumbnailView`'s own viewer, and
                    // their `DocumentStateViewModel` is intentionally created with nil
                    // url/fileName — routing a PDF tap through `handleTap` would trigger a
                    // redundant download (and a possible error alert) with no sheet to present.
                    //
                    // `handleTap` resolves loaded/loading/initial consistently: it presents
                    // immediately when cached, records intent so an in-flight warm-cache
                    // pre-fetch still presents on completion, and downloads on demand
                    // otherwise — matching `DocumentCellDocumentThumbnailView`.
                    documentStateViewModel.handleTap(url: attachmentItem.url)
                }
            } label: {
                if attachmentItem.isPDF {
                    RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                        .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                        .frame(size: thumbnailSize)
                        .background {
                            PDFThumbnailView(
                                viewModel: PDFViewModel(attachmentItem: attachmentItem, alertType: $alertType),
                                inSelectionMode: $inSelectionMode,
                                width: innerThumbnailSize.width,
                                height: innerThumbnailSize.height
                            )
                            .clippedHitArea(
                                RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.innerCornerRadius)
                            )
                        }
                } else {
                    documentView
                        .onAppear(perform: presentPendingDocument)
                        .onChange(of: documentStateViewModel.isReadyToPresent) { _ in
                            presentPendingDocument()
                        }
                }
            }
            .disabled(inSelectionMode)

            if inSelectionMode {
                SelectableCircle(isSelected: attachment.isSelected)
                    .padding([.top, .trailing], Constants.Padding.selectableCircleTopTrailing)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.AttachmentGalleryView.Item.Document.identifier)
        .accessibilityLabel(A11y.AttachmentGalleryView.Item.Document.label(attachmentItem.fileName))
        .accessibilityHint(
            inSelectionMode
                ? A11y.AttachmentGalleryView.Item.Document.Hint.select
                : A11y.AttachmentGalleryView.Item.Document.Hint.browse
        )
        .ifNotNil(cellAccessibilityValue) { view, value in
            view.accessibilityValue(value)
        }
    }

    // MARK: - Private Methods

    private var cellAccessibilityValue: String? {
        if inSelectionMode {
            return attachment.isSelected
                ? A11y.AttachmentGalleryView.Item.Document.Value.selected
                : A11y.AttachmentGalleryView.Item.Document.Value.notSelected
        }
        switch documentStateViewModel.loadingState {
        case .initial, .loading:
            return A11y.AttachmentGalleryView.Item.Value.loading
        case .failed:
            return A11y.AttachmentGalleryView.Item.Value.failed
        case .loaded:
            return nil
        }
    }
}

// MARK: - Helpers

private extension AttachmentGalleryDocumentThumbnailView {

    /// The thumbnail size minus the attachment border, for content drawn inside it.
    var innerThumbnailSize: CGSize {
        StyleGuide.Sizing.Attachment.innerSize(for: thumbnailSize)
    }

    /// Hands a document the view model has marked ready to the preview host.
    ///
    /// Called from `onAppear` as well as `onChange`, and clears the flag unconditionally. The flag lives
    /// on the view model, which outlives the cell's realization in a lazy container: one set while the
    /// cell was off screen would never reach `onChange` — and `handleTap` re-assigning the same `true`
    /// is not a change either — leaving the cell permanently unable to present.
    func presentPendingDocument() {
        guard documentStateViewModel.isReadyToPresent else {
            return
        }

        documentStateViewModel.isReadyToPresent = false

        guard case .loaded(let url) = documentStateViewModel.loadingState else {
            return
        }

        presentAttachmentPreview(.document(url))
    }
}

// MARK: - Subviews

private extension AttachmentGalleryDocumentThumbnailView {

    @ViewBuilder
    var documentView: some View {
        ZStack {
            Asset.Images.blankFile.swiftUIImage
                .resizable()
                .foregroundStyle(colors.background.surface.variant)
                .padding(.horizontal, Constants.Padding.documentBlankHorizontal)
                .padding(.vertical, Constants.Padding.documentBlankVertical)
                .background {
                    RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                        .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                        .frame(size: thumbnailSize)
                }
                .frame(size: thumbnailSize)
                .ifNotNil(attachmentItem.fileExtension) { view, fileExtension in
                    view.overlay {
                        Text(fileExtension.uppercased())
                            .font(.callout)
                            .bold()
                            .foregroundStyle(colors.brand.onPrimary)
                            .truncationMode(.middle)
                            .lineLimit(Constants.Sizing.fileExtensionLineLimit)
                            .padding(.vertical, Constants.Padding.fileExtensionTextVertical)
                            .padding(.horizontal, Constants.Padding.fileExtensionTextHorizontal)
                            .background {
                                RoundedRectangle(cornerRadius: Constants.Sizing.fileExtensionCornerRadius)
                                    .fill(colors.brand.primary)
                            }
                    }
                }

            if case .loading = documentStateViewModel.loadingState {
                AttachmentLoadingView(size: thumbnailSize)
            } else if case .failed = documentStateViewModel.loadingState {
                AttachmentFailedView(size: thumbnailSize, drawsBorder: true)
            }
        }
    }
}

// MARK: - Previews

#Preview("Document") {
    let item: AttachmentItem = MockData.docPreviewItem
    let viewModel = AttachmentGalleryViewModel(messageTypes: [.documentPreview(item)])
    
    HStack(spacing: 12) {
        AttachmentGalleryDocumentThumbnailView(
            attachment: MockData.selectableDocumentAttachment,
            item: item,
            attachmentGalleryViewModel: viewModel,
            inSelectionMode: .constant(true),
            alertType: .constant(nil),
        )
        
        AttachmentGalleryDocumentThumbnailView(
            attachment: MockData.selectableDocumentAttachment,
            item: item,
            attachmentGalleryViewModel: viewModel,
            inSelectionMode: .constant(false),
            alertType: .constant(nil),
        )
    }
    .environmentObject(ChatStyle())
}

#Preview("PDF") {
    let item: AttachmentItem = MockData.pdfPreviewItem
    let viewModel = AttachmentGalleryViewModel(messageTypes: [.documentPreview(item)])
    
    HStack(spacing: 12) {
        AttachmentGalleryDocumentThumbnailView(
            attachment: MockData.selectablePDFAttachment,
            item: item,
            attachmentGalleryViewModel: viewModel,
            inSelectionMode: .constant(true),
            alertType: .constant(nil),
        )
        
        AttachmentGalleryDocumentThumbnailView(
            attachment: MockData.selectablePDFAttachment,
            item: item,
            attachmentGalleryViewModel: viewModel,
            inSelectionMode: .constant(false),
            alertType: .constant(nil),
        )
    }
    .environmentObject(ChatStyle())
}
