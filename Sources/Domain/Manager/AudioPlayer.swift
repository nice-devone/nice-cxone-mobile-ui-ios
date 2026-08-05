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
import SwiftUI

/// View model that manages playback of a remote audio attachment.
///
/// `AudioPlayer` downloads the audio file to the caches directory on first use, then drives an `AVPlayer`
/// instance to play, pause, and seek within the recording. It publishes formatted progress and duration
/// strings for display in the voice-message cell.
@MainActor
class AudioPlayer: NSObject, ObservableObject {

    // MARK: - Properties

    /// Binding to the alert presented by the parent view when an error occurs.
    @Binding var alertType: ChatAlertType?

    /// Whether playback is currently active.
    @Published var isPlaying = false
    /// Total duration of the audio formatted as `MM:SS`.
    @Published var formattedDuration: String
    /// Current playback position formatted as `MM:SS`.
    @Published var formattedProgress: String
    
    private let audioSession: AudioSessionProviding
    private let audioPlayback: AudioPlaybackProviding
    private let audioFileDownloader: AudioFileDownloading
    /// Pre-computed zero-time string used as the initial and reset value for progress/duration labels.
    private let formattedZeroDuration: String
    private let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]

        return formatter
    }()
    
    /// Repeating timer (0.1 s interval) that drives `formattedProgress` and detects playback completion.
    /// nonisolated(unsafe): captured by value in deinit and invalidated via a `@MainActor` Task hop,
    /// ensuring `invalidate()` runs on the same run loop thread that scheduled the timer.
    nonisolated(unsafe) private var timer: Timer?
    private var fileName: String

    /// The remote URL of the audio attachment.
    private(set) var url: URL

    /// Playback position as a fraction in the range [0, 1].
    var progress: Double {
        audioPlayback.playProgress
    }

    var currentTimeInSeconds: Double {
        audioPlayback.currentDuration
    }

    var duration: Double {
        audioPlayback.totalDuration
    }

    // MARK: - Lifecycle
    
    init(
        url: URL,
        fileName: String,
        alertType: Binding<ChatAlertType?>,
        audioSession: AudioSessionProviding = AVAudioSession.sharedInstance(),
        audioPlayback: AudioPlaybackProviding = DefaultAudioPlaybackProvider(),
        audioFileDownloader: AudioFileDownloading = DefaultAudioFileDownloader()
    ) {
        self.url = url
        self.fileName = fileName
        self._alertType = alertType
        self.audioSession = audioSession
        self.audioPlayback = audioPlayback
        self.audioFileDownloader = audioFileDownloader

        self.formattedZeroDuration = formatter.string(from: 0) ?? ""
        self.formattedDuration = formattedZeroDuration
        self.formattedProgress = formattedZeroDuration
    }

    deinit {
        let timer = self.timer
        
        Task { @MainActor in
            timer?.invalidate()
        }
    }

    // MARK: - Methods

    /// Downloads the audio file (if not already cached) and prepares the player for playback.
    ///
    /// Activates the `AVAudioSession` with `.playback` category and updates `formattedDuration`
    /// once the file is ready. Shows a generic error alert and resets state on failure.
    @MainActor
    func prepare() async {
        LogManager.trace("Preparing audio player")

        do {
            let fileUrl = try await audioFileDownloader.downloadAudioFile(from: url, fileName: fileName)
            audioPlayback.replaceCurrentItem(with: fileUrl)
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: [])

            formattedProgress = safeFormatTimeInterval(0)
            // Awaiting the asset's loaded duration here is required: the synchronous
            // `totalDuration` property returns 0 until the AVAsset finishes loading its
            // metadata, which happens after `replaceCurrentItem`. Reading it inline would
            // freeze `formattedDuration` at "00:00".
            let total = try await audioPlayback.loadTotalDuration()
            formattedDuration = safeFormatTimeInterval(total)
        } catch {
            error.logError()

            reset()
            alertType = .genericError
        }
    }

    /// Starts or resumes playback from the current position.
    ///
    /// Seeks to the beginning when the previous playback reached the end.
    /// Creates the progress timer if it is not already running.
    func play() {
        LogManager.trace("Playing audio")

        isPlaying = true

        // Restart from the beginning when the previous playback completed
        if audioPlayback.playProgress == 1 {
            audioPlayback.seekToZero()
        }

        if timer == nil || timer?.isValid == false {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
        
        audioPlayback.play()
    }

    /// Pauses playback, invalidates the progress timer, and deactivates the audio session.
    func pause() {
        LogManager.trace("Pausing audio")

        timer?.invalidate()
        audioPlayback.pause()
        isPlaying = false
        // Deactivate the session so other audio sources (e.g. music) can resume
        try? audioSession.setActive(false, options: [])
    }

    /// Moves the playback position by the given number of seconds relative to the current position.
    ///
    /// Clamps the result to the valid range [0, duration].
    ///
    /// - Parameter value: Number of seconds to jump; positive seeks forward, negative seeks backward.
    func seek(_ value: Int) {
        LogManager.trace("Adjusting audio footage of \(value)")

        let duration = audioPlayback.totalDuration
        // Belt-and-braces `isFinite` checks on `duration` and (below) on `currentDuration`:
        // `AudioPlaybackProviding` already guarantees finite, non-negative values from its
        // conforming implementations, so in practice these guards never fire. They stay as
        // defensive code against a custom (non-conforming) provider that might surface a
        // raw AVPlayer value where `CMTime.indefinite` collapses to `NaN`.
        guard duration.isFinite, duration > 0 else {
            LogManager.error("Unable to get duration to be able to seek to a specific time")
            return
        }

        let rawCurrent = audioPlayback.currentDuration
        let currentSeconds = rawCurrent.isFinite ? max(0, rawCurrent) : 0
        let targetTime = currentSeconds + Double(value)
        let clampedTargetTime = max(0.0, min(targetTime, duration))
        audioPlayback.seek(to: clampedTargetTime)
    }
}

// MARK: - Private methods

private extension AudioPlayer {
    
    /// Formats a time interval into a positional mm:ss string safely.
    ///
    /// Guards against non-finite (NaN/±infinity) and negative values that can
    /// cause `DateComponentsFormatter` to assert or crash. Non-finite or
    /// negative inputs are treated as 0.
    ///
    /// - Parameter interval: The raw `TimeInterval` to format.
    ///
    /// - Returns: A formatted string or `formattedZeroDuration` when input is invalid.
    func safeFormatTimeInterval(_ interval: TimeInterval) -> String {
        let clamped: TimeInterval = interval.isFinite && interval >= 0 ? interval : 0
        
        return formatter.string(from: clamped) ?? formattedZeroDuration
    }
    
    func reset() {
        LogManager.trace("Resetting AudioPlayer")

        isPlaying = false
        formattedProgress = formattedZeroDuration
        // Also clear formattedDuration so a failed prepare() doesn't leave the UI showing
        // the previous item's duration alongside a zeroed progress label.
        formattedDuration = formattedZeroDuration
        audioPlayback.pause()
        timer?.invalidate()
        try? audioSession.setActive(false, options: [])
    }

    /// Repeating timer callback that updates `formattedProgress` and stops playback when complete.
    ///
    /// - Note: Marked `@objc` for `Timer` selector compatibility. The timer is always scheduled on
    ///   the main run loop (from `@MainActor` context), so this fires on the main thread and can
    ///   mutate state directly without an async Task hop.
    @MainActor @objc
    func timerAction() {
        formattedProgress = safeFormatTimeInterval(TimeInterval(audioPlayback.currentDuration))

        if audioPlayback.playProgress >= 1 {
            isPlaying = false
            timer?.invalidate()
        }
    }
}
