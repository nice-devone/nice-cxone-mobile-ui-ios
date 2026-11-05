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

import Foundation

#if DEBUG

// MARK: - MockAudioPlaybackProvider

/// Preview replacement for the `AVPlayer`-backed playback provider.
///
/// Reports a fixed clip length immediately — no asset is loaded, so the duration label renders
/// on the first frame instead of after an asynchronous metadata load — and advances the playback
/// position in wall-clock time so the progress bar, seek buttons, and elapsed label all behave
/// like the real thing in the canvas.
@MainActor
final class MockAudioPlaybackProvider: AudioPlaybackProviding {

    // MARK: - Properties

    /// Length of the simulated clip, in seconds.
    ///
    /// Keep in sync with ``formattedSimulatedDuration`` — that string is what `AudioPlayer`
    /// renders for this value.
    static let simulatedDuration: TimeInterval = 45
    /// ``simulatedDuration`` as `AudioPlayer` formats it.
    static let formattedSimulatedDuration = "00:45"

    /// Position accumulated over previous play sessions; the authoritative value while paused.
    private var elapsedBeforePause: TimeInterval = 0
    /// Start of the current play session; `nil` while paused.
    private var playStartDate: Date?

    var totalDuration: Double {
        Self.simulatedDuration
    }

    var currentDuration: Double {
        guard let playStartDate else {
            return elapsedBeforePause
        }

        return min(elapsedBeforePause + Date().timeIntervalSince(playStartDate), Self.simulatedDuration)
    }

    var playProgress: Double {
        min(max(0, currentDuration / Self.simulatedDuration), 1)
    }

    // MARK: - Methods

    func loadTotalDuration() async throws -> Double {
        Self.simulatedDuration
    }

    func replaceCurrentItem(with url: URL) {
        LogManager.trace("[MOCK] Replace current item with \(url.lastPathComponent)")

        elapsedBeforePause = 0
        playStartDate = nil
    }

    func play() {
        LogManager.trace("[MOCK] Play")

        playStartDate = Date()
    }

    func pause() {
        LogManager.trace("[MOCK] Pause")

        elapsedBeforePause = currentDuration
        playStartDate = nil
    }

    func seekToZero() {
        seek(to: 0)
    }

    func seek(to seconds: Double) {
        LogManager.trace("[MOCK] Seek to \(seconds)")

        guard seconds.isFinite else {
            return
        }

        elapsedBeforePause = min(max(0, seconds), Self.simulatedDuration)

        // Rebase the play session so playback continues from the new position
        if playStartDate != nil {
            playStartDate = Date()
        }
    }
}

#endif
