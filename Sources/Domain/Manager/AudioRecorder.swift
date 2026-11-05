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
import Combine
import SwiftUI

/// View model that manages recording, playback, and deletion of a voice message attachment.
///
/// `AudioRecorder` drives a state machine (`VoiceMessageState`) that controls the UI.
/// It owns an `AVAudioRecorder` for capture and an `AVAudioPlayer` for playback of the
/// saved recording. A per-second Combine timer updates the `time` and `length` properties
/// used to display elapsed/total duration in the voice-message input bar.
@MainActor
class AudioRecorder: NSObject, ObservableObject {
    
    // MARK: - Objects
    
    /// Represents the lifecycle state of the voice message within the recording flow.
    enum VoiceMessageState {
        /// No recording exists and no activity is in progress.
        case idle
        /// The microphone is actively capturing audio.
        case recording
        /// A recording has been captured and is ready to play or send.
        case recorded
        /// The captured recording is currently being played back.
        case playing
        /// Playback has been paused; the position is preserved for resumption.
        case paused
    }
    
    /// Metadata describing the file format used for a recorded audio clip.
    struct AudioFileType {
        /// The file extension for this format (e.g. `"m4a"`).
        let `extension`: String
        /// The MIME type for this format (e.g. `"audio/x-m4a"`).
        let mimeType: String
    }
    
    // MARK: - Properties
    
    /// Elapsed time in seconds — counts up while recording or playing back.
    @Published var time: TimeInterval = 0
    /// Total duration of the captured recording in seconds, set when recording stops.
    @Published var length: TimeInterval = 0
    /// Current lifecycle state that drives the recording UI.
    @Published var state: VoiceMessageState = .idle
    
    /// Binding to the alert presented by the parent view when an error occurs.
    @Binding var alertType: ChatAlertType?
    
    /// The shared audio session, reconfigured for `.playAndRecord` while capturing.
    private let audioSession: AudioSessionProviding
    /// The active recorder instance; `nil` when idle or after the session is torn down.
    private let audioRecording: AudioRecordingProviding
    /// Player used for playback of the captured recording.
    private let audioPlayer: AudioPlayerProviding
    /// Source of the per-second ticks that advance `time`.
    private let tickProvider: TimerTickProviding
    /// Arbitrates the shared audio session with the attachment players in the conversation.
    private let audioSessionCoordinator: AudioSessionCoordinator
    /// Sweeps up abandoned recordings; `nil` in previews and tests, which must not touch the file system.
    private let staleRecordingCleaner: StaleRecordingCleaner?

    /// Combine subscriptions for the per-second progress timer.
    private var ticks = [AnyCancellable]()
    /// Observer token for the audio session interruption notification.
    /// nonisolated(unsafe): assigned once from the `@MainActor` init and only read again in `deinit` to
    /// unregister, which `NotificationCenter` supports from any thread. Same shape as `AudioPlayer.timer`.
    nonisolated(unsafe) private var interruptionObserver: NSObjectProtocol?

    /// The attachment ready to be sent once a recording is saved; `nil` until `setupRecorder()` succeeds.
    var attachmentItem: AttachmentItem?
    
    /// `time` formatted as `MM:SS` (or `HH:MM:SS` for recordings lasting one hour or more).
    var formattedCurrentTime: String {
        formatted(time)
    }
    /// `length` formatted as `MM:SS` (or `HH:MM:SS` for recordings lasting one hour or more).
    var formattedLength: String {
        formatted(length)
    }
    
    /// The audio format used for all voice message recordings — MPEG-4 AAC in an `.m4a` container.
    nonisolated static let currentAudioFile = AudioFileType(extension: "m4a", mimeType: "audio/x-m4a")

    /// Directory captured voice messages are written to.
    ///
    /// A dedicated subdirectory of Caches rather than its root, so ownership is explicit: audio attachments
    /// cache into the root, and a sent voice message caches under a name that differs from the local
    /// recording only in its separators. Sharing the root would leave `StaleRecordingCleaner` unable to tell
    /// an abandoned recording from an attachment's cache entry.
    nonisolated static var recordingsDirectory: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("VoiceMessages", isDirectory: true)
    }
    
    /// Interval of the progress ticker that advances `time`, in seconds.
    private static let tickInterval: TimeInterval = 1

    // MARK: - Init

    init(
        alertType: Binding<ChatAlertType?>,
        audioSession: AudioSessionProviding = AVAudioSession.sharedInstance(),
        audioRecording: AudioRecordingProviding = DefaultAudioRecordingProvider(),
        audioPlayer: AudioPlayerProviding = DefaultAudioPlayerProvider(),
        tickProvider: TimerTickProviding = DefaultTimerTickProvider(),
        audioSessionCoordinator: AudioSessionCoordinator = .shared,
        staleRecordingCleaner: StaleRecordingCleaner? = StaleRecordingCleaner(directory: AudioRecorder.recordingsDirectory)
    ) {
        self._alertType = alertType
        self.audioSession = audioSession
        self.audioRecording = audioRecording
        self.audioPlayer = audioPlayer
        self.tickProvider = tickProvider
        self.audioSessionCoordinator = audioSessionCoordinator
        self.staleRecordingCleaner = staleRecordingCleaner
        super.init()

        setupDelegateCallbacks()
        setupInterruptionObserver()
    }

    deinit {
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
        }
    }
    
    // MARK: - Methods
    
    /// Requests microphone access if needed, sets up the recorder, and begins capturing audio.
    ///
    /// The method is a no-op if permission is denied (an alert is shown) or if the recorder
    /// cannot be initialized. On success the state transitions to `.recording` and the
    /// per-second progress timer starts. On failure the state resets to `.idle` and a
    /// generic error alert is shown.
    func record() {
        LogManager.trace("Recording voice message")

        Task { [weak self] in
            guard let self else {
                return
            }
            // Check microphone permission before attempting to set up hardware
            guard self.isRecordPermissionGranted() else {
                LogManager.error(.failed("Record permission not granted"))
                return
            }

            self.sweepAbandonedRecordings()

            do {
                try self.setupRecorder()

                guard state != .recording else {
                    LogManager.error(.failed("Unable to record - already recording"))
                    return
                }
                guard audioRecording.url != nil else {
                    LogManager.error(.failed("Unable to record - recorder URL not set"))
                    return
                }

                // Stop any attachment playback first — it cannot be heard once the session switches to
                // `.playAndRecord`, so leaving it running only produces a stuck pause button
                self.audioSessionCoordinator.claimForVoiceMessage()

                try self.audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try self.audioSession.setActive(true, options: [])

                self.time = 0

                self.startTicking()

                audioRecording.record()

                self.state = .recording
            } catch {
                error.logError()

                self.attachmentItem = nil

                do {
                    try self.eraseAudioRecorder(deleteRecording: true)
                } catch {
                    error.logError()
                }

                self.state = .idle
                self.alertType = .genericError
            }
        }
    }

    /// Stops an active recording, saves the file, and transitions the state to `.recorded`.
    ///
    /// Cancels the progress timer immediately so `time` stops incrementing before the
    /// recorder is torn down. On failure the state resets to `.idle` and a generic error
    /// alert is shown.
    func stopRecording() {
        LogManager.trace("Recording has been stopped")

        // Cancel the timer before stopping so `time` reflects the true final value
        ticks.cancel()

        do {
            // Pass `false` to keep the recorded file on disk
            try eraseAudioRecorder(deleteRecording: false)

            state = .recorded
        } catch {
            error.logError()

            attachmentItem = nil

            state = .idle
            alertType = .genericError
        }
    }

    /// Plays back the captured recording from the current position.
    ///
    /// If playback was paused, the player resumes from where it left off. Otherwise a new
    /// `AVAudioPlayer` is created from the recorder's output URL and playback starts from the
    /// beginning. The per-second progress timer is (re-)started in both cases.
    func play() {
        LogManager.trace("Playing recorded voice message")

        guard ![.playing, .recording].contains(state) else {
            LogManager.error(.failed("Recording or already playing."))
            return
        }
        guard let recorderUrl = audioRecording.url else {
            LogManager.error(.failed("Audio Recorder is not set"))
            return
        }

        // Take the session from whichever attachment is playing, the same way `record()` does — otherwise
        // that player still believes it owns the session and both clips play over each other
        audioSessionCoordinator.claimForVoiceMessage()

        // The session was deactivated when the recording was finalized — by the stop button, by a
        // hand-over to an attachment, or by a system interruption. `AVAudioPlayer` produces no output on an
        // inactive session, so re-activate before playing rather than counting the ticker up in silence.
        // The category is set explicitly because it is process-global and sticky: without this, playback
        // would inherit whatever an attachment cell — or the host app — configured last
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
        } catch {
            error.logError()

            // Bail out rather than counting the ticker up over silence — this is a deliberate tap, so
            // unlike the silent `prepare()` prefetch the customer should be told it didn't work
            alertType = .genericError
            return
        }

        // Resume only from `.paused`, never from a non-zero player position: a finished player can still
        // report a non-zero `currentTime`, and resuming there would tick past the end of the clip
        // instead of replaying it
        if state == .paused {
            // Re-read the position the player actually paused at; `time` only ever held whole seconds, so
            // resuming without this loses the fraction of a second below each tick. A zero is ignored for
            // the same reason as in `updateTimer()`: a pause landing in the same instant the clip ends
            // sees a player that has already reset itself, and the label would jump back to 00:00
            if audioPlayer.currentTime > 0 {
                time = audioPlayer.currentTime
            }

            state = .playing
            audioPlayer.play()

            // `pause()` cancelled the ticker — without this the elapsed-time label would stay
            // frozen at the paused position for the rest of the playback
            startTicking()
        } else {
            do {
                try audioPlayer.loadAudio(from: recorderUrl)
                audioPlayer.prepareToPlay()

                // A freshly loaded player always starts at the beginning of the clip
                time = 0

                state = .playing
                audioPlayer.play()

                startTicking()
            } catch {
                error.logError()

                ticks.cancel()
                attachmentItem = nil

                do {
                    try eraseAudioRecorder(deleteRecording: true)
                } catch {
                    error.logError()
                }

                eraseAudioPlayer()

                state = .idle
                alertType = .genericError
            }
        }
    }

    /// Pauses an active playback session.
    ///
    /// Cancels the progress timer and pauses the player, preserving the current position
    /// for resumption via `play()`. Transitions the state to `.paused`.
    func pause() {
        LogManager.trace("Recorded voice message has been paused")

        ticks.cancel()
        audioPlayer.pause()

        state = .paused
    }

    /// Discards the current recording and resets all state to `.idle`.
    ///
    /// Cancels the progress timer, clears `attachmentItem`, stops and deletes the
    /// recorded file, and tears down the audio player.
    func delete() {
        LogManager.trace("Removing recorded voice message")

        ticks.cancel()
        attachmentItem = nil

        do {
            try eraseAudioRecorder(deleteRecording: true)
        } catch {
            error.logError()
        }

        eraseAudioPlayer()

        state = .idle
    }

    /// Steps aside so another component can take the shared audio session, without losing the recording.
    ///
    /// An in-progress capture is finalized rather than discarded — `stopRecording()` closes the file and
    /// moves to `.recorded`, so the customer can still send what they recorded — and playback of an
    /// already-captured clip is paused. Every state except `.idle` then releases the session: `play()`
    /// activates it and `pause()` does not, so a paused or finished preview still holds a claim.
    ///
    /// This is also what the input bar calls as it leaves the view hierarchy: a recording now outlives a
    /// parent re-render, so without it the session would stay active after the customer leaves the thread,
    /// with the microphone indicator lit and their other audio still interrupted. A captured clip is
    /// deliberately left on disk — deleting it here would throw away exactly what the rest of this flow
    /// works to preserve.
    func yieldAudioSession() {
        switch state {
        case .recording:
            LogManager.trace("Finalizing the recording to release the audio session")

            // Finalizing deactivates the session on its way through `eraseAudioRecorder(deleteRecording:)`
            stopRecording()
        case .playing:
            pause()

            deactivateAudioSession()
        case .recorded, .paused:
            deactivateAudioSession()
        case .idle:
            break
        }
    }

}

// MARK: - Private methods

private extension AudioRecorder {

    /// Observes system interruptions of the shared audio session and yields it gracefully.
    ///
    /// In-app hand-overs are announced through `AudioSessionCoordinator`; this covers what the process
    /// cannot see coming — a phone call, Siri, or another app taking the session. Without it the
    /// interruption stops `AVAudioRecorder`, which reports failure through
    /// `handleRecordingFinished(successfully:)` and deletes the file, so a customer interrupted by an
    /// incoming call would lose everything they had recorded.
    func setupInterruptionObserver() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            // The type is read out here because `Notification` cannot cross into the `@MainActor` task
            guard let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: rawType) == .began else {
                return
            }

            Task { @MainActor in
                LogManager.trace("Audio session was interrupted")

                self?.yieldAudioSession()
            }
        }
    }

    func setupDelegateCallbacks() {
        audioRecording.onFinishRecording = { [weak self] flag in
            Task { @MainActor in
                self?.handleRecordingFinished(successfully: flag)
            }
        }
        audioRecording.onEncodeError = { [weak self] error in
            Task { @MainActor in
                self?.handleRecordingEncodeError(error)
            }
        }
        audioPlayer.onFinishPlaying = { [weak self] flag in
            Task { @MainActor in
                self?.handlePlayingFinished(successfully: flag)
            }
        }
        audioPlayer.onDecodeError = { [weak self] error in
            Task { @MainActor in
                self?.handlePlayingDecodeError(error)
            }
        }
    }

    /// Called when the recorder finishes, either because `stop()` was called or due to an interruption.
    ///
    /// - Parameters:
    ///   - recorder: The recorder that finished.
    ///   - flag: `true` if the recording completed successfully.
    ///
    func handleRecordingFinished(successfully flag: Bool) {
        LogManager.trace("Voice message recording did finish \(flag ? "successfully" : "unsuccessfully")")

        ticks.cancel()

        // Successful flag is handled in the trigger place, e.g. "delete" or "stop" method
        if !flag {
            attachmentItem = nil

            do {
                try eraseAudioRecorder(deleteRecording: true)
            } catch {
                error.logError()
            }

            state = .idle
            alertType = .genericError
        }
    }

    /// Called when the recorder encounters an encoding error mid-session.
    ///
    /// - Parameters:
    ///   - recorder: The recorder that failed.
    ///   - error: The underlying encoding error, if available.
    ///
    func handleRecordingEncodeError(_ error: Error?) {
        LogManager.trace("Error occured during encoding")

        error?.logError()

        ticks.cancel()
        attachmentItem = nil

        do {
            try eraseAudioRecorder(deleteRecording: true)
        } catch {
            error.logError()
        }

        state = .idle
        alertType = .genericError
    }

    /// Called when playback of the recorded audio finishes.
    ///
    /// On success the state returns to `.recorded` so the user can play again or send.
    /// On failure the player and recording are torn down and the state resets to `.idle`.
    ///
    /// - Parameters:
    ///   - player: The player that finished.
    ///   - flag: `true` if playback completed without errors.
    ///
    func handlePlayingFinished(successfully flag: Bool) {
        LogManager.trace("Playing recorded voice message did finish \(flag ? "successfully" : "unsuccessfully")")

        ticks.cancel()

        if flag {
            state = .recorded

            // `play()` activated the session and no other path releases it once the clip simply ends —
            // without this the customer's other audio stays interrupted for the rest of their visit
            deactivateAudioSession()
        } else {
            attachmentItem = nil
            eraseAudioPlayer()

            state = .idle
            alertType = .genericError
        }
    }

    /// Called when the player encounters a decoding error.
    ///
    /// - Parameters:
    ///   - player: The player that failed.
    ///   - error: The underlying decoding error, if available.
    ///
    func handlePlayingDecodeError(_ error: Error?) {
        LogManager.trace("Error occured during decoding")

        error?.logError()

        ticks.cancel()
        attachmentItem = nil
        eraseAudioPlayer()

        state = .idle
        alertType = .genericError
    }

    /// Sweeps up clips abandoned by an input bar that went away before they were sent.
    ///
    /// Triggered when a new recording starts rather than from `init`: abandoned clips only exist because
    /// somebody recorded, so this is where the sweep is actually earned. Tying it to construction instead
    /// put file-system work behind every appearance of the input bar — including snapshot renders, which
    /// build `MessageInputView` through `ChatView` and so cannot be handed a `nil` cleaner.
    ///
    /// Best effort and off the main actor. The age check inside the cleaner is what keeps it away from the
    /// recording about to be written here, and from one owned by a second input bar mid-transition.
    func sweepAbandonedRecordings() {
        guard let staleRecordingCleaner else {
            return
        }

        Task.detached {
            staleRecordingCleaner.removeRecordings(olderThan: StaleRecordingCleaner.staleAge)
        }
    }

    /// Releases the shared audio session so other audio sources can resume.
    ///
    /// Used on the paths that hold an active session without an active recorder — playback of a captured
    /// clip — where `eraseAudioRecorder(deleteRecording:)` would be too destructive.
    func deactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: [])
        } catch {
            error.logError()
        }
    }

    /// Stops playback, saves the current `time` as the total `length`, and resets `time` to zero.
    func eraseAudioPlayer() {
        LogManager.trace("Erasing audio player")

        length = time
        time = 0
        audioPlayer.stop()
    }

    /// Stops the recorder, optionally deletes the file on disk, and deactivates the audio session.
    ///
    /// Saves `time` as the final `length` and resets `time` to zero before stopping,
    /// so the duration label reflects the true recording length.
    ///
    /// - Parameter deleteRecording: Pass `true` to permanently delete the audio file (e.g. when
    ///   the user discards or cancels). Pass `false` when transitioning to `.recorded` to keep the file.
    /// - Throws: Any error thrown by `AVAudioSession.setActive(false)`.
    func eraseAudioRecorder(deleteRecording: Bool) throws {
        LogManager.trace("Erasing audio recorder")

        length = time
        time = 0
        audioRecording.stop()

        if deleteRecording {
            audioRecording.deleteRecording()
        }

        try audioSession.setActive(false, options: [])
    }

    /// Starts — or restarts — the ticker that advances `time` while recording or playing.
    ///
    /// Any previous subscription is cancelled first, so the elapsed-time display can never be
    /// driven by two tickers at once.
    func startTicking() {
        ticks.cancel()

        tickProvider.ticks(every: Self.tickInterval)
            .sink { [weak self] _ in
                self?.updateTimer()
            }
            .store(in: &ticks)
    }

    /// Advances the elapsed-time display; called by the Combine timer while recording or playing.
    ///
    /// During playback `time` is read back from the player so the label tracks the true position —
    /// counting ticks instead would drift away from the audio after every pause and resume.
    /// A zero position is ignored rather than displayed: recording has no player to read from, and a
    /// playing `AVAudioPlayer` reports `0` both when it never actually started and once it has reset
    /// itself at the end of the clip, so the label keeps counting instead of snapping back to `00:00`.
    func updateTimer() {
        if state == .playing, audioPlayer.currentTime > 0 {
            time = audioPlayer.currentTime
        } else {
            time += Self.tickInterval
        }
    }

    /// Returns whether the app currently has microphone recording permission.
    ///
    /// - If permission is `.granted`, returns `true` immediately.
    /// - If permission is `.denied`, presents a `microphonePermissionDenied` alert that deep-links
    ///   the user to Settings, then returns `false`.
    /// - If permission is undetermined (`.undetermined`), requests permission from the system
    ///   and returns `false`; the caller should retry after the user responds.
    ///
    /// - Returns: `true` only when `recordPermission == .granted`.
    func isRecordPermissionGranted() -> Bool {
        guard audioSession.recordPermission != .granted else {
            return true
        }

        if audioSession.recordPermission == .denied {
            // Show an alert that deep-links the user to the Settings app to re-enable the microphone
            alertType = .microphonePermissionDenied {
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    LogManager.error("Unable to get Settings URL")
                    return
                }

                Task { @MainActor in
                    UIApplication.shared.open(url)
                }
            }

            return false
        } else {
            // Permission is undetermined — request it and let the system callback handle the result
            audioSession.requestRecordPermission { granted in
                LogManager.trace("Record permission granted: \(granted)")
            }

            return false
        }
    }

    /// Creates the output file URL, configures `AVAudioRecorder` with MPEG-4 AAC settings, and
    /// populates `attachmentItem` with the pending recording metadata.
    ///
    /// The output file is placed in ``recordingsDirectory`` with a timestamped filename.
    /// Recording settings: MPEG-4 AAC format, 12 kHz sample rate, mono, high quality.
    ///
    /// - Throws: Any error thrown by creating the directory or by `AVAudioRecorder.init(url:settings:)`.
    func setupRecorder() throws {
        LogManager.trace("Setting up recorder")

        // Thrown rather than returned: `record()`'s `catch` is what resets to `.idle` and raises the alert,
        // so returning here would leave the customer with a record button that silently does nothing
        guard let recordingsDirectory = Self.recordingsDirectory else {
            throw CommonError.failed("Unable to get voice messages directory")
        }

        // Created on demand: the system can purge anything under Caches between recordings
        try FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)

        // The prefix is shared with `StaleRecordingCleaner`, which sweeps up abandoned recordings by name
        let recordingName = "\(StaleRecordingCleaner.recordingPrefix)\(Date().formatted(format: "HH:mm:ss_dd-MM-YY")).\(Self.currentAudioFile.extension)"
        let bundle = recordingsDirectory.appendingPathComponent(recordingName)

        // MPEG-4 AAC, mono, 12 kHz, high quality — balanced for voice clarity at a small file size
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        try audioRecording.setupRecorder(url: bundle, settings: settings)
        attachmentItem = AttachmentItem(url: bundle, friendlyName: recordingName, mimeType: bundle.mimeType, fileName: recordingName)
    }

    /// Formats a `TimeInterval` as a human-readable duration string.
    ///
    /// Uses `MM:SS` for durations under one hour and `HH:MM:SS` for longer recordings,
    /// padding each component with a leading zero when necessary.
    ///
    /// - Parameter value: The duration in seconds to format.
    /// - Returns: A formatted string such as `"03:47"` or `"1:02:15"`.
    func formatted(_ value: TimeInterval) -> String {
        let components = DateComponentsFormatter()
        // Switch to hour component only when the recording reaches or exceeds 60 minutes
        components.allowedUnits = value >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        components.zeroFormattingBehavior = .pad

        return components.string(from: value) ?? ""
    }
}
