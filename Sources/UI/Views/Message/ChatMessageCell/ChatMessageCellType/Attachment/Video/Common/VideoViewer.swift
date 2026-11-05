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

import AVFoundation
import AVKit
import SwiftUI

/// Full-screen playback for a video attachment, mirroring `ImageViewer`: a dedicated
/// viewer with a toolbar close button, the attachment name as the title, and a share
/// action, instead of presenting a bare `VideoPlayer`. Presented inside a
/// `NavigationStack` so the toolbar renders.
struct VideoViewer: View, Themed {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    @Environment(\.dismiss) private var dismiss

    /// The **local** cache file the video was downloaded to — never the remote attachment
    /// URL. `ShareLink` shares this file directly, so the recipient gets the video itself
    /// rather than an auth-gated or expired CDN link. The type can't express the
    /// requirement, hence the name: a caller passing `item.url` would silently regress
    /// sharing back to a remote link.
    ///
    /// Note this lives in `.cachesDirectory`, which the system may evict at any time —
    /// including while the share sheet is open.
    let fileURL: URL
    let name: String

    // Held in `@State` so the player survives `body` re-evaluations (device rotation,
    // color-scheme changes, parent state updates). Constructing `AVPlayer(url:)` inline
    // in `body` would build a fresh player on every re-render, restarting playback from
    // the beginning and losing the current position.
    @State private var player: AVPlayer

    // MARK: - Init

    init(fileURL: URL, name: String) {
        self.fileURL = fileURL
        self.name = name
        self._player = State(initialValue: AVPlayer(url: fileURL))
    }

    // MARK: - Builder

    var body: some View {
        VideoPlayer(player: player)
            .background(colors.background.default)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Asset.close
                            .accessibilityHidden(true)
                    }
                    .accessibilityIdentifier(A11y.VideoViewer.ButtonClose.identifier)
                    .accessibilityLabel(A11y.VideoViewer.ButtonClose.label)
                    .accessibilityHint(A11y.VideoViewer.ButtonClose.hint)
                }

                ToolbarItem(placement: .principal) {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(colors.content.primary)
                        .accessibilityAddTraits(.isHeader)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: fileURL) {
                        Asset.share
                    }
                    .accessibilityIdentifier(A11y.VideoViewer.ButtonShare.identifier)
                    .accessibilityLabel(A11y.VideoViewer.ButtonShare.label)
                    .accessibilityHint(A11y.VideoViewer.ButtonShare.hint)
                }
            }
            .tint(colors.brand.primary)
            .navigationBarTitleDisplayMode(.inline)
            // Stop playback when the viewer is dismissed. Without this the AVPlayer keeps
            // holding the audio session and audio continues over the conversation after the
            // cover is closed, with no visible player left to pause it.
            .onDisappear {
                player.pause()
            }
            .accessibilityIdentifier(A11y.VideoViewer.Content.identifier)
            .accessibilityLabel(A11y.VideoViewer.Content.label)
            .accessibilityHint(A11y.VideoViewer.Content.hint)
    }
}

// MARK: - Preview

#Preview {
    let item = MockData.videoItem
    // `fileURL` must be a local cache file, so the preview resolves the same on-disk
    // location production writes to instead of passing the remote attachment URL.
    let fileURL = item.url.attachmentCacheURL(fileName: item.fileName)
        ?? FileManager.default.temporaryDirectory.appendingPathComponent(item.fileName)

    NavigationStack {
        VideoViewer(fileURL: fileURL, name: item.friendlyName)
            .environmentObject(ChatStyle())
    }
}
