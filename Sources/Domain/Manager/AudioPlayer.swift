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
import SwiftUI

class AudioPlayer: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Binding var alertType: ChatAlertType?
    
    @Published var isPlaying = false
    @Published var formattedDuration: String
    @Published var formattedProgress: String
    
    private let audioSession: AVAudioSession = .sharedInstance()
    private let formattedZeroDuration: String
    private let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        
        return formatter
    }()
    private let chatLocalization: ChatLocalization
    
    private var avPlayer: AVPlayer
    private var timer: Timer?
    private var fileName: String

    private(set) var url: URL
    
    var progress: Double {
        avPlayer.playProgress
    }
    
    // MARK: - Lifecycle
    
    init(url: URL, fileName: String, alertType: Binding<ChatAlertType?>, chatLocalization: ChatLocalization) {
        self.url = url
        self.fileName = fileName
        self._alertType = alertType
        self.chatLocalization = chatLocalization
        
        self.avPlayer = AVPlayer()
        self.formattedZeroDuration = formatter.string(from: 0) ?? ""
        self.formattedDuration = formattedZeroDuration
        self.formattedProgress = formattedZeroDuration
    }
    
    deinit {
        reset()
    }
    
    // MARK: - Methods

    func prepare() {
        Task {
            do {
                let fileUrl = try await downloadAndSaveAudioFile(url)
                
                avPlayer.replaceCurrentItem(with: AVPlayerItem(url: fileUrl))
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true)

                _ = await MainActor.run { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.formattedProgress = self.formattedZeroDuration
                    self.formattedDuration = self.formatter.string(from: TimeInterval(self.avPlayer.totalDuration)) ?? self.formattedZeroDuration
                }
            } catch {
                error.logError()
                
                _ = await MainActor.run { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.reset()
                    self.alertType = .genericError(localization: self.chatLocalization)
                }
            }
        }
    }

    func play() {
        LogManager.trace("Playing audio")
        
        isPlaying = true

        if avPlayer.playProgress == 1 {
            avPlayer.seek(to: .zero)
        }
        
        if timer == nil || timer?.isValid == false {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
        
        avPlayer.play()
    }
    
    func pause() {
        LogManager.trace("Pausing audio")
        
        timer?.invalidate()
        avPlayer.pause()
        isPlaying = false
    }
    
    func seek(_ value: Int) {
        LogManager.trace("Adjusting audio footage of \(value)")
        
        guard let duration = avPlayer.currentItem?.duration.seconds else {
            return
        }
        
        let targetTime = CMTimeGetSeconds(avPlayer.currentTime()) + Double(value)
        let newTimeDuration = min(max(0, targetTime), duration)
        let time = CMTimeMake(value: Int64(newTimeDuration * 1000 as Float64), timescale: 1000)
        
        avPlayer.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}

// MARK: - Private methods

private extension AudioPlayer {
    
    func reset() {
        LogManager.trace("Reseting AudioPlayer")
        
        isPlaying = false
        formattedProgress = formattedZeroDuration
        avPlayer.pause()
        timer?.invalidate()
        try? audioSession.setActive(false)
    }
    
    @objc
    func timerAction() {
        formattedProgress = formatter.string(from: TimeInterval(avPlayer.currentDuration)) ?? formattedZeroDuration

        if avPlayer.playProgress >= 1 {
            isPlaying = false
            timer?.invalidate()
        }
    }
    
    func downloadAndSaveAudioFile(_ audioFileUrl: URL) async throws -> URL {
        guard let docDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CommonError.failed("Unable to get Documents directory URL")
        }

        // Sanitize the filename to avoid path issues
        let sanitizedFilename = sanitizeFilename(fileName)
        let fileUrl = docDirectoryUrl.appendingPathComponent(sanitizedFilename)

        if FileManager().fileExists(atPath: fileUrl.path) {
            return fileUrl
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                URLSession.shared.downloadTask(with: audioFileUrl) { (location, response, error) in
                    if let error {
                        continuation.resume(throwing: error)
                    }
                    
                    guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode, let location = location else {
                        continuation.resume(throwing: CommonError.failed("Server error"))
                        return
                    }

                    do {
                        // If destination file already exists, remove it first
                        if FileManager.default.fileExists(atPath: fileUrl.path) {
                            try FileManager.default.removeItem(at: fileUrl)
                        }
                        
                        // Now move the temp file to the final destination
                        try FileManager.default.moveItem(at: location, to: fileUrl)
                        continuation.resume(returning: fileUrl)
                    } catch {
                        LogManager.error("Failed to save audio file: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                }
                .resume()
            }
        }
    }
    
    func sanitizeFilename(_ filename: String) -> String {
        // Replace slashes and other problematic characters with underscores
        let illegalCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        let components = filename.components(separatedBy: illegalCharacters)
        let safeName = components.joined(separator: "_")
        
        // Ensure we don't have path traversal issues
        let lastPathComponent = (safeName as NSString).lastPathComponent
        
        // Limit filename length to avoid filesystem issues and UI display problems
        // while preserving the file extension and most of the original name
        if lastPathComponent.count > 100 {
            let fileExtension = (lastPathComponent as NSString).pathExtension
            let nameWithoutExtension = (lastPathComponent as NSString).deletingPathExtension
            let truncatedName = String(nameWithoutExtension.prefix(90))
            return truncatedName + (fileExtension.isEmpty ? "" : "." + fileExtension)
        }
        
        return lastPathComponent
    }
}
