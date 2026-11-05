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

#if DEBUG

extension AudioPlayer {

    /// Creates a player wired to the in-memory preview providers instead of the network and `AVPlayer`.
    ///
    /// The real player downloads the attachment before it can report a duration, so a canvas without
    /// network access — or with a fixture URL that no longer resolves — is stuck at `00:00`. This
    /// variant reports a fixed clip length and simulates playback locally, which also keeps snapshot
    /// tests deterministic: the duration label reads the same before and after `prepare()` runs.
    ///
    /// - Parameters:
    ///   - item: Attachment the player represents. Only its URL and file name are used.
    ///   - alertType: Binding used by the player to surface errors.
    /// - Returns: A player safe to drive from a SwiftUI preview or a snapshot test.
    static func preview(
        item: AttachmentItem = MockData.audioItem,
        alertType: Binding<ChatAlertType?> = .constant(nil)
    ) -> AudioPlayer {
        let player = AudioPlayer(
            url: item.url,
            fileName: item.fileName,
            alertType: alertType,
            audioSession: MockAudioSessionProvider(),
            audioPlayback: MockAudioPlaybackProvider(),
            audioFileDownloader: MockAudioFileDownloader()
        )

        // Render the duration on the very first frame — `prepare()` resolves the same value, so the
        // label never changes and a snapshot can't capture a half-prepared state
        player.formattedDuration = MockAudioPlaybackProvider.formattedSimulatedDuration

        return player
    }
}

#endif
