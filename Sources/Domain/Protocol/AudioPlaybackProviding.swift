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
import Mockable

/// Abstraction over the `AVPlayer`-backed audio playback used by ``AudioPlayer``.
///
/// The protocol exists so the player view model can be unit-tested without spinning up a
/// real `AVPlayer`. The default implementation, ``DefaultAudioPlaybackProvider``, wraps a
/// single `AVPlayer` instance and forwards calls to it.
///
/// All members are `@MainActor`-isolated because `AVPlayer`'s computed properties are
/// main-actor-isolated under Swift Concurrency.
@Mockable
@MainActor
protocol AudioPlaybackProviding {

    // MARK: - Live state

    /// Fractional playback progress of the active item, in the range `[0, 1]`.
    ///
    /// Implementations guarantee a finite, non-negative value — never `NaN`, `inf`, or
    /// negative — so callers can safely use it in arithmetic and bindings without
    /// sanitising. Returns `0` when the player has no current item or when the active
    /// asset's duration has not yet loaded. Combine with ``totalDuration`` to render
    /// percentage labels.
    var playProgress: Double { get }

    /// Current playback time of the active item, in seconds.
    ///
    /// Safe to read repeatedly during playback — the underlying `AVPlayer` returns a fresh
    /// value on every call. Implementations guarantee a finite, non-negative value;
    /// returns `0` when the player has no current item or when the time is not yet known.
    var currentDuration: Double { get }

    /// Best-effort synchronous read of the active item's total duration, in seconds.
    ///
    /// Implementations guarantee a finite, non-negative value. **Treat any value `<= 0`
    /// as "duration unknown / item not ready"** — that's what you get while the
    /// underlying `AVAsset` is still loading its metadata (e.g. immediately after
    /// ``replaceCurrentItem(with:)``).
    ///
    /// When the real duration is required regardless of load state (such as right after
    /// replacing the item), use ``loadTotalDuration()`` instead — it awaits the asset's
    /// metadata and returns the canonical value.
    var totalDuration: Double { get }

    /// Asynchronously loads and returns the active item's total duration, in seconds.
    ///
    /// Use this from ``AudioPlayer/prepare()`` and any other code path that needs the
    /// duration **immediately after** ``replaceCurrentItem(with:)``: the synchronous
    /// ``totalDuration`` property reports `0` until the asset's metadata has loaded, so
    /// reading it inline always reports `0`. This method awaits the asset's `.duration`
    /// key and returns the real value once it is available.
    ///
    /// - Returns: Duration in seconds, or `0` if no item is loaded or the value is
    ///            non-finite.
    /// - Throws: Any error surfaced by `AVAsset.load(.duration)` (e.g. network failures
    ///            for remote assets).
    func loadTotalDuration() async throws -> Double

    // MARK: - Item control

    /// Replaces the player's current item with the asset at `url`.
    ///
    /// Returns immediately; asset metadata loads asynchronously in the background. Use
    /// ``loadTotalDuration()`` if you need the duration right after calling this.
    ///
    /// - Parameter url: Local or remote URL of the audio asset to play.
    func replaceCurrentItem(with url: URL)

    // MARK: - Transport

    /// Starts or resumes playback at the current position.
    ///
    /// Has no effect if no item is loaded. Use ``seekToZero()`` first if you need to
    /// restart from the beginning after the previous playback completed.
    func play()

    /// Pauses playback at the current position. Has no effect if playback is already
    /// paused.
    func pause()

    /// Resets the playback position to the start of the current item without changing the
    /// play / pause state.
    func seekToZero()

    /// Seeks to an absolute position within the current item.
    ///
    /// The implementation clamps the target to `[0, totalDuration]`. Non-finite values
    /// and unloaded items are ignored, so callers do not need to pre-validate.
    ///
    /// - Parameter seconds: Absolute position from the start of the item, in seconds
    ///            (not a delta).
    func seek(to seconds: Double)
}

/// Default `AVPlayer`-backed implementation of ``AudioPlaybackProviding``.
///
/// `@MainActor` because `AVPlayer`'s computed properties are `@MainActor`-isolated; the
/// type is only used from ``AudioPlayer``, which is itself `@MainActor`.
@MainActor
final class DefaultAudioPlaybackProvider: AudioPlaybackProviding {

    // MARK: - Properties

    /// The underlying engine. A single instance is reused across track changes via
    /// ``replaceCurrentItem(with:)``.
    private var avPlayer = AVPlayer()

    var playProgress: Double {
        avPlayer.playProgress
    }

    var currentDuration: Double {
        avPlayer.currentDuration
    }

    var totalDuration: Double {
        avPlayer.totalDuration
    }

    // MARK: - Methods

    func loadTotalDuration() async throws -> Double {
        guard let asset = avPlayer.currentItem?.asset else {
            return 0
        }

        let duration = try await asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)

        return seconds.isFinite && seconds >= 0 ? seconds : 0
    }

    func replaceCurrentItem(with url: URL) {
        avPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
    }

    func play() {
        avPlayer.play()
    }

    func pause() {
        avPlayer.pause()
    }

    func seekToZero() {
        avPlayer.seek(to: .zero)
    }

    func seek(to seconds: Double) {
        guard seconds.isFinite,
              let durationSeconds = avPlayer.currentItem?.duration.seconds,
              durationSeconds.isFinite,
              durationSeconds > 0
        else {
            return
        }

        let clamped = min(max(0, seconds), durationSeconds)
        // `CMTimeMakeWithSeconds` does the seconds-to-timescale conversion internally,
        // which avoids the manual `Int64(clamped * 1000)` rounding and makes the intent
        // (millisecond-precision seek) explicit at the call site.
        let time = CMTimeMakeWithSeconds(clamped, preferredTimescale: 1000)

        avPlayer.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
