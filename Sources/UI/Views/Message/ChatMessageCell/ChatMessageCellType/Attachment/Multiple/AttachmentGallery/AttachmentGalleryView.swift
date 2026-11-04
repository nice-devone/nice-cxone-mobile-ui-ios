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

struct AttachmentGalleryView: View, Themed, LayoutAware {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let gridColumnCount: Int = 2
            static let fileNameLineLimit = 2
            static let bottomSectionTextLineLimit = 1
        }
        
        enum Spacing {
            static let gridItem: CGFloat = 20
            static let gridItemNameVertical: CGFloat = 4
            static let elementsVertical: CGFloat = 0
            static let bottomButtonsHorizontal: CGFloat = 48
            static let textAndShareHorizontal: CGFloat = 16
        }
        
        enum Padding {
            static let gridTop: CGFloat = 24
            static let gridHorizontal: CGFloat = 20
            static let bottomButtons: CGFloat = 4
        }
    }
    
    // MARK: - Properties

    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout
    
    @EnvironmentObject var style: ChatStyle

    // `@StateObject`, not `@ObservedObject`: this view creates its own view model, and that view
    // model holds the overview's selection state (`attachments[].isSelected`, `inSelectionMode`).
    // The view is presented from `MultipleAttachmentsContainer`'s `.sheet`, whose content closure
    // is re-evaluated whenever the parent re-renders — with `@ObservedObject` that built a fresh
    // view model and silently reset the user's selection mid-session.
    @StateObject private var viewModel: AttachmentGalleryViewModel

    @Binding private var alertType: ChatAlertType?

    /// Computed, not a stored `let`: the column width is orientation-derived, and a stored property is
    /// resolved once when the gallery is presented — a rotation while it is open would not reach it.
    private var config: [GridItem] {
        Array(
            repeating: GridItem(
                .adaptive(minimum: attachmentSize(for: .large).width),
                spacing: Constants.Spacing.gridItem,
                alignment: .top
            ),
            count: Constants.Sizing.gridColumnCount
        )
    }

    private let message: ChatMessage

    // MARK: - Init

    init(message: ChatMessage, messageTypes: [ChatMessageType], alertType: Binding<ChatAlertType?>) {
        self.message = message
        self._viewModel = StateObject(wrappedValue: AttachmentGalleryViewModel(messageTypes: messageTypes))
        self._alertType = alertType
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: Constants.Spacing.elementsVertical) {
            gridView
            
            ColoredDivider(colors.border.default)
                .ignoresSafeArea(.all)
                .accessibilityHidden(true)
            
            bottomButtonsView
        }
        .background(colors.background.default)
        // Its own host, despite `ChatView` having one: the gallery is presented in a sheet, and a cover
        // put up from beneath a sheet does not render above it. Hosted above the `LazyVGrid` so a preview
        // survives its cell being recycled.
        .attachmentPreviewHost(alertType: $alertType)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(L10n.Common.attachments)
                    .font(.headline)
                    .foregroundStyle(colors.content.primary)
                    .accessibilityIdentifier(A11y.AttachmentGalleryView.Title.identifier)
                    .accessibilityAddTraits(.isHeader)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.inSelectionMode ? L10n.Common.cancel : L10n.Common.select) {
                    viewModel.inSelectionMode.toggle()

                    A11y.announce(
                        viewModel.inSelectionMode
                            ? A11y.Announcement.AttachmentGalleryView.SelectionMode.enabled
                            : A11y.Announcement.AttachmentGalleryView.SelectionMode.disabled
                    )
                }
                .tint(colors.brand.primary)
                .accessibilityIdentifier(
                    viewModel.inSelectionMode
                        ? A11y.AttachmentGalleryView.ButtonCancel.identifier
                        : A11y.AttachmentGalleryView.ButtonSelect.identifier
                )
                .accessibilityLabel(
                    viewModel.inSelectionMode
                        ? A11y.AttachmentGalleryView.ButtonCancel.label
                        : A11y.AttachmentGalleryView.ButtonSelect.label
                )
                .accessibilityHint(
                    viewModel.inSelectionMode
                        ? A11y.AttachmentGalleryView.ButtonCancel.hint
                        : A11y.AttachmentGalleryView.ButtonSelect.hint
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews

private extension AttachmentGalleryView {

    var gridView: some View {
        ScrollView(showsIndicators: true) {
            LazyVGrid(columns: config) {
                // Identify by the attachment's stable `id`, not by `\.self`: `SelectableAttachment`
                // hashes its mutable `isSelected`, so `\.self` changed a cell's identity on every
                // selection toggle. The cells own `@StateObject` view models that kick off a
                // download on init, so a churning identity re-fired those downloads and could hand
                // a reused slot the previous attachment's view model. The `id` is assigned once in
                // `SelectableAttachmentMapper` and never changes, keeping identity 1:1 with the
                // attachment while selection updates still re-render the cell.
                ForEach(viewModel.attachments, id: \.id) { selectableAttachment in
                    VStack(spacing: Constants.Spacing.gridItemNameVertical) {
                        switch selectableAttachment.messageType {
                        case .image(let entity):
                            AttachmentGalleryImageThumbnailView(
                                item: selectableAttachment,
                                attachmentGalleryViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode,
                                alertType: $alertType
                            )
                            
                            Text(entity.fileName)
                                .foregroundStyle(colors.content.primary)
                        case .video(let entity):
                            AttachmentGalleryVideoThumbnailView(
                                item: selectableAttachment,
                                attachmentGalleryViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode,
                                alertType: $alertType
                            )
                            
                            Text(entity.fileName)
                                .foregroundStyle(colors.content.primary)
                        case .documentPreview(let entity):
                            AttachmentGalleryDocumentThumbnailView(
                                attachment: selectableAttachment,
                                item: entity,
                                attachmentGalleryViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode,
                                alertType: $alertType
                            )
                            
                            Text(entity.fileName)
                                .foregroundStyle(colors.content.primary)
                        default:
                            EmptyView()
                                .onAppear {
                                    LogManager.warning("Unsupported attachment type in attachments view: type = \(selectableAttachment.messageType)")
                                }
                        }
                    }
                    .multilineTextAlignment(.center)
                    .lineLimit(Constants.Sizing.fileNameLineLimit)
                    .truncationMode(.middle)
                }
            }
            .padding(.top, Constants.Padding.gridTop)
            .padding(.horizontal, Constants.Padding.gridHorizontal)
        }
    }
    
    var bottomButtonsView: some View {
        HStack(spacing: Constants.Spacing.bottomButtonsHorizontal) {
            if viewModel.inSelectionMode {
                Button(L10n.Chat.Attachments.Selection.all) {
                    viewModel.selectAll()

                    A11y.announce(A11y.Announcement.AttachmentGalleryView.selectedAll)
                }
                .disabled(!viewModel.isSelectAllEnabled)
                .foregroundStyle(
                    viewModel.isSelectAllEnabled
                        ? colors.brand.primary
                        : colors.content.tertiary
                )
                .adjustForA11y()
                .accessibilityIdentifier(A11y.AttachmentGalleryView.ButtonSelectAll.identifier)
                .accessibilityLabel(A11y.AttachmentGalleryView.ButtonSelectAll.label)
                .accessibilityHint(A11y.AttachmentGalleryView.ButtonSelectAll.hint)

                Button(L10n.Chat.Attachments.deselect) {
                    viewModel.selectNone()
                    A11y.announce(A11y.Announcement.AttachmentGalleryView.deselectedAll)
                }
                .disabled(!viewModel.isSelectNoneEnabled)
                .foregroundStyle(
                    viewModel.isSelectNoneEnabled
                        ? colors.brand.primary
                        : colors.content.tertiary
                )
                .adjustForA11y()
                .accessibilityIdentifier(A11y.AttachmentGalleryView.ButtonDeselect.identifier)
                .accessibilityLabel(A11y.AttachmentGalleryView.ButtonDeselect.label)
                .accessibilityHint(A11y.AttachmentGalleryView.ButtonDeselect.hint)
            } else {
                Spacer()
            }
            
            HStack(spacing: Constants.Spacing.textAndShareHorizontal) {
                if viewModel.inSelectionMode {
                    Text(
                        viewModel.selectedAttachments.isEmpty
                            ? L10n.Chat.Attachments.selectionMode
                            : L10n.Chat.Attachments.SelectedCount.message(viewModel.selectedAttachments.count)
                    )
                    .foregroundStyle(colors.content.primary)
                    .lineLimit(Constants.Sizing.bottomSectionTextLineLimit)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier(
                        A11y.AttachmentGalleryView.Status.identifier(
                            viewModel.selectedAttachments.isEmpty ? "selection_mode" : "selected_count")
                    )
                    .accessibilityLabel(
                        viewModel.selectedAttachments.isEmpty
                            ? A11y.AttachmentGalleryView.Status.SelectionMode.label
                            : A11y.AttachmentGalleryView.Status.SelectedCount.label(viewModel.selectedAttachments.count)
                    )
                }

                shareButton(for: viewModel.attachmentsToShare)
            }
        }
        .animation(.default, value: viewModel.inSelectionMode)
        .padding(Constants.Padding.bottomButtons)
    }

    /// Takes the attachments to share as a parameter so they are resolved once per render.
    func shareButton(for attachmentsToShare: [URL]) -> some View {
        let isShareEnabled = !attachmentsToShare.isEmpty

        return ShareLink(items: attachmentsToShare) {
            Asset.share
        }
        .disabled(!isShareEnabled)
        .foregroundStyle(
            isShareEnabled
                ? colors.brand.primary
                : colors.content.tertiary
        )
        .adjustForA11y()
        .accessibilityIdentifier(A11y.AttachmentGalleryView.ButtonShare.identifier)
        .accessibilityLabel(A11y.AttachmentGalleryView.ButtonShare.label)
        .accessibilityHint(
            attachmentsToShare.isEmpty
                ? A11y.AttachmentGalleryView.ButtonShare.Hint.none
                : attachmentsToShare.count == 1
                    ? A11y.AttachmentGalleryView.ButtonShare.Hint.single
                    : A11y.AttachmentGalleryView.ButtonShare.Hint.multiple(attachmentsToShare.count)
        )
    }
}

// MARK: - Previews

#Preview("Media Attachments") {
    let attachments: [ChatMessageType] = [
        .text(Lorem.sentence()),
        .image(MockData.imageItem()),
        .audio(MockData.audioItem),
        .video(MockData.videoItem),
        .image(MockData.imageItem())
    ]
    
    Color.clear
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                AttachmentGalleryView(message: MockData.multipleMediaAttachmentsMessage(), messageTypes: attachments, alertType: .constant(nil))
            }
        }
        .environmentObject(ChatStyle())
}

#Preview("Document Attachments") {
    let attachments: [ChatMessageType] = [
        .text(Lorem.sentence()),
        .documentPreview(MockData.pdfPreviewItem),
        .documentPreview(MockData.docPreviewItem),
        .documentPreview(MockData.pptPreviewItem),
        .documentPreview(MockData.xlsPreviewItem),
        .documentPreview(MockData.docPreviewItem)
    ]
    
    Color.clear
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                AttachmentGalleryView(message: MockData.multipleDocumentAttachmentsMessage(), messageTypes: attachments, alertType: .constant(nil))
            }
        }
        .environmentObject(ChatStyle())
}
