//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import AVFoundation
import Combine
import SwiftUI

class AudioRecorder: NSObject, ObservableObject {
    
    // MARK: - Objects
    
    enum VoiceMessageState {
        case idle
        case recording
        case recorded
        case playing
        case paused
    }

    struct AudioFileType {
        let `extension`: String
        let mimeType: String
    }
    
    // MARK: - Properties
    
    @Published var time: TimeInterval = 0
    @Published var length: TimeInterval = 0
    @Published var state: VoiceMessageState = .idle
    
    @Binding var alertType: ChatAlertType?
    
    private let localization: ChatLocalization
    private let audioSession: AVAudioSession = .sharedInstance()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer = AVAudioPlayer()
    private var ticks = [AnyCancellable]()
    private var url: URL?
    
    var attachmentItem: AttachmentItem?
    
    var formattedCurrentTime: String {
        formatted(time)
    }
    var formattedLength: String {
        formatted(length)
    }
    
    static let currentAudioFile = AudioFileType(extension: "m4a", mimeType: "audio/x-m4a")

    // MARK: - Init
    
    init(alertType: Binding<ChatAlertType?>, localization: ChatLocalization) {
        self._alertType = alertType
        self.localization = localization
        super.init()
    }
    
    // MARK: - Methods
    
    func record() {
        LogManager.trace("Recording voice message")
        
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            guard self.isRecordPermissionGranted() else {
                LogManager.error(.failed("Record permission not granted"))
                return
            }
            
            do {
                try self.setupRecorder()
                
                guard state != .recording, let audioRecorder else {
                    LogManager.error(.failed("Unable to record - already recording"))
                    return
                }
                
                try self.audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try self.audioSession.setActive(true)
                
                self.time = 0
                
                Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in self.updateTimer() }
                    .store(in: &ticks)
                
                audioRecorder.record()
                
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
                self.alertType = .genericError(localization: localization)
            }
        }
    }
    
    func stopRecording() {
        LogManager.trace("Recording has been stopped")
        
        ticks.cancel()
        
        do {
            try eraseAudioRecorder(deleteRecording: false)
            
            state = .recorded
        } catch {
            error.logError()
            
            attachmentItem = nil
            
            state = .idle
            alertType = .genericError(localization: localization)
        }
    }
    
    func play() {
        LogManager.trace("Playing recorded voice message")
        
        guard ![.playing, .recording].contains(state) else {
            LogManager.error(.failed("Recording or already playing."))
            return
        }
        guard let recorder = audioRecorder else {
            LogManager.error(.failed("Audio Recorder is not set"))
            return
        }
        
        if let url, recorder.url == url, audioPlayer.currentTime != 0 {
            state = .playing
            audioPlayer.play()
        } else {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: recorder.url)
                audioPlayer.delegate = self as AVAudioPlayerDelegate
                audioPlayer.prepareToPlay()
                
                url = audioRecorder?.url
                
                state = .playing
                audioPlayer.play()
                
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
                alertType = .genericError(localization: localization)
            }
        }
    }
    
    func pause() {
        LogManager.trace("Recorded voice message has been paused")
        
        ticks.cancel()
        audioPlayer.pause()
        
        state = .paused
    }
    
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

// MARK: - AVAudioRecorderDelegate

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
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
            alertType = .genericError(localization: localization)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
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
        alertType = .genericError(localization: localization)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioRecorder: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        LogManager.trace("Playing recorded voice message did finish \(flag ? "successfully" : "unsuccessfully")")
        
        ticks.cancel()
        
        if flag {
            state = .recorded
        } else {
            attachmentItem = nil
            eraseAudioPlayer()
            
            state = .idle
            alertType = .genericError(localization: localization)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        LogManager.trace("Error occured during decoding")
        
        error?.logError()
        
        ticks.cancel()
        attachmentItem = nil
        eraseAudioPlayer()
        
        state = .idle
        alertType = .genericError(localization: localization)
    }
}

// MARK: - Private methods

private extension AudioRecorder {
    
    func eraseAudioPlayer() {
        LogManager.trace("Erasing audio player")
        
        length = time
        time = 0
        audioPlayer.stop()
    }
    
    /// Cleans up and stops the current audio recording session.
    ///
    /// This method handles the cleanup of the audio recorder by stopping the recording,
    /// optionally deleting the recorded file, and deactivating the audio session.
    ///
    /// - Parameter deleteRecording: Whether to delete the recorded audio file from storage.
    ///   - Set to `true` when permanently removing a recording (e.g., when deleting or canceling).
    ///   - Set to `false` when transitioning states but keeping the recording (e.g., when stopping a recording to save it).
    /// - Throws: An error if deactivating the audio session fails.
    func eraseAudioRecorder(deleteRecording: Bool) throws {
        LogManager.trace("Erasing audio recorder")
        
        length = time
        time = 0
        audioRecorder?.stop()
        
        if deleteRecording {
            audioRecorder?.deleteRecording()
        }
        
        try audioSession.setActive(false)
    }
    
    func updateTimer() {
        time += 1
    }
    
    func isRecordPermissionGranted() -> Bool {
        guard AVAudioSession.sharedInstance().recordPermission != .granted else {
            return true
        }
        
        if AVAudioSession.sharedInstance().recordPermission == .denied {
            alertType = .microphonePermissionDenied(localization: localization) {
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
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                LogManager.trace("Record permission granted: \(granted)")
            }
            
            return false
        }
    }
    
    func setupRecorder() throws {
        LogManager.trace("Setting up recorder")
        
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            LogManager.error(.failed("Unable to get caches directory"))
            return
        }
        
        let recordingName = "voice_message_\(Date().formatted(format: "HH:mm:ss_dd-MM-YY")).\(Self.currentAudioFile.extension)"
        let bundle = cachesDirectory.appendingPathComponent(recordingName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        audioRecorder = try AVAudioRecorder(url: bundle, settings: settings)
        audioRecorder?.delegate = self as AVAudioRecorderDelegate
        url = audioRecorder?.url
        attachmentItem = AttachmentItem(url: bundle, friendlyName: recordingName, mimeType: bundle.mimeType, fileName: recordingName)
    }
    
    func formatted(_ value: TimeInterval) -> String {
        let components = DateComponentsFormatter()
        components.allowedUnits = value >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        components.zeroFormattingBehavior = .pad
        
        return components.string(from: value) ?? ""
    }
}
