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

struct MessageInputAttachmentListView: View, Themed, LayoutAware {
    private typealias A11yPreview = A11y.MessageInput.AttachmentPreview

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            /// The remove button's tap area. A 44 pt target is the accessibility minimum; the visible
            /// circle is drawn at `buttonTinyDimension`, so this only governs where taps land.
            static let closeButtonHitDimension: CGFloat = StyleGuide.Sizing.Button.regularDimension
            /// Nudges the button out past the thumbnail's top-trailing corner so the visible circle
            /// straddles the edge rather than sitting inside it.
            static let buttonOffset: CGFloat = StyleGuide.Sizing.Button.smallDimension / 2
            /// How far the hit rect follows the circle out over that corner. Only the label is offset,
            /// so an un-shifted rect would leave the outermost part of the circle — the corner a user
            /// aims for — outside it.
            ///
            /// It only has to make up the ~4 pt the offset label overhangs its frame by, not the whole
            /// `buttonOffset`: the 44 pt frame already extends 12 pt past the 20 pt label on every side.
            /// The gap between tiles is the ceiling — any further and the rect reaches the neighbouring
            /// attachment, where a tap would remove the wrong one. Note the floor, though: narrowing
            /// that gap below ~4 pt would reopen the dead corner from the other end.
            static let closeButtonHitOffset: CGFloat = Spacing.attachmentsHorizontal
            static let closeButtonStrokeWidth: CGFloat = 1.5
            /// Height reserved for the filename title at the default text size. `.caption`
            /// measures ~16 pt of line height there; the extra point is deliberate slack, since
            /// over-reserving only adds a hairline of padding while under-reserving clips the
            /// descenders. Scaled with Dynamic Type via `@ScaledMetric(relativeTo: .caption)` in
            /// `contentHeight` so the label isn't clipped at larger accessibility sizes.
            static let titleBaseHeight: CGFloat = 17
            static let gradientWidth: CGFloat = 80

            /// Thumbnail geometry for the strip: shrunken while the keyboard is taking the space away
            /// on a compact-height screen, full size otherwise.
            static func displayMode(isCompact: Bool) -> AttachmentThumbnailDisplayMode {
                isCompact ? .smallCompact : .small
            }

            /// Total strip height. Every term the tile lays out has to be counted here, or the strip
            /// clips it: the thumbnail, the strip's own vertical padding, and the top inset that keeps
            /// the remove button — which overhangs the thumbnail's corner — from being cut off. The
            /// title adds its Dynamic-Type-scaled height plus the spacing above it, and is only present
            /// outside compact mode.
            static func contentHeight(thumbnailHeight: CGFloat, isCompact: Bool, titleHeight: CGFloat) -> CGFloat {
                let thumbnail = thumbnailHeight
                    + Padding.thumbnailScrollViewVertical(isCompact: isCompact) * 2
                    + Padding.attachmentItemTop

                return isCompact
                    ? thumbnail
                    : thumbnail + Spacing.imageAndTextVertical + titleHeight
            }
        }
        
        enum Spacing {
            static let attachmentsHorizontal: CGFloat = 8
            static let imageAndTextVertical: CGFloat = 4
        }
        
        enum Padding {
            /// Vertical padding around the thumbnail strip. Tightened on compact-height screens, where
            /// the strip, the input bar and the conversation all have to share the ~150 pt left above
            /// the keyboard.
            static func thumbnailScrollViewVertical(isCompact: Bool) -> CGFloat {
                isCompact ? 4 : 14
            }
            static let attachmentItemTop: CGFloat = 8
            static let closeButton: CGFloat = 4
        }
    }
    
    // MARK: - Properties

    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout

    @EnvironmentObject var style: ChatStyle

    @Binding var attachments: [AttachmentItem]
    @Binding var alertType: ChatAlertType?

    /// Whether the keyboard is currently on screen and taking height away from the conversation.
    let isKeyboardVisible: Bool

    /// Scales the reserved title height with the user's Dynamic Type setting so the
    /// `.caption` filename label under each thumbnail isn't clipped at larger sizes.
    @ScaledMetric(relativeTo: .caption) private var titleHeight: CGFloat = Constants.Sizing.titleBaseHeight

    /// The strip shrinks — smaller thumbnails, tighter padding, no filename label — only while the
    /// keyboard is actually taking the space away.
    ///
    /// A landscape iPhone leaves ~150 pt below the navigation bar with the keyboard up, which the
    /// regular strip (~128 pt) and the input bar (~52 pt) cannot share. Without the keyboard the same
    /// screen has ~355 pt, so the strip keeps its full size and shows filenames there.
    @MainActor
    private var isCompact: Bool {
        isCompactHeight && isKeyboardVisible
    }

    /// Handed to every tile so the thumbnail size is part of their init arguments — see the note on
    /// `MessageInputImageThumbnailView.displayMode`.
    @MainActor
    private var displayMode: AttachmentThumbnailDisplayMode {
        Constants.Sizing.displayMode(isCompact: isCompact)
    }

    /// Height reserved for the strip, from the geometry the current orientation and Dynamic Type
    /// setting resolve to.
    @MainActor
    private var stripHeight: CGFloat {
        Constants.Sizing.contentHeight(
            thumbnailHeight: attachmentSize(for: displayMode).height,
            isCompact: isCompact,
            titleHeight: titleHeight
        )
    }

    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: .zero) {
            // Only the horizontal container inset is ignored, so the divider still spans display-wide
            // in landscape. `.all` would also opt out of the `.keyboard` region, which detaches the
            // strip from keyboard avoidance and leaves the input bar stranded behind the keyboard.
            ColoredDivider(colors.border.default)
                .ignoresSafeArea(.container, edges: .horizontal)
                .accessibilityHidden(true)

            ZStack(alignment: .trailing) {
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHStack(spacing: Constants.Spacing.attachmentsHorizontal) {
                        Spacer()
                        
                        ForEach(attachments, id: \.url) { attachment in
                            attachmentView(for: attachment)
                        }
                        
                        Spacer(minLength: Constants.Sizing.gradientWidth)
                    }
                    .padding(.vertical, Constants.Padding.thumbnailScrollViewVertical(isCompact: isCompact))
                }
                
                LinearGradient(colors: [.clear, colors.background.default], startPoint: .leading, endPoint: .trailing)
                    .frame(width: Constants.Sizing.gradientWidth, height: stripHeight)
                    // Decorative fade only — must not intercept touches, otherwise it
                    // swallows taps on close buttons that scroll under the rightmost
                    // `gradientWidth` pt of the viewport (the `Spacer(minLength:)` above
                    // pads scroll content, not the gradient's hit region).
                    .allowsHitTesting(false)
            }
            .frame(height: stripHeight)
            .ignoresSafeArea(.container, edges: .horizontal)
        }
        // Resize alongside the keyboard's own transition rather than snapping to the new size.
        .animation(.default, value: isCompact)
    }
}

// MARK: - Subviews

private extension MessageInputAttachmentListView {

    func attachmentView(for attachment: AttachmentItem) -> some View {
        let mediaType = AttachmentMediaType(mimeType: attachment.mimeType)
        let (typeIdentifier, typeLabel, typeHint) = switch mediaType {
        case .image:
            (A11yPreview.Thumbnail.Image.identifier, A11yPreview.Thumbnail.Image.label(attachment.fileName), A11yPreview.Thumbnail.Image.hint)
        case .video:
            (A11yPreview.Thumbnail.Video.identifier, A11yPreview.Thumbnail.Video.label(attachment.fileName), A11yPreview.Thumbnail.Video.hint)
        case .audio, .document:
            (A11yPreview.Thumbnail.Document.identifier, A11yPreview.Thumbnail.Document.label(attachment.fileName), A11yPreview.Thumbnail.Document.hint)
        }

        return VStack(spacing: Constants.Spacing.imageAndTextVertical) {
            ZStack(alignment: .topTrailing) {
                switch mediaType {
                case .image:
                    MessageInputImageThumbnailView(url: attachment.url, displayMode: displayMode)
                case .video:
                    MessageInputVideoThumbnailView(url: attachment.url, displayMode: displayMode)
                case .audio, .document:
                    MessageInputDocumentThumbnailView(item: attachment, alertType: $alertType, displayMode: displayMode)
                }

                closeButton {
                    attachments.removeAll { $0.url == attachment.url }

                    A11y.announce(A11y.Announcement.Attachment.removed(attachment.fileName))
                }
                .accessibilityIdentifier(A11yPreview.ButtonRemove.identifier)
                .accessibilityLabel(A11yPreview.ButtonRemove.label)
                .accessibilityHint(A11yPreview.ButtonRemove.hint(attachment.fileName))
            }
            .padding(.top, Constants.Padding.attachmentItemTop)

            if !isCompact {
                Text(attachment.fileName)
                    .font(.caption)
                    .foregroundStyle(colors.content.primary)
                    .frame(width: attachmentSize(for: displayMode).width)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .accessibilityHidden(true)
            }
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
                .fixedSize(width: StyleGuide.Sizing.Button.tinyDimension, height: StyleGuide.Sizing.Button.tinyDimension)
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
                // Offsets the visible circle out over the thumbnail's corner while the button's frame
                // below stays anchored inside the tile. Offsetting the frame instead would carry the hit
                // rect with it and let a tap near the next attachment's corner delete this one.
                .offset(x: Constants.Sizing.buttonOffset, y: -Constants.Sizing.buttonOffset)
        }
        .frame(width: Constants.Sizing.closeButtonHitDimension, height: Constants.Sizing.closeButtonHitDimension)
        // Outside the frame, not on the label: a button takes its hit region from the label's shape, so
        // inside it the tap area stayed the ~20 pt symbol and the frame only centred it.
        .contentShape(
            Rectangle()
                .offset(x: Constants.Sizing.closeButtonHitOffset, y: -Constants.Sizing.closeButtonHitOffset)
        )
    }
}

#if DEBUG

// MARK: - Previews

@available(iOS 17.0, *)
#Preview("Media Attachments - regular") {
    @Previewable @State var attachments = [
        MockData.videoItem,
        MockData.imageItem(imageIndex: 1),
        MockData.audioItem,
        MockData.imageItem(imageIndex: 2),
        MockData.imageItem(imageIndex: 3),
        MockData.imageItem(imageIndex: 4),
        MockData.imageItem(imageIndex: 5),
        MockData.imageItem(imageIndex: 6),
        MockData.imageItem(imageIndex: 7),
        MockData.imageItem(imageIndex: 8),
        MockData.imageItem(imageIndex: 9)
    ]
    
    NavigationStack {
        VStack {
            Color.clear
                .overlay(alignment: .bottom) {
                    MessageInputAttachmentListView(
                        attachments: $attachments,
                        alertType: .constant(nil),
                        isKeyboardVisible: false
                    )
                }

            MessageInputView(
                attachmentRestrictions: MockData.attachmentRestrictions,
                attachments: $attachments,
                isEditing: .constant(false),
                isInputEnabled: .constant(false),
                isSendingMessage: .constant(false),
                alertType: .constant(nil),
                audioRecorder: .preview()
            ) { _, _ in }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("John Doe")
        .environmentObject(ChatStyle())
    }
}

@available(iOS 17.0, *)
#Preview("Media Attachments - compact") {
    @Previewable @State var attachments = [
        MockData.videoItem,
        MockData.imageItem(imageIndex: 1),
        MockData.audioItem,
        MockData.imageItem(imageIndex: 2),
        MockData.imageItem(imageIndex: 3),
        MockData.imageItem(imageIndex: 4),
        MockData.imageItem(imageIndex: 5),
        MockData.imageItem(imageIndex: 6),
        MockData.imageItem(imageIndex: 7),
        MockData.imageItem(imageIndex: 8),
        MockData.imageItem(imageIndex: 9)
    ]
    
    NavigationStack {
        VStack {
            Color.clear
                .overlay(alignment: .bottom) {
                    MessageInputAttachmentListView(
                        attachments: $attachments,
                        alertType: .constant(nil),
                        isKeyboardVisible: true
                    )
                }
            
            MessageInputView(
                attachmentRestrictions: MockData.attachmentRestrictions,
                attachments: $attachments,
                isEditing: .constant(false),
                isInputEnabled: .constant(false),
                isSendingMessage: .constant(false),
                alertType: .constant(nil),
                audioRecorder: .preview()
            ) { _, _ in }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("John Doe")
        .environmentObject(ChatStyle())
    }
}

@available(iOS 17.0, *)
#Preview("Document Attachments - small") {
    @Previewable @State var attachments = [
        MockData.docPreviewItem,
        MockData.pdfPreviewItem,
        MockData.pptPreviewItem
    ]
    
    NavigationStack {
        VStack {
            Color.clear
                .overlay(alignment: .bottom) {
                    MessageInputAttachmentListView(
                        attachments: $attachments,
                        alertType: .constant(nil),
                        isKeyboardVisible: false
                    )
                }
            
            MessageInputView(
                attachmentRestrictions: MockData.attachmentRestrictions,
                attachments: $attachments,
                isEditing: .constant(false),
                isInputEnabled: .constant(false),
                isSendingMessage: .constant(false),
                alertType: .constant(nil),
                audioRecorder: .preview()
            ) { _, _ in }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("John Doe")
        .environmentObject(ChatStyle())
    }
}

@available(iOS 17.0, *)
#Preview("Document Attachments - compact") {
    @Previewable @State var attachments = [
        MockData.docPreviewItem,
        MockData.pdfPreviewItem,
        MockData.pptPreviewItem
    ]
    
    NavigationStack {
        VStack {
            Color.clear
                .overlay(alignment: .bottom) {
                    MessageInputAttachmentListView(
                        attachments: $attachments,
                        alertType: .constant(nil),
                        isKeyboardVisible: true
                    )
                }
            
            MessageInputView(
                attachmentRestrictions: MockData.attachmentRestrictions,
                attachments: $attachments,
                isEditing: .constant(false),
                isInputEnabled: .constant(false),
                isSendingMessage: .constant(false),
                alertType: .constant(nil),
                audioRecorder: .preview()
            ) { _, _ in }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("John Doe")
        .environmentObject(ChatStyle())
    }
}

#endif
