//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
    
    // MARK: - Enums
    
    enum VoiceMessageState {
        case idle
        case recording
        case recorded
        case playing
        case paused
    }

    // MARK: - Properties
    
    @Published var time: TimeInterval = 0
    @Published var length: TimeInterval = 0
    @Published var state: VoiceMessageState = .idle
    
    private let audioSession: AVAudioSession = .sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer = AVAudioPlayer()
    private var ticks = [AnyCancellable]()
    private var url: URL?
    
    var attachmentItem: AttachmentItem?
    var currentProgress: Float = 0
    
    var formattedCurrentTime: String {
        formatted(time)
    }
    var formattedLength: String {
        formatted(length)
    }
    
    // MARK: - Methods
    
    func record() {
        LogManager.trace("Recording voice message")
        
        Task { @MainActor in
            guard await isRecordPermissionGranted() else {
                LogManager.error(.failed("Record permission not granted"))
                return
            }
            
            do {
                try setupRecorder()
                
                guard state != .recording, let recorder = self.audioRecorder else {
                    LogManager.error(.failed("Unable to record - already recording"))
                    return
                }
                
                try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try audioSession.setActive(true)
                
                time = 0
                currentProgress = 0
                
                Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in self?.updateTimer() }
                    .store(in: &ticks)
                
                recorder.record()
                state = .recording
            } catch {
                error.logError()
            }
        }
    }
    
    func pause() {
        LogManager.trace("Recorded voice message has been paused")
        
        state = .paused
        audioPlayer.pause()
        
        ticks.cancel()
    }
    
    func stop() {
        LogManager.trace("Recording has been stopped")
        
        ticks.cancel()
        
        length = time
        time = 0
        state = .recorded
        audioRecorder?.stop()
        
        do {
            try audioSession.setActive(false)
        } catch {
            error.logError()
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
                    currentProgress = 0
                }
                
                Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in self?.updateTimer() }
                    .store(in: &ticks)
            } catch {
                error.logError()
            }
        }
    }
    
    func delete() {
        LogManager.trace("Removing recorded voice message")
        
        if let audioRecorder, audioRecorder.deleteRecording() {
            attachmentItem = nil
            state = .idle
        } else {
            LogManager.error(.failed("Unable to delete recorded file"))
        }
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        LogManager.trace("Voice message recording did finish")
        
        currentProgress = 1
        state = .recorded
        
        ticks.cancel()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        LogManager.trace("Error occured during encoding")
        
        if let error {
            error.logError()
        }
        
        state = .idle
        ticks.cancel()
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioRecorder: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        LogManager.trace("Playing recorded voice message did finish")
        
        ticks.cancel()
        
        state = .recorded
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        LogManager.trace("Error occured during decoding")
        
        guard let error else {
            return
        }
        
        error.logError()
    }
}

// MARK: - Private methods

private extension AudioRecorder {
    
    func updateTimer() {
        time += 1
        
        currentProgress = Float(time / audioPlayer.duration.rounded())
    }
    
    func isRecordPermissionGranted() async -> Bool {
        guard AVAudioSession.sharedInstance().recordPermission != .granted else {
            return true
        }
        
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func setupRecorder() throws {
        LogManager.trace("Setting up recorder")
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            LogManager.error(.failed("Unable to get document directory"))
            return
        }
        
        let recordingName = "voice_message_\(Date().formatted(format: "HH:mm:ss_dd-MM-YY")).m4a"
        let bundle = documentDirectory.appendingPathComponent(recordingName)
        
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
