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

import Kingfisher
import SwiftUI

struct MessageInputImageThumbnailView: View, Themed, LayoutAware {
    
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
    
    @State private var loadedImage: UIImage?
    @State private var loadFailed = false

    let url: URL

    /// Stored rather than hardcoded so the strip can hand down `.smallCompact`. It has to be part of
    /// the view's init arguments — otherwise SwiftUI sees an unchanged view and skips re-rendering it
    /// when the strip switches size, leaving a full-size thumbnail in a compact slot.
    private let displayMode: AttachmentThumbnailDisplayMode

    // MARK: - Init

    init(url: URL, displayMode: AttachmentThumbnailDisplayMode) {
        self.url = url
        self.displayMode = displayMode

        // Show an in-memory cached image immediately to avoid a placeholder flash
        // for content Kingfisher already holds in memory. This is a cheap memory
        // lookup (no disk I/O) and is inert when the image isn't cached.
        if let cachedImage = ImageCache.default.retrieveImageInMemoryCache(forKey: url.absoluteString) {
            _loadedImage = State(initialValue: cachedImage)
        }
    }

    // MARK: - Builder
    
    var body: some View {
        let clipShape = RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)

        Group {
            if let loadedImage {
                Image(uiImage: loadedImage) // swiftlint:disable:this accessibility_label_for_image
                    .resizable()
                    .scaledToFill()
            } else if loadFailed {
                AttachmentFailedView(size: thumbnailSize, clipShape: clipShape)
            } else {
                KFImage(source: imageSource)
                    .onSuccess { result in
                        loadedImage = result.image
                    }
                    // Without this the placeholder spinner would stay up forever when the load fails.
                    .onFailure { _ in
                        loadFailed = true
                    }
                    .placeholder {
                        AttachmentLoadingView(size: thumbnailSize)
                    }
                    .resizable()
            }
        }
        .frame(size: thumbnailSize)
        .clippedHitArea(clipShape)
        .background {
            clipShape
                .fill(colors.background.default)
        }
        .overlay {
            clipShape
                .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
        }
    }
}

// MARK: - Private Properties

private extension MessageInputImageThumbnailView {

    /// A file picked from Files or iCloud Drive lies outside the app's sandbox and is security-scoped,
    /// which Kingfisher's default file provider can't read.
    var imageSource: Source {
        if url.isFileURL {
            return .provider(SecurityScopedImageDataProvider(fileURL: url))
        } else {
            return .network(url)
        }
    }
}

// MARK: - Preview

#Preview {
    MessageInputImageThumbnailView(url: MockData.imageUrl(), displayMode: .small)
        .environmentObject(ChatStyle())
}
