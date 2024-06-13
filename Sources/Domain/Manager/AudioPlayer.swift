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
import SwiftUI

class AudioPlayer: NSObject, ObservableObject {
    
    // MARK: - Properties
    
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
    
    private var avPlayer: AVPlayer
    private var timer: Timer?
    private var fileName: String

    private(set) var url: URL
    
    var progress: Double {
        avPlayer.playProgress
    }
    
    // MARK: - Lifecycle
    
    init(url: URL, fileName: String) {
        self.url = url
        self.fileName = fileName
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
                
                do {
                    avPlayer.replaceCurrentItem(with: AVPlayerItem(url: fileUrl))
                    try audioSession.setCategory(.playback, mode: .default)
                    try audioSession.setActive(true)

                    Task { @MainActor in
                        formattedProgress = formattedZeroDuration
                        formattedDuration = formatter.string(from: TimeInterval(avPlayer.totalDuration)) ?? formattedZeroDuration
                    }
                } catch {
                    error.logError()
                }
            } catch {
                error.logError()
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

        let fileUrl = docDirectoryUrl.appendingPathComponent(fileName)

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
                        try FileManager.default.moveItem(at: location, to: fileUrl)
                        continuation.resume(returning: fileUrl)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                .resume()
            }
        }
    }
}
