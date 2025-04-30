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

import SwiftUI

struct AttachmentsView: View, Themed {

    // MARK: - Properties

    @Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization

    @ObservedObject var viewModel: AttachmentsViewModel

    @Binding private var alertType: ChatAlertType?
    
    @State private var shareModalIsPresented = false
    
    private let config = Array(
        repeating: GridItem(
            .adaptive(minimum: StyleGuide.Attachment.largeDimension),
            spacing: Self.gridItemSpacing,
            alignment: .top
        ),
        count: 2
    )

    private let message: ChatMessage

    private static let gridItemSpacing: CGFloat = 20
    private static let gridItemNameSpacing: CGFloat = 4
    private static let paddingHorizontal: CGFloat = 20
    private static let bottomSectionSpacing: CGFloat = 40
    private static let bottomSectionPadding: CGFloat = 4

    // MARK: - Init

    init(message: ChatMessage, messageTypes: [ChatMessageType], alertType: Binding<ChatAlertType?>) {
        self.message = message
        self.viewModel = AttachmentsViewModel(messageTypes: messageTypes)
        self._alertType = alertType
    }

    // MARK: - Builder

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                gridView
                
                ColoredDivider(colors.customizable.onBackground.opacity(0.1))
                
                bottomButtonsView
            }
            .navigationTitle(localization.commonAttachments)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.inSelectionMode ? localization.commonCancel : localization.commonSelect) {
                        viewModel.inSelectionMode.toggle()
                    }
                    .foregroundStyle(colors.customizable.primary)
                }
            }
        }
    }
}

// MARK: - Subviews

private extension AttachmentsView {

    var gridView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: config) {
                ForEach($viewModel.attachments.wrappedValue, id: \.self) { selectableAttachment in
                    VStack(spacing: Self.gridItemNameSpacing) {
                        switch selectableAttachment.messageType {
                        case .image(let entity):
                            SelectableImageMessageCell(
                                item: selectableAttachment,
                                attachmentsViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode,
                                alertType: $alertType,
                                localization: localization
                            )
                            
                            Text(entity.fileName)
                                .foregroundStyle(colors.customizable.onBackground)
                        case .video(let entity):
                            SelectableVideoMessageCell(
                                item: selectableAttachment,
                                attachmentsViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode,
                                alertType: $alertType,
                                localization: localization
                            )
                            
                            Text(entity.fileName)
                                .foregroundStyle(colors.customizable.onBackground)
                        case .audio(let entity):
                            SelectableAudioMessageCell(
                                item: selectableAttachment,
                                attachmentsViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode,
                                alertType: $alertType,
                                localization: localization
                            )
                            
                            Text(entity.fileName)
                                .foregroundStyle(colors.customizable.onBackground)
                        case .documentPreview(let entity):
                            SelectableDocumentMessageCell(
                                attachment: selectableAttachment,
                                item: entity,
                                attachmentsViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode
                            )
                            
                            Text(entity.fileName)
                                .foregroundStyle(colors.customizable.onBackground)
                        default:
                            EmptyView()
                        }
                    }
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .truncationMode(.middle)
                }
            }
            .padding(.horizontal, Self.paddingHorizontal)
        }
    }
    
    var bottomButtonsView: some View {
        // Not using the `bottomSectionSpacing` because of the selection mode
        HStack(spacing: 0) {
            if viewModel.inSelectionMode {
                Button(action: viewModel.selectAll) {
                    Text(localization.chatAttachmentsSelectionAll)
                        .frame(minWidth: StyleGuide.buttonDimension, minHeight: StyleGuide.buttonDimension)
                }
                .disabled(!viewModel.isSelectAllEnabled)
                .foregroundStyle(viewModel.isSelectAllEnabled ? colors.customizable.primary : colors.customizable.onBackground.opacity(0.5))
                .padding(.trailing, Self.bottomSectionSpacing)
                
                Button(localization.chatAttachmentsDeselect, action: viewModel.selectNone)
                    .disabled(!viewModel.isSelectNoneEnabled)
                    .foregroundStyle(viewModel.isSelectNoneEnabled ? colors.customizable.primary : colors.customizable.onBackground.opacity(0.5))
                    .frame(minWidth: StyleGuide.buttonDimension, minHeight: StyleGuide.buttonDimension)
                
                Spacer(minLength: Self.bottomSectionSpacing)
                
                Text(
                    viewModel.selectedAttachments.isEmpty
                        ? localization.chatAttachmentsSelectionMode
                        : String(format: localization.chatAttachmentsSelectedCount, viewModel.selectedAttachments.count)
                )
                .foregroundStyle(colors.customizable.onBackground)
            }
            
            Spacer()
            
            Button {
                shareModalIsPresented.toggle()
            } label: {
                Asset.share
                    .frame(minWidth: StyleGuide.buttonDimension, minHeight: StyleGuide.buttonDimension)
            }
            .disabled(!viewModel.isShareEnabled)
            .foregroundStyle(viewModel.isShareEnabled ? colors.customizable.primary : colors.customizable.onBackground.opacity(0.5))
        }
        .padding(Self.bottomSectionPadding)
        .lineLimit(1)
        .truncationMode(.middle)
        .sheet(isPresented: $shareModalIsPresented) {
            ShareSheet(activityItems: viewModel.inSelectionMode ? viewModel.selectedAttachments : viewModel.shareableAttachments)
        }
    }
}

// MARK: - Previews

#Preview("Media Attachments") {
    let attachments: [ChatMessageType] = [
        .text(Lorem.sentence()),
        .image(MockData.imageItem),
        .documentPreview(MockData.pdfPreviewItem),
        .image(MockData.imageItem),
        .audio(MockData.audioItem),
        .image(MockData.imageItem)
    ]
    
    Color.clear
        .sheet(isPresented: .constant(true)) {
            AttachmentsView(message: MockData.multipleMediaAttachmentsMessage(), messageTypes: attachments, alertType: .constant(nil))
        }
        .environmentObject(ChatLocalization())
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
            AttachmentsView(message: MockData.multipleDocumentAttachmentsMessage(), messageTypes: attachments, alertType: .constant(nil))
        }
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
}
