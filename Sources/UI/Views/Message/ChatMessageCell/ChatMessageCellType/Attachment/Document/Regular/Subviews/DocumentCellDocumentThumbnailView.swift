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

// MARK: - Constants

/// Top-level, not nested in `DocumentCellDocumentThumbnailView`: Swift disallows static
/// stored properties in types nested inside a generic type.
private enum Constants {
    static let accessibilityIdentifier = "document"

    enum Sizing {
        static let fileExtensionCornerRadius: CGFloat = 6
        static let fileExtensionLineLimit = 1
    }

    enum Padding {
        static let fileExtensionTextVertical: CGFloat = 4
        static let fileExtensionTextHorizontal: CGFloat = 8
        static let fileExtensionContainerVertical: CGFloat = 12
        static let fileExtensionContainerHorizontal: CGFloat = 22
    }
}

struct DocumentCellDocumentThumbnailView<ClipShape: InsettableShape>: View, Themed, LayoutAware {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    @Environment(\.presentAttachmentPreview) private var presentAttachmentPreview

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `AttachmentThumbnailDisplayMode.size` directly, so a rotation invalidates this view and the size
    /// is resolved again.
    private var thumbnailSize: CGSize {
        attachmentSize(for: displayMode)
    }

    @StateObject private var viewModel: DocumentStateViewModel

    let fileExtension: String
    let url: URL

    private let displayMode: AttachmentThumbnailDisplayMode = .regular

    /// Bubble-matched shape for cells grouped in a conversation (see `MessageGroupPosition.attachmentClipShape`);
    /// defaults to the plain attachment corner radius for standalone/multi-container contexts.
    /// Only the failed-loading fallback below actually needs this — see its call site.
    let clipShape: ClipShape

    // MARK: - Init

    init(
        fileExtension: String,
        url: URL,
        fileName: String? = nil,
        alertType: Binding<ChatAlertType?>,
        clipShape: ClipShape = RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
    ) {
        // `@StateObject` (created once and owned by the view) rather than a fresh
        // instance on every re-init — the view model now starts a background download
        // in `init`, so recreating it per re-render would re-fire duplicate downloads
        // and drop in-flight tap intent. Mirrors `ImageMessageCell` / `VideoMessageCell`.
        _viewModel = StateObject(wrappedValue: DocumentStateViewModel(alertType: alertType, url: url, fileName: fileName))
        self.fileExtension = fileExtension
        self.url = url
        self.clipShape = clipShape
    }
    
    // MARK: - Builder
    
    @ViewBuilder
    var body: some View {
        Button {
            viewModel.handleTap(url: url)
        } label: {
            buttonLabel
        }
        .onAppear(perform: presentPendingDocument)
        .onChange(of: viewModel.isReadyToPresent) { _ in
            presentPendingDocument()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.Attachment.identifier(type: Constants.accessibilityIdentifier))
        .accessibilityLabel(A11y.Conversation.MessageCell.Attachment.Document.label(url.lastPathComponent))
        .accessibilityHint(A11y.Conversation.MessageCell.Attachment.Document.hint)
    }
}

// MARK: - Subviews

private extension DocumentCellDocumentThumbnailView {
    
    var buttonLabel: some View {
        ZStack {
            switch viewModel.loadingState {
            case .initial, .loading:
                AttachmentLoadingView(size: thumbnailSize)
            case .loaded:
                Asset.Images.blankFile.swiftUIImage
                    .resizable()
                    .foregroundStyle(colors.background.default)
                
                Text(fileExtension.uppercased())
                    .font(.caption2)
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
            case .failed:
                // `clipShape`: unlike `AttachmentLoadingView` above, `AttachmentFailedView`'s
                // clip shape also drives an unconditional background fill, not just the
                // border stroke — passing the wrong shape would fill a plain uniform corner
                // while the caller's border (see `standaloneDocument`) strokes a tighter
                // grouped-position one, leaving an unpainted gap between the two arcs.
                AttachmentFailedView(size: thumbnailSize, clipShape: clipShape)
            }
        }
        .padding(.vertical, Constants.Padding.fileExtensionContainerVertical)
        .padding(.horizontal, Constants.Padding.fileExtensionContainerHorizontal)
        .frame(size: thumbnailSize)
    }
}

// MARK: - Private Methods

private extension DocumentCellDocumentThumbnailView {

    /// Hands a document the view model has marked ready to the preview host.
    ///
    /// Called from `onAppear` as well as `onChange`, and clears the flag unconditionally. The flag lives
    /// on the view model, which outlives the cell's realization in a lazy container: one set while the
    /// cell was off screen would never reach `onChange` — and `handleTap` re-assigning the same `true`
    /// is not a change either — leaving the cell permanently unable to present.
    func presentPendingDocument() {
        guard viewModel.isReadyToPresent else {
            return
        }

        viewModel.isReadyToPresent = false

        guard case .loaded(let url) = viewModel.loadingState else {
            return
        }

        presentAttachmentPreview(.document(url))
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview("Single") {
    @Previewable @Environment(\.colorScheme) var scheme

    let style = ChatStyle()

    VStack {
        DocumentCellDocumentThumbnailView(
            fileExtension: "ppt",
            url: MockData.docPreviewURL,
            alertType: .constant(nil)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.colors(for: scheme).background.surface.default)
        )
        .shareable(MockData.documentMessage(user: MockData.agent), attachments: [])
        
        DocumentCellDocumentThumbnailView(
            fileExtension: "ppt",
            url: MockData.docPreviewURL,
            alertType: .constant(nil)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.colors(for: scheme).brand.primary)
        )
        .shareable(MockData.documentMessage(user: MockData.customer), attachments: [])
    }
    .padding(.horizontal, 12)
    .environmentObject(style)
}

@available(iOS 17, *)
#Preview("Multiple attachments container") {
    @Previewable @Environment(\.colorScheme) var scheme
    
    let style = ChatStyle()
    
    VStack {
        HStack {
            DocumentCellDocumentThumbnailView(
                fileExtension: "ppt",
                url: MockData.docPreviewURL,
                alertType: .constant(nil)
            )
            
            DocumentCellDocumentThumbnailView(
                fileExtension: "ppt",
                url: MockData.docPreviewURL,
                alertType: .constant(nil)
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.colors(for: scheme).brand.primary)
        )
        
        HStack {
            DocumentCellDocumentThumbnailView(
                fileExtension: "ppt",
                url: MockData.docPreviewURL,
                alertType: .constant(nil)
            )
            
            DocumentCellDocumentThumbnailView(
                fileExtension: "ppt",
                url: MockData.docPreviewURL,
                alertType: .constant(nil)
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.colors(for: scheme).background.surface.default)
        )
    }
    .environmentObject(style)
}
