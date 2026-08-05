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

    /// Combine subscriptions for the per-second progress timer.
    private var ticks = [AnyCancellable]()
    /// URL of the most recently loaded recording, used to detect when `audioPlayer` needs reloading.
    private var url: URL?
    
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
    
    // MARK: - Init

    init(
        alertType: Binding<ChatAlertType?>,
        audioSession: AudioSessionProviding = AVAudioSession.sharedInstance(),
        audioRecording: AudioRecordingProviding = DefaultAudioRecordingProvider(),
        audioPlayer: AudioPlayerProviding = DefaultAudioPlayerProvider()
    ) {
        self._alertType = alertType
        self.audioSession = audioSession
        self.audioRecording = audioRecording
        self.audioPlayer = audioPlayer
        super.init()

        setupDelegateCallbacks()
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

                try self.audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try self.audioSession.setActive(true, options: [])

                self.time = 0

                // Tick every second to update the elapsed-time display
                Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in self?.updateTimer() }
                    .store(in: &ticks)

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
    /// If playback was paused and the recorder URL hasn't changed, the player resumes
    /// from where it left off. Otherwise a new `AVAudioPlayer` is created from the
    /// recorder's output URL and playback starts from the beginning. The per-second
    /// progress timer is (re-)started in both cases.
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

        // Resume from the paused position if the URL hasn't changed and the player is mid-file
        if let url, recorderUrl == url, audioPlayer.currentTime != 0 {
            state = .playing
            audioPlayer.play()
        } else {
            do {
                try audioPlayer.loadAudio(from: recorderUrl)
                audioPlayer.prepareToPlay()

                url = audioRecording.url

                state = .playing
                audioPlayer.play()

                // Reset the progress display when starting a fresh playthrough from the beginning
                if audioPlayer.currentTime == 0 {
                    time = 0
                }

                Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in self?.updateTimer() }
                    .store(in: &ticks)
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
}

// MARK: - Private methods

private extension AudioRecorder {

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

    /// Increments `time` by one second; called by the Combine timer while recording or playing.
    func updateTimer() {
        time += 1
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
    /// The output file is placed in the caches directory with a timestamped filename.
    /// Recording settings: MPEG-4 AAC format, 12 kHz sample rate, mono, high quality.
    ///
    /// - Throws: Any error thrown by `AVAudioRecorder.init(url:settings:)`.
    func setupRecorder() throws {
        LogManager.trace("Setting up recorder")

        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            LogManager.error(.failed("Unable to get caches directory"))
            return
        }

        let recordingName = "voice_message_\(Date().formatted(format: "HH:mm:ss_dd-MM-YY")).\(Self.currentAudioFile.extension)"
        let bundle = cachesDirectory.appendingPathComponent(recordingName)

        // MPEG-4 AAC, mono, 12 kHz, high quality — balanced for voice clarity at a small file size
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        try audioRecording.setupRecorder(url: bundle, settings: settings)
        url = audioRecording.url
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
