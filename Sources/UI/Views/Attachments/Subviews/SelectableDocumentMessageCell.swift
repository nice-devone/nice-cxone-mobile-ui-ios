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
import UniformTypeIdentifiers

struct SelectableDocumentMessageCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        static let pdfFileExtension = "pdf"
        
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
    
    @ObservedObject private var pdfViewModel: PDFViewModel
    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel
    @ObservedObject private var documentStateViewModel: DocumentStateViewModel

    @Environment(\.colorScheme) var scheme

    @EnvironmentObject var style: ChatStyle

    @Binding private var inSelectionMode: Bool

    private var fileExtension: String? {
        attachmentItem.fileName.pathExtension?.nilIfEmpty()
            ?? attachmentItem.url.pathExtension.lowercased().nilIfEmpty()
            ?? attachmentItem.mimeType.preferredMimeTypeExtension?.nilIfEmpty()
            ?? nil
    }

    private let attachment: SelectableAttachment
    private let attachmentItem: AttachmentItem
    private let displayMode: AttachmentThumbnailDisplayMode = .large
    
    // MARK: - Init
    
    init(
        attachment: SelectableAttachment,
        item: AttachmentItem,
        attachmentsViewModel: AttachmentsViewModel,
        inSelectionMode: Binding<Bool>,
        alertType: Binding<ChatAlertType?>
    ) {
        self.attachment = attachment
        self.attachmentItem = item
        self.pdfViewModel = PDFViewModel(attachmentItem: item, alertType: alertType)
        self.attachmentsViewModel = attachmentsViewModel
        self.documentStateViewModel = DocumentStateViewModel(alertType: alertType)
        self._inSelectionMode = inSelectionMode
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                if inSelectionMode {
                    let willBeSelected = !attachment.isSelected
                    attachmentsViewModel.selectAttachment(with: attachment.id)

                    A11y.announce(
                        willBeSelected
                            ? A11y.Announcement.AttachmentsView.selected(attachmentItem.fileName)
                            : A11y.Announcement.AttachmentsView.deselected(attachmentItem.fileName)
                    )
                } else {
                    if case .loaded = documentStateViewModel.loadingState {
                        documentStateViewModel.isReadyToPresent = true
                    } else {
                        Task {
                            await documentStateViewModel.downloadAndSaveFile(url: attachmentItem.url)
                        }
                    }
                }
            } label: {
                if fileExtension == Constants.pdfFileExtension {
                    RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                        .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                        .frame(width: displayMode.size.width, height: displayMode.size.height)
                        .background {
                            PDFThumbnailView(
                                viewModel: pdfViewModel,
                                inSelectionMode: $inSelectionMode,
                                width: displayMode.size.width - (2 * StyleGuide.Sizing.Attachment.borderWidth),
                                height: displayMode.size.height - (2 * StyleGuide.Sizing.Attachment.borderWidth)
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius - (2 * StyleGuide.Sizing.Attachment.borderWidth))
                            )
                        }
                } else {
                    documentView
                        .sheet(isPresented: $documentStateViewModel.isReadyToPresent) {
                            if case .loaded(let url) = documentStateViewModel.loadingState {
                                QuickLookPreview(url: url, isPresented: $documentStateViewModel.isReadyToPresent)
                            }
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
        .accessibilityIdentifier(A11y.AttachmentsView.Item.Document.identifier)
        .accessibilityLabel(A11y.AttachmentsView.Item.Document.label(attachmentItem.fileName))
        .accessibilityHint(
            inSelectionMode
                ? A11y.AttachmentsView.Item.Document.Hint.select
                : A11y.AttachmentsView.Item.Document.Hint.browse
        )
        .ifNotNil(cellAccessibilityValue) { view, value in
            view.accessibilityValue(value)
        }
    }

    // MARK: - Private Methods

    private var cellAccessibilityValue: String? {
        if inSelectionMode {
            return attachment.isSelected
                ? A11y.AttachmentsView.Item.Document.Value.selected
                : A11y.AttachmentsView.Item.Document.Value.notSelected
        }
        switch documentStateViewModel.loadingState {
        case .initial, .loading:
            return A11y.AttachmentsView.Item.Value.loading
        case .failed:
            return A11y.AttachmentsView.Item.Value.failed
        case .loaded:
            return nil
        }
    }
}

// MARK: - Subviews

private extension SelectableDocumentMessageCell {
    
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
                        .stroke(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                        .frame(width: displayMode.size.width, height: displayMode.size.height)
                }
                .frame(width: displayMode.size.width, height: displayMode.size.height)
                .ifNotNil(fileExtension) { view, fileExtension in
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
                AttachmentLoadingView(
                    width: displayMode.size.width,
                    height: displayMode.size.height
                )
            } else if case .failed = documentStateViewModel.loadingState {
                AttachmentFailedView(
                    width: displayMode.size.width,
                    height: displayMode.size.height
                )
            }
        }
    }
}

// MARK: - Helper Methods

private extension String {
    
    var pathExtension: String? {
        URL(fileURLWithPath: self).pathExtension.lowercased()
    }

    var preferredMimeTypeExtension: String? {
        guard let utType = UTType(mimeType: self),
              let preferredExtension = utType.preferredFilenameExtension?.lowercased(),
              !preferredExtension.isEmpty
        else {
            return nil
       }

        return preferredExtension
   }
}

// MARK: - Previews

#Preview("Document") {
    let item: AttachmentItem = MockData.docPreviewItem
    let viewModel = AttachmentsViewModel(messageTypes: [.documentPreview(item)])
    
    HStack(spacing: 12) {
        SelectableDocumentMessageCell(
            attachment: MockData.selectableDocumentAttachment,
            item: item,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(true),
            alertType: .constant(nil),
        )
        
        SelectableDocumentMessageCell(
            attachment: MockData.selectableDocumentAttachment,
            item: item,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(false),
            alertType: .constant(nil),
        )
    }
    .environmentObject(ChatStyle())
}

#Preview("PDF") {
    let item: AttachmentItem = MockData.pdfPreviewItem
    let viewModel = AttachmentsViewModel(messageTypes: [.documentPreview(item)])
    
    HStack(spacing: 12) {
        SelectableDocumentMessageCell(
            attachment: MockData.selectablePDFAttachment,
            item: item,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(true),
            alertType: .constant(nil),
        )
        
        SelectableDocumentMessageCell(
            attachment: MockData.selectablePDFAttachment,
            item: item,
            attachmentsViewModel: viewModel,
            inSelectionMode: .constant(false),
            alertType: .constant(nil),
        )
    }
    .environmentObject(ChatStyle())
}
