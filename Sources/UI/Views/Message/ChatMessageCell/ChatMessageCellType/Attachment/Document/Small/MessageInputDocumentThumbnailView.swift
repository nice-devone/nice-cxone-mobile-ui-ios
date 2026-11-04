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

struct MessageInputDocumentThumbnailView: View, Themed, LayoutAware {

    // MARK: - Constants
    
    private enum Constants {
        enum Sizing {
            static let fileExtensionCornerRadius: CGFloat = 6
            static let fileExtensionLineLimit = 1
        }
        enum Padding {
            static let fileExtensionVertical: CGFloat = 2
            static let fileExtensionHorizontal: CGFloat = 4
            static let documentThumbnailVertical: CGFloat = 6
            static let documentThumbnailHorizontal: CGFloat = 16
            /// The insets above are tuned for the regular ~79 pt tile. A `smallCompact` tile is only
            /// ~49–55 pt, where 16 pt of horizontal inset per side leaves too little room for the
            /// extension badge and truncates it away.
            static let documentThumbnailVerticalCompact: CGFloat = 3
            static let documentThumbnailHorizontalCompact: CGFloat = 8
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    /// Thumbnail dimensions for the current orientation. Taken from ``LayoutAware`` rather than from
    /// `AttachmentThumbnailDisplayMode.size` directly, so a rotation invalidates this view and the size
    /// is resolved again.
    private var thumbnailSize: CGSize {
        attachmentSize(for: displayMode)
    }

    @Binding private var alertType: ChatAlertType?

    /// Stored rather than hardcoded so the strip can hand down `.smallCompact` — see the note on
    /// `MessageInputImageThumbnailView.displayMode`.
    private let displayMode: AttachmentThumbnailDisplayMode

    let item: AttachmentItem

    private var documentThumbnailVerticalPadding: CGFloat {
        displayMode == .smallCompact
            ? Constants.Padding.documentThumbnailVerticalCompact
            : Constants.Padding.documentThumbnailVertical
    }

    private var documentThumbnailHorizontalPadding: CGFloat {
        displayMode == .smallCompact
            ? Constants.Padding.documentThumbnailHorizontalCompact
            : Constants.Padding.documentThumbnailHorizontal
    }

    // MARK: - Init

    init(item: AttachmentItem, alertType: Binding<ChatAlertType?>, displayMode: AttachmentThumbnailDisplayMode) {
        self.item = item
        self.displayMode = displayMode

        self._alertType = alertType
    }
    
    // MARK: - Builder
    
    @ViewBuilder
    var body: some View {
        if item.isPDF {
            pdfThumbnailView
        } else if let fileExtension = item.fileExtension {
            documentThumbnailView(fileExtension: fileExtension)
        } else {
            AttachmentLoadingView(size: thumbnailSize, drawsBorder: true)
        }
    }
}

// MARK: - Subviews

private extension MessageInputDocumentThumbnailView {

    var pdfThumbnailView: some View {
        PDFThumbnailView(
            viewModel: PDFViewModel(attachmentItem: item, alertType: $alertType),
            inSelectionMode: .constant(false),
            width: thumbnailSize.width,
            height: thumbnailSize.height
        )
        .clippedHitArea(RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
        )
    }
    
    func documentThumbnailView(fileExtension: String) -> some View {
        ZStack {
            Asset.Images.blankFile.swiftUIImage
                .resizable()
                .foregroundStyle(colors.background.surface.variant)
            
            Text(fileExtension.uppercased())
                .font(.caption2)
                .bold()
                .foregroundStyle(colors.brand.onPrimary)
                .truncationMode(.middle)
                .lineLimit(Constants.Sizing.fileExtensionLineLimit)
                .padding(.vertical, Constants.Padding.fileExtensionVertical)
                .padding(.horizontal, Constants.Padding.fileExtensionHorizontal)
                .background {
                    RoundedRectangle(cornerRadius: Constants.Sizing.fileExtensionCornerRadius)
                        .fill(colors.brand.primary)
                }
        }
        .padding(.vertical, documentThumbnailVerticalPadding)
        .padding(.horizontal, documentThumbnailHorizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
        )
        .frame(size: thumbnailSize)
    }
}

// MARK: - Previews

#Preview("Small size") {
    let mimeTypes: [[AttachmentItem]] = [
        [
            MockData.audioItem,
            MockData.videoItem,
            MockData.docPreviewItem
        ],
        [
            MockData.pptPreviewItem,
            MockData.xlsPreviewItem,
            MockData.pdfPreviewItem
        ]
    ]
    
    Grid(horizontalSpacing: 10, verticalSpacing: 10) {
        ForEach(mimeTypes, id: \.self) { section in
            GridRow {
                ForEach(section, id: \.self) { item in
                    MessageInputDocumentThumbnailView(item: item, alertType: .constant(nil), displayMode: .small)
                }
            }
        }
    }
    .environmentObject(ChatStyle())
}

#Preview("Compact size") {
    let mimeTypes: [[AttachmentItem]] = [
        [
            MockData.audioItem,
            MockData.videoItem,
            MockData.docPreviewItem
        ],
        [
            MockData.pptPreviewItem,
            MockData.xlsPreviewItem,
            MockData.pdfPreviewItem
        ]
    ]

    Grid(horizontalSpacing: 10, verticalSpacing: 10) {
        ForEach(mimeTypes, id: \.self) { section in
            GridRow {
                ForEach(section, id: \.self) { item in
                    MessageInputDocumentThumbnailView(item: item, alertType: .constant(nil), displayMode: .smallCompact)
                }
            }
        }
    }
    .environmentObject(ChatStyle())
}
