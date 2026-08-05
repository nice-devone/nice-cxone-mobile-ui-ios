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

struct MessageInputAttachmentListView: View, Themed {
    private typealias A11yPreview = A11y.MessageInput.AttachmentPreview

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let buttonOffset: CGFloat = StyleGuide.Sizing.buttonSmallDimension / 2
            static let closeButtonStrokeWidth: CGFloat = 1.5
            @MainActor
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
                    .accessibilityElement(children: .ignore)
                    .accessibilityIdentifier(A11yPreview.Loading.identifier)
                    .accessibilityLabel(A11yPreview.Loading.label)
                    .accessibilityValue(A11yPreview.Loading.value(Int(loadingProgress.fractionCompleted * 100)))
            } else {
            	ColoredDivider(colors.border.default)
                	.padding(.horizontal, Constants.Padding.dividerHorizontal)
                    .accessibilityHidden(true)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Constants.Spacing.attachmentsHorizontal) {
                    Spacer()
                    
                    ForEach(attachments, id: \.url) { attachment in
                        attachmentView(for: attachment)
                    }
                }
                .frame(height: Constants.Sizing.contentHeight)
            }
        }
    }
}

// MARK: - Subviews

private extension MessageInputAttachmentListView {

    func attachmentView(for attachment: AttachmentItem) -> some View {
        let (typeIdentifier, typeLabel, typeHint) = switch attachment.mimeType {
        case let type where type.starts(with: UTType.imagePreffix):
            (A11yPreview.Thumbnail.Image.identifier, A11yPreview.Thumbnail.Image.label(attachment.fileName), A11yPreview.Thumbnail.Image.hint)
        case let type where type.starts(with: UTType.videoPreffix):
            (A11yPreview.Thumbnail.Video.identifier, A11yPreview.Thumbnail.Video.label(attachment.fileName), A11yPreview.Thumbnail.Video.hint)
        default:
            (A11yPreview.Thumbnail.Document.identifier, A11yPreview.Thumbnail.Document.label(attachment.fileName), A11yPreview.Thumbnail.Document.hint)
        }

        return VStack(spacing: Constants.Spacing.attachmentsVertical) {
            ZStack(alignment: .topTrailing) {
                switch attachment.mimeType {
                case let type where type.starts(with: UTType.imagePreffix):
                    MessageInputImageThumbnailView(url: attachment.url)
                case let type where type.starts(with: UTType.videoPreffix):
                    VideoThumbnailView(url: attachment.url, displayMode: .small)
                default:
                    MesssageInputAttachmentListDocumentView(item: attachment, alertType: $alertType)
                }

                closeButton {
                    attachments.removeAll { $0.url == attachment.url }

                    A11y.announce(A11y.Announcement.Attachment.removed(attachment.fileName))
                }
                .offset(x: Constants.Sizing.buttonOffset, y: -Constants.Sizing.buttonOffset)
                .accessibilityIdentifier(A11yPreview.ButtonRemove.identifier)
                .accessibilityLabel(A11yPreview.ButtonRemove.label)
                .accessibilityHint(A11yPreview.ButtonRemove.hint(attachment.fileName))
            }
            .padding(.top, Constants.Padding.attachmentItemTop)

            Text(attachment.fileName)
                .font(.caption)
                .foregroundStyle(colors.content.primary)
                .padding(.top, Constants.Padding.textTop)
                .frame(width: StyleGuide.Sizing.Attachment.smallDimension)
                .lineLimit(1)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(typeIdentifier)
        .accessibilityLabel(typeLabel)
        .accessibilityHint(typeHint)
    }
    
    func closeButton(closure: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.default, closure)
        } label: {
            Asset.Attachment.remove
                .fixedSize(width: StyleGuide.Sizing.buttonTinyDimension, height: StyleGuide.Sizing.buttonTinyDimension)
                .foregroundStyle(colors.status.error)
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
    .environmentObject(ChatStyle())
}
