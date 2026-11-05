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

// MARK: - Constants

/// Top-level, not nested in `VideoThumbnailView`: Swift disallows static stored
/// properties in types nested inside a generic type.
private enum Constants {

    enum Colors {
        static let playButtonOverlay: Double = 0.8
        static let playButtonBackgroundOverlay: Double = 0.7
    }
}

struct VideoThumbnailView<ClipShape: InsettableShape>: View, Themed, LayoutAware {

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

    @State private var thumbnail: Image?

    /// `true` once `.task` has resolved with no frame — distinguishes "still generating"
    /// from "generation finished and failed", so a permanent extraction failure (unsupported
    /// codec, truncated file, non-video bytes) doesn't get stuck showing `AttachmentLoadingView`'s
    /// spinner forever. `getVideoThumbnail()` swallows its own errors and returns `nil` either
    /// way, so this is the only signal available to tell the two apart.
    @State private var thumbnailGenerationFailed = false

    let url: URL?
    let displayMode: AttachmentThumbnailDisplayMode

    /// Bubble-matched shape for cells grouped in a conversation (see `MessageGroupPosition.attachmentClipShape`);
    /// defaults to the plain attachment corner radius for standalone/gallery/composer contexts.
    /// Only the failed-generation fallback below actually needs this — see its call site.
    let clipShape: ClipShape

    // MARK: - Init

    init(
        url: URL?,
        displayMode: AttachmentThumbnailDisplayMode,
        clipShape: ClipShape = RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
    ) {
        self.url = url
        self.displayMode = displayMode
        self.clipShape = clipShape

        // Render an already-cached thumbnail on the first paint (covers seeded snapshot
        // fixtures and thumbnails generated on an earlier appearance) so it doesn't wait
        // for the asynchronous task below.
        if let cachedThumbnail = url?.cachedVideoThumbnail() {
            _thumbnail = State(initialValue: cachedThumbnail)
        }
    }

    // MARK: - Builder

    var body: some View {
        Group {
            if let thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(size: thumbnailSize)
                    .clippedHitArea(Rectangle())
                    .overlay(
                        Asset.Attachment.playButtonSymbol
                            .font(displayMode.font)
                            .foregroundStyle(
                                Asset.Colors.Base.black.swiftUIColor.opacity(Constants.Colors.playButtonBackgroundOverlay),
                                Asset.Colors.Base.white.swiftUIColor.opacity(Constants.Colors.playButtonOverlay)
                            )
                    )
            } else if thumbnailGenerationFailed {
                // AttachmentFailedView, not AttachmentLoadingView: the task below already ran
                // to completion and found no frame, so this state won't resolve on its own — an
                // animated spinner here would misread as "still downloading" indefinitely.
                //
                // `clipShape` (not the default here): unlike `AttachmentLoadingView` below,
                // `AttachmentFailedView`'s clip shape also drives an unconditional background
                // fill, not just the border stroke — passing the wrong shape would fill a plain
                // uniform corner while the caller's border strokes a tighter grouped-position
                // one, leaving an unpainted gap between the two arcs. No `drawsBorder`: every
                // current caller already draws its own border around the whole cell.
                AttachmentFailedView(size: thumbnailSize, clipShape: clipShape)
            } else {
                // No `drawsBorder` here: every current caller (`VideoMessageCell`, the gallery
                // and composer thumbnails) already wraps this whole view in its own border,
                // unconditionally of loading state — drawing one here too would stroke the same
                // border twice, stacked exactly on top of itself. `clipShape` is passed anyway
                // for consistency with the branch above, even though it's dead code here since
                // `AttachmentLoadingView` only reads it when `drawsBorder` is `true`.
                AttachmentLoadingView(size: thumbnailSize, clipShape: clipShape)
            }
        }
        .frame(size: thumbnailSize)
        .task(id: url) {
            // Defensive on the same grounds as the cancellation guard below (no current
            // caller mutates a live instance's `url`): `.task(id:)` reuses the same
            // `@State` across a URL change, so without this reset a failure recorded for
            // an earlier URL would keep rendering `AttachmentFailedView` for the new one
            // until its own task resolves.
            thumbnailGenerationFailed = false

            guard thumbnail == nil else {
                return
            }

            let generatedThumbnail = await url?.getVideoThumbnail()

            // Defensive rather than a fix for a reachable bug: every current caller
            // identifies its `VideoThumbnailView` by a stable id fixed to this same `url`
            // (`MessageInputAttachmentListView`/`AttachmentGalleryView`'s stable-id
            // `ForEach`s, `VideoMessageCell`'s one-URL-per-message), so cancellation here
            // only happens when the view leaves the hierarchy — where `@State` is torn
            // down anyway and this write would be discarded regardless. Kept because
            // `getVideoThumbnail()` catches every error internally, cancellation included,
            // and returns `nil` either way, so it can't distinguish "generation failed"
            // from "cancelled" for us to react to differently — and the guard costs nothing.
            guard !Task.isCancelled else {
                return
            }

            thumbnail = generatedThumbnail
            thumbnailGenerationFailed = generatedThumbnail == nil
        }
    }
}

// MARK: - Preview

private struct PreviewHelper: View {
    
    let title: String
    let displayMode: AttachmentThumbnailDisplayMode
    
    var body: some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            VideoThumbnailView(url: MockData.videoUrl, displayMode: displayMode)
                .environmentObject(ChatStyle())
        }
    }
}

#Preview {
    List {
        PreviewHelper(title: "Tap on more that 4 attachments", displayMode: .regular)
        
        PreviewHelper(title: "Standalone Video Attachment", displayMode: .large)
    }
}
