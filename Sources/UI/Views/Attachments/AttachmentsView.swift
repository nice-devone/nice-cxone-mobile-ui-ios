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

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let gridColumnCount: Int = 2
            static let fileNameLineLimit = 2
            static let bottomSectionTextLineLimit = 1
        }
        
        enum Spacing {
            static let headerElementsVertical: CGFloat = 0
            static let headerElementsHorizontal: CGFloat = 0
            static let gridItem: CGFloat = 20
            static let gridItemNameVertical: CGFloat = 4
            static let elementsVertical: CGFloat = 0
            static let bottomButtonsHorizontal: CGFloat = 48
            static let textAndShareHorizontal: CGFloat = 16
        }
        
        enum Padding {
            static let headerVertical: CGFloat = 12
            static let headerHorizontal: CGFloat = 24
            static let gridHorizontal: CGFloat = 20
            static let bottomButtons: CGFloat = 4
        }
    }
    
    // MARK: - Properties

    @Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization

    @ObservedObject var viewModel: AttachmentsViewModel

    @Binding private var alertType: ChatAlertType?
    
    @State private var iShareModalPresented = false
    
    private let config = Array(
        repeating: GridItem(
            .adaptive(minimum: StyleGuide.Sizing.Attachment.largeWidth),
            spacing: Constants.Spacing.gridItem,
            alignment: .top
        ),
        count: Constants.Sizing.gridColumnCount
    )

    private let message: ChatMessage

    // MARK: - Init

    init(message: ChatMessage, messageTypes: [ChatMessageType], alertType: Binding<ChatAlertType?>) {
        self.message = message
        self.viewModel = AttachmentsViewModel(messageTypes: messageTypes)
        self._alertType = alertType
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: Constants.Spacing.elementsVertical) {
            headerView
            
            gridView
            
            ColoredDivider(colors.border.default)
            
            bottomButtonsView
        }
        .background(colors.background.default)
        .sheet(isPresented: $iShareModalPresented) {
            ShareSheet(activityItems: viewModel.inSelectionMode ? viewModel.selectedAttachments : viewModel.shareableAttachments)
        }
    }
}

// MARK: - Subviews

private extension AttachmentsView {

    var headerView: some View {
        VStack(spacing: Constants.Spacing.headerElementsVertical) {
            HStack(spacing: Constants.Spacing.headerElementsHorizontal) {
                Spacer()
                    .frame(maxWidth: .infinity)
                
                Text(localization.commonAttachments)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.inSelectionMode.toggle()
                    } label: {
                        Text(viewModel.inSelectionMode ? localization.commonCancel : localization.commonSelect)
                            .fontWeight(.medium)
                    }
                }
                .font(.callout)
                .foregroundStyle(colors.brand.primary)
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, Constants.Padding.headerVertical)
            .padding(.horizontal, Constants.Padding.headerHorizontal)
            
            ColoredDivider(colors.border.default)
        }
    }
    
    var gridView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: config) {
                ForEach($viewModel.attachments.wrappedValue, id: \.self) { selectableAttachment in
                    VStack(spacing: Constants.Spacing.gridItemNameVertical) {
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
                                .foregroundStyle(colors.content.primary)
                        case .video(let entity):
                            SelectableVideoMessageCell(
                                item: selectableAttachment,
                                attachmentsViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode,
                                alertType: $alertType,
                                localization: localization
                            )
                            
                            Text(entity.fileName)
                                .foregroundStyle(colors.content.primary)
                        case .documentPreview(let entity):
                            SelectableDocumentMessageCell(
                                attachment: selectableAttachment,
                                item: entity,
                                attachmentsViewModel: viewModel,
                                inSelectionMode: $viewModel.inSelectionMode,
                                alertType: $alertType,
                                localization: localization
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
            .padding(.top, 24)
            .padding(.horizontal, Constants.Padding.gridHorizontal)
        }
    }
    
    var bottomButtonsView: some View {
        HStack(spacing: Constants.Spacing.bottomButtonsHorizontal) {
            if viewModel.inSelectionMode {
                Button(localization.chatAttachmentsSelectionAll, action: viewModel.selectAll)
                    .disabled(!viewModel.isSelectAllEnabled)
                    .foregroundStyle(
                        viewModel.isSelectAllEnabled
                            ? colors.brand.primary
                            : colors.content.tertiary
                    )
                    .adjustForA11y()
                
                Button(localization.chatAttachmentsDeselect, action: viewModel.selectNone)
                    .disabled(!viewModel.isSelectNoneEnabled)
                    .foregroundStyle(
                        viewModel.isSelectNoneEnabled
                            ? colors.brand.primary
                            : colors.content.tertiary
                    )
                    .adjustForA11y()
            } else {
                Spacer()
            }
            
            HStack(spacing: Constants.Spacing.textAndShareHorizontal) {
                if viewModel.inSelectionMode {
                    Text(
                        viewModel.selectedAttachments.isEmpty
                            ? localization.chatAttachmentsSelectionMode
                            : String(format: localization.chatAttachmentsSelectedCount, viewModel.selectedAttachments.count)
                    )
                    .foregroundStyle(colors.content.primary)
                    .lineLimit(Constants.Sizing.bottomSectionTextLineLimit)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity)
                }
                
                Button {
                    iShareModalPresented.toggle()
                } label: {
                    Asset.share
                }
                .disabled(!viewModel.isShareEnabled)
                .foregroundStyle(
                    viewModel.isShareEnabled
                        ? colors.brand.primary
                        : colors.content.tertiary
                )
                .adjustForA11y()
            }
        }
        .animation(.default, value: viewModel.inSelectionMode)
        .padding(Constants.Padding.bottomButtons)
    }
}

// MARK: - Previews

#Preview("Media Attachments") {
    let attachments: [ChatMessageType] = [
        .text(Lorem.sentence()),
        .image(MockData.imageItem),
        .audio(MockData.audioItem),
        .video(MockData.videoItem),
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
