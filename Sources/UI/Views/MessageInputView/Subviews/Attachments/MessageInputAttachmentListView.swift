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
import UniformTypeIdentifiers

struct MessageInputAttachmentListView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let buttonOffset: CGFloat = StyleGuide.Sizing.buttonSmallDimension / 2
            static let closeButtonStrokeWidth: CGFloat = 1.5
            static let contentHeight: CGFloat = StyleGuide.Sizing.Attachment.smallDimension + Constants.Padding.thumbnailScrollViewVertical * 2
        }
        
        enum Spacing {
            static let attachmentsVertical: CGFloat = 0
            static let attachmentsHorizontal: CGFloat = 8
        }
        
        enum Padding {
            static let dividerHorizontal: CGFloat = 12
            static let thumbnailScrollViewVertical: CGFloat = 14
            static let attachmentItemTop: CGFloat = 8
            static let textTop: CGFloat = 4
            static let closeButton: CGFloat = 4
        }
    }
    
    // MARK: - Properties

    @Environment(\.colorScheme) var scheme

    @EnvironmentObject var style: ChatStyle

    @Binding var attachments: [AttachmentItem]
    @Binding var loadingProgress: Progress?
    @Binding var alertType: ChatAlertType?
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: .zero) {
            
            if let loadingProgress {
                ProgressView(value: loadingProgress.fractionCompleted)
                    .tint(colors.brand.primary)
                    .background(colors.border.default)
            } else {
            	ColoredDivider(colors.border.default)
                	.padding(.horizontal, Constants.Padding.dividerHorizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Constants.Spacing.attachmentsHorizontal) {
                    Spacer()
                    
                    ForEach(0..<attachments.count, id: \.self) { index in
                        attachmentView(at: index)
                    }
                }
                .frame(height: Constants.Sizing.contentHeight)
            }
        }
    }
}

// MARK: - Subviews

private extension MessageInputAttachmentListView {

    @ViewBuilder
    func attachmentView(at index: Int) -> some View {
        let attachment = attachments[index]
        
        VStack(spacing: Constants.Spacing.attachmentsVertical) {
            ZStack(alignment: .topTrailing) {
                switch attachment.mimeType {
                case let type where type.starts(with: UTType.imagePreffix):
                    MessageInputImageThumbnailView(url: attachment.url)
                case let type where type.starts(with: UTType.videoPreffix):
                    VideoThumbnailView(url: attachment.url, displayMode: .small)
                default:
                    MesssageInputAttachmentListDocumentView(item: attachment)
                }
                
                closeButton {
                    attachments.remove(at: index)
                }
                .offset(x: Constants.Sizing.buttonOffset, y: -Constants.Sizing.buttonOffset)
            }
            .padding(.top, Constants.Padding.attachmentItemTop)
            
            Text(attachment.fileName)
                .font(.caption)
                .foregroundColor(colors.content.primary)
                .padding(.top, Constants.Padding.textTop)
                .frame(width: StyleGuide.Sizing.Attachment.smallDimension)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
    
    func closeButton(closure: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.default, closure)
        } label: {
            Asset.Attachment.remove
                .fixedSize(width: StyleGuide.Sizing.buttonTinyDimension, height: StyleGuide.Sizing.buttonTinyDimension)
                .foregroundColor(colors.status.error)
                .background(
                    Circle()
                        .fill(colors.background.default)
                        .padding(Constants.Padding.closeButton)
                        .overlay(
                            Circle()
                                .stroke(colors.background.default, lineWidth: Constants.Sizing.closeButtonStrokeWidth)
                        )
                )
                .contentShape(Rectangle())
        }
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview("Media Attachments") {
    @Previewable @State var progress: Progress? = {
        var progress = Progress(totalUnitCount: 100)
        progress.completedUnitCount = 50
        
        return progress
    }()
    @Previewable @State var attachments = [
        MockData.videoItem,
        MockData.imageItem,
        MockData.audioItem
    ]
    
    VStack {
        Spacer()
        
        MessageInputAttachmentListView(
            attachments: $attachments,
            loadingProgress: $progress,
            alertType: .constant(nil)
        )
    }
    .environmentObject(ChatLocalization())
    .environmentObject(ChatStyle())
}

@available(iOS 17.0, *)
#Preview("Document Attachments") {
    @Previewable @State var progress: Progress? = {
        var progress = Progress(totalUnitCount: 100)
        progress.completedUnitCount = 75
        
        return progress
    }()
    @Previewable @State var attachments = [
        MockData.docPreviewItem,
        MockData.pdfPreviewItem,
        MockData.pptPreviewItem
    ]
    
    VStack {
        Spacer()
        
        MessageInputAttachmentListView(attachments: $attachments, loadingProgress: $progress, alertType: .constant(nil))
    }
    .environmentObject(ChatLocalization())
    .environmentObject(ChatStyle())
}
