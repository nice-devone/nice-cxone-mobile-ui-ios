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

    // MARK: - Objects

    /// How far `prepare()` has got with fetching the attachment and loading it into the player.
    enum PreparationState: Equatable {
        /// `prepare()` has not run yet.
        case idle
        /// The attachment is being downloaded — playback is possible, just not yet.
        case preparing
        /// The attachment is loaded and playback can start.
        case ready
        /// The attachment could not be fetched or loaded.
        case failed
    }

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
    private let audioSessionCoordinator: AudioSessionCoordinator
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
    /// How far `prepare()` has got with the attachment.
    private var preparationState: PreparationState = .idle
    /// Whether the customer asked for playback while `prepare()` was still downloading.
    private var shouldPlayWhenReady = false
    /// Bumped by every `prepare()`, so a superseded run cannot write state that belongs to a newer one.
    private var preparationGeneration = 0

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
        audioFileDownloader: AudioFileDownloading = DefaultAudioFileDownloader(),
        audioSessionCoordinator: AudioSessionCoordinator = .shared
    ) {
        self.url = url
        self.fileName = fileName
        self._alertType = alertType
        self.audioSession = audioSession
        self.audioPlayback = audioPlayback
        self.audioFileDownloader = audioFileDownloader
        self.audioSessionCoordinator = audioSessionCoordinator

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
    /// Updates `formattedDuration` once the file is ready. Runs from `.task` on every appearance, so a
    /// failure resets the labels and fails quietly — `play()` surfaces it when the customer asks for the
    /// audio. The shared `AVAudioSession` is deliberately left untouched here — see `play()`.
    @MainActor
    func prepare() async {
        LogManager.trace("Preparing audio player")

        // A pending tap is only dropped when this call supersedes a preparation that is still in flight: that
        // tap belongs to an appearance which is already gone, and keeping it would start playback on its own
        // when the cell scrolls back into view. A tap made while `.idle` — between the cell appearing and
        // `.task` getting here — is a live request, so it survives and is honoured below
        if preparationState == .preparing, shouldPlayWhenReady {
            shouldPlayWhenReady = false
            isPlaying = false
        }

        preparationGeneration += 1
        let generation = preparationGeneration
        preparationState = .preparing

        do {
            let fileUrl = try await audioFileDownloader.downloadAudioFile(from: url, fileName: fileName)

            // Both boundaries that write player state are guarded the same way: superseded runs return
            // silently because the newer run owns that state now, while a cancelled run throws so the `catch`
            // below can reset it. Checked before the first mutation, not just before the state transition, so
            // neither can reset the item or the progress label of a playback a newer run has already started
            guard isCurrent(generation) else {
                return
            }

            // Cancellation is asserted rather than relied on to surface as a throw: `DefaultAudioFileDownloader`
            // resumes its continuation normally when the `URLSession` download completes, and the cached branch
            // never suspends at all
            try Task.checkCancellation()

            audioPlayback.replaceCurrentItem(with: fileUrl)

            formattedProgress = safeFormatTimeInterval(0)
            // Awaiting the asset's loaded duration here is required: the synchronous
            // `totalDuration` property returns 0 until the AVAsset finishes loading its
            // metadata, which happens after `replaceCurrentItem`. Reading it inline would
            // freeze `formattedDuration` at "00:00".
            let total = try await audioPlayback.loadTotalDuration()

            // The same pair again — a newer run can have taken over, or this one been cancelled, while the
            // duration was loading. Without the cancellation half, a latched tap on a cell that has since
            // scrolled away would fall through to `play()` below: audio starting unprompted
            guard isCurrent(generation) else {
                return
            }

            try Task.checkCancellation()

            formattedDuration = safeFormatTimeInterval(total)

            preparationState = .ready

            // The customer tapped play while the download was still running — honour it now
            if shouldPlayWhenReady {
                shouldPlayWhenReady = false

                play()
            }
        } catch {
            // Same as above: a superseded run must not undo the newer one's state
            guard isCurrent(generation) else {
                return
            }

            // A cancelled `.task` means the cell scrolled away, not that anything failed: no alert, and
            // `.idle` rather than `.failed` so the next appearance can prepare (and play) normally
            if Task.isCancelled || error is CancellationError {
                LogManager.trace("Audio preparation was cancelled")

                preparationState = .idle
                shouldPlayWhenReady = false
                isPlaying = false
                return
            }

            error.logError()

            preparationState = .failed

            reset()

            // Usually nothing here is user-initiated — this runs whenever the cell appears — so it fails
            // quietly: an alert would pop over the conversation on its own, once per audio cell in a
            // thread full of them. The exception is a customer already waiting on this playback.
            if shouldPlayWhenReady {
                shouldPlayWhenReady = false

                alertType = .genericError
            }
        }
    }

    /// Starts or resumes playback from the current position.
    ///
    /// Activates the `AVAudioSession` with the `.playback` category, seeks to the beginning when the
    /// previous playback reached the end, and creates the progress timer if it is not already running.
    /// While the attachment is still downloading the request is remembered and starts once it lands.
    /// Shows a generic error alert and does nothing when the audio failed to load or the session is refused.
    func play() {
        LogManager.trace("Playing audio")

        switch preparationState {
        case .ready:
            break
        case .idle, .preparing:
            // Nothing has failed — the download is in flight, or `.task` is about to start it — so remember
            // the request and start as soon as `prepare()` lands. `isPlaying` flips now so the button
            // reflects the pending playback rather than looking like a dead tap
            LogManager.trace("Audio is still being prepared - playback is pending")

            shouldPlayWhenReady = true
            isPlaying = true
            return
        case .failed:
            // Without a loaded item, claiming the session would interrupt the customer's other audio for
            // a playback that cannot produce sound
            LogManager.error(.failed("Audio is not ready to be played"))

            isPlaying = false
            alertType = .genericError
            return
        }

        // Let the current owner step aside first: a voice message being recorded is finalized (and stays
        // sendable) instead of being destroyed by the category flip below
        audioSessionCoordinator.claimForPlayback(self)

        // Claim the shared session here rather than in `prepare()`: a cell merely scrolling into view
        // must not take the session away from an in-progress voice-message recording
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
        } catch {
            error.logError()

            // Bail out instead of falling through: `AVPlayer` cannot output on a session it was refused,
            // so continuing would leave the cell showing the pause icon with no sound and no way back.
            // `isPlaying` is cleared rather than left alone because a deferred playback already set it —
            // `prepare()` calls this itself once a latched tap resolves
            isPlaying = false
            alertType = .genericError
            return
        }

        isPlaying = true

        // Restart from the beginning when the previous playback completed
        if isPlaybackFinished {
            audioPlayback.seekToZero()
        }

        if timer == nil || timer?.isValid == false {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
        
        audioPlayback.play()
    }

    /// Pauses playback, invalidates the progress timer, and deactivates the audio session.
    ///
    /// Also cancels a playback still waiting on `prepare()`, so a download that lands after the customer
    /// changed their mind doesn't start playing on its own.
    func pause() {
        LogManager.trace("Pausing audio")

        shouldPlayWhenReady = false

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
        let currentSeconds = rawCurrent.finiteNonNegative
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
        let clamped: TimeInterval = interval.finiteNonNegative
        
        return formatter.string(from: clamped) ?? formattedZeroDuration
    }
    
    /// Whether the playback has reached the end of the clip.
    var isPlaybackFinished: Bool {
        audioPlayback.playProgress >= 1
    }

    /// Whether `generation` is still the newest `prepare()` run.
    ///
    /// A run that has been superseded must not write player state — the newer one owns it now.
    ///
    /// - Parameter generation: The generation captured when the run started.
    /// - Returns: `true` while this run is still the current one.
    func isCurrent(_ generation: Int) -> Bool {
        guard generation == preparationGeneration else {
            LogManager.trace("Discarding a superseded audio preparation")

            return false
        }

        return true
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
        // The session is deliberately not deactivated here: `reset()` runs from a failed `prepare()`,
        // which never claimed it, and deactivating would cut off whoever does own it — an in-progress
        // voice-message recording or another cell's playback
    }

    /// Repeating timer callback that updates `formattedProgress` and stops playback when complete.
    ///
    /// - Note: Marked `@objc` for `Timer` selector compatibility. The timer is always scheduled on
    ///   the main run loop (from `@MainActor` context), so this fires on the main thread and can
    ///   mutate state directly without an async Task hop.
    @MainActor @objc
    func timerAction() {
        formattedProgress = safeFormatTimeInterval(TimeInterval(audioPlayback.currentDuration))

        if isPlaybackFinished {
            isPlaying = false
            timer?.invalidate()
            // Mirrors `pause()`: hand the session back when the clip ends, so other audio sources resume
            try? audioSession.setActive(false, options: [])
        }
    }
}
