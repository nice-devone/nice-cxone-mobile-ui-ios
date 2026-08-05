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

struct DocumentCellDocumentThumbnailView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
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
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject private var viewModel: DocumentStateViewModel
    
    let fileExtension: String
    let url: URL
    
    private let displayMode: AttachmentThumbnailDisplayMode = .regular
    
    // MARK: - Init
    
    init(fileExtension: String, url: URL, alertType: Binding<ChatAlertType?>) {
        self.viewModel = DocumentStateViewModel(alertType: alertType)
        self.fileExtension = fileExtension
        self.url = url
    }
    
    // MARK: - Builder
    
    @ViewBuilder
    var body: some View {
        Button {
            if case .loaded = viewModel.loadingState {
                viewModel.isReadyToPresent = true
            } else {
                Task {
                    await viewModel.downloadAndSaveFile(url: url)
                }
            }
        } label: {
            buttonLabel
        }
        .sheet(isPresented: $viewModel.isReadyToPresent) {
            if case .loaded(let url) = viewModel.loadingState {
                QuickLookPreview(url: url, isPresented: $viewModel.isReadyToPresent)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.Attachment.identifier(type: "document"))
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
                AttachmentLoadingView(
                    width: displayMode.size.width,
                    height: displayMode.size.height
                )
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
                AttachmentFailedView(
                    width: displayMode.size.width,
                    height: displayMode.size.height
                )
            }
        }
        .padding(.vertical, Constants.Padding.fileExtensionContainerVertical)
        .padding(.horizontal, Constants.Padding.fileExtensionContainerHorizontal)
        .frame(width: displayMode.size.width, height: displayMode.size.height)
    }
}

// MARK: - Preview

#Preview("Single") {
    VStack {
        DocumentCellDocumentThumbnailView(
            fileExtension: "ppt",
            url: MockData.docPreviewURL,
            alertType: .constant(nil)
        )
        .messageChatStyle(MockData.documentMessage(user: MockData.agent), position: .single)
        .shareable(MockData.documentMessage(user: MockData.agent), attachments: [], spacerLength: 0)
        
        DocumentCellDocumentThumbnailView(
            fileExtension: "ppt",
            url: MockData.docPreviewURL,
            alertType: .constant(nil)
        )
        .messageChatStyle(MockData.documentMessage(user: MockData.customer), position: .single)
        .shareable(MockData.documentMessage(user: MockData.customer), attachments: [], spacerLength: 0)
        
        VStack(spacing: 2) {
            DocumentCellDocumentThumbnailView(
                fileExtension: "ppt",
                url: MockData.docPreviewURL,
                alertType: .constant(nil)
            )
            .messageChatStyle(MockData.documentMessage(user: MockData.agent), position: .first)
            .shareable(MockData.documentMessage(user: MockData.agent), attachments: [], spacerLength: 0)
            
            DocumentCellDocumentThumbnailView(
                fileExtension: "ppt",
                url: MockData.docPreviewURL,
                alertType: .constant(nil)
            )
            .messageChatStyle(MockData.documentMessage(user: MockData.agent), position: .inside)
            .shareable(MockData.documentMessage(user: MockData.agent), attachments: [], spacerLength: 0)
            
            DocumentCellDocumentThumbnailView(
                fileExtension: "ppt",
                url: MockData.docPreviewURL,
                alertType: .constant(nil)
            )
            .messageChatStyle(MockData.documentMessage(user: MockData.agent), position: .last)
            .shareable(MockData.documentMessage(user: MockData.agent), attachments: [], spacerLength: 0)
        }
    }
    .padding(.horizontal, 12)
    .environmentObject(ChatStyle())
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
