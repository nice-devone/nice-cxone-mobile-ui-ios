//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

struct AttachmentsView: View {

    // MARK: - Properties

    @EnvironmentObject private var localization: ChatLocalization
    
    @ObservedObject var viewModel: AttachmentsViewModel

    @State private var shareModalIsPresented = false

    private let config = [
        GridItem(.adaptive(minimum: MultipleAttachmentContainer.cellDimension), spacing: 10),
        GridItem(.adaptive(minimum: MultipleAttachmentContainer.cellDimension), spacing: 10)
    ]

    private let message: ChatMessage

    // MARK: - Init

    init(message: ChatMessage, messageTypes: [ChatMessageType]) {
        self.message = message
        self.viewModel = AttachmentsViewModel(messageTypes: messageTypes)
    }

    // MARK: - Builder

    var body: some View {
        NavigationView {
            VStack {
                gridView
                
                selectionOptionsView
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, StyleGuide.Message.paddingHorizontal)
            .navigationTitle(localization.commonAttachments)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.inSelectionMode ? localization.commonCancel : localization.commonSelect) {
                        viewModel.inSelectionMode.toggle()
                    }
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
                    switch selectableAttachment.messageType {
                    case .image:
                        SelectableImageMessageCell(item: selectableAttachment, attachmentsViewModel: viewModel, inSelectionMode: $viewModel.inSelectionMode)
                    case .video:
                        SelectableVideoMessageCell(item: selectableAttachment, attachmentsViewModel: viewModel, inSelectionMode: $viewModel.inSelectionMode)
                    case .audio:
                        SelectableAudioMessageCell(item: selectableAttachment, attachmentsViewModel: viewModel, inSelectionMode: $viewModel.inSelectionMode)
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }

    var selectionOptionsView: some View {
        HStack {
            Button(localization.chatAttachmentsSelectionAll) {
                viewModel.selectAll()
            }
            .if(!viewModel.inSelectionMode) { view in
                view.hidden()
            }
            
            Spacer()
            
            Button(localization.chatAttachmentsDeselect) {
                viewModel.selectNone()
            }
            .if(!viewModel.inSelectionMode) { view in
                view.hidden()
            }

            Spacer()
            
            Text(
                viewModel.selectedAttachments.isEmpty
                    ? localization.chatAttachmentsSelectionMode
                    : String(format: localization.chatAttachmentsSelectedCount, viewModel.selectedAttachments.count)
            )
            .if(!viewModel.inSelectionMode) { view in
                view.hidden()
            }
            
            Spacer()
            
            Button {
                shareModalIsPresented.toggle()
            } label: {
                Asset.share
            }
            .disabled(viewModel.inSelectionMode ? viewModel.selectedAttachments.isEmpty : false)
        }
        .sheet(isPresented: $shareModalIsPresented) {
            ShareSheet(activityItems: viewModel.selectedAttachments)
        }
    }
}

// MARK: - Previews

struct AttachmentsView_Previews: PreviewProvider {
    
    static let attachments: [ChatMessageType] = [
        .image(MockData.imageItem),
        .image(MockData.imageItem),
        .image(MockData.imageItem),
        .image(MockData.imageItem),
        .image(MockData.imageItem)
    ]
    
    static var previews: some View {
        Group {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    AttachmentsView(message: MockData.imageMessage(), messageTypes: attachments)
                }
                .previewDisplayName("Light Mode")
            
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    AttachmentsView(message: MockData.imageMessage(), messageTypes: attachments)
                }
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatLocalization())
    }
}
