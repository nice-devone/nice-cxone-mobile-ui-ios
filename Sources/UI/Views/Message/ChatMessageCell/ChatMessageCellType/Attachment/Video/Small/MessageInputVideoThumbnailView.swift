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

struct MessageInputVideoThumbnailView: View, Themed {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    let url: URL?

    /// Stored rather than hardcoded so the strip can hand down `.smallCompact` — see the note on
    /// `MessageInputImageThumbnailView.displayMode`.
    private let displayMode: AttachmentThumbnailDisplayMode

    // MARK: - Init

    init(url: URL?, displayMode: AttachmentThumbnailDisplayMode) {
        self.url = url
        self.displayMode = displayMode
    }

    // MARK: - Builder

    var body: some View {
        // Thin wrapper, not a reimplementation: `VideoThumbnailView` already owns the
        // cache-check/load/flicker-avoidance logic shared with the Regular and Large
        // tiers. Only the composer's border is specific here.
        VideoThumbnailView(url: url, displayMode: displayMode)
            .clippedHitArea(.rect(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                    .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
            )
    }
}

// MARK: - Preview

#Preview {
    MessageInputVideoThumbnailView(url: MockData.videoUrl, displayMode: .small)
        .environmentObject(ChatStyle())
}
