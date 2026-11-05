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

// MARK: - MockAudioPlayerProvider

/// Preview replacement for `AVAudioPlayer` that simulates playback of the clip "captured" by
/// `MockAudioRecordingProvider` — no file is ever read.
///
/// A repeating timer advances `currentTime` and reports completion once the simulated clip
/// length is reached, so the preview can walk the full recorded → playing → recorded cycle.
///
/// @unchecked Sendable: only accessed from `AudioRecorder`, which is `@MainActor`, and from the
/// timer block, which fires on the main run loop the timer was scheduled on.
final class MockAudioPlayerProvider: AudioPlayerProviding, @unchecked Sendable {

    // MARK: - Properties

    /// Playback progress resolution — also the granularity of the simulated `currentTime`.
    private static let tickInterval: TimeInterval = 0.1
    /// Clip length used when nothing has been recorded yet.
    private static let fallbackDuration: TimeInterval = 5

    private let recordingProvider: MockAudioRecordingProvider

    private var timer: Timer?

    private var duration: TimeInterval {
        recordingProvider.recordedDuration > 0 ? recordingProvider.recordedDuration : Self.fallbackDuration
    }

    private(set) var currentTime: TimeInterval = 0

    var onFinishPlaying: (@Sendable (Bool) -> Void)?
    var onDecodeError: (@Sendable (Error?) -> Void)?

    // MARK: - Init

    init(recordingProvider: MockAudioRecordingProvider) {
        self.recordingProvider = recordingProvider
    }

    deinit {
        // The run loop owns the scheduled timer — without this it keeps firing at 10 Hz for the rest of
        // the preview process whenever the canvas re-renders while a simulated clip is still playing.
        // `deinit` can run off the main thread (the recorder drops its callbacks from a `Task`), and
        // `invalidate()` only works on the run loop that scheduled the timer — same hop as `AudioPlayer`
        let timer = self.timer

        Task { @MainActor in
            timer?.invalidate()
        }
    }

    // MARK: - Methods

    func loadAudio(from url: URL) throws {
        LogManager.trace("[MOCK] Load audio from \(url.lastPathComponent)")

        reset()
    }

    func prepareToPlay() {
        LogManager.trace("[MOCK] Prepare to play")
    }

    func play() {
        LogManager.trace("[MOCK] Play")

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: Self.tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        LogManager.trace("[MOCK] Pause")

        timer?.invalidate()
        timer = nil
    }

    func stop() {
        LogManager.trace("[MOCK] Stop")

        reset()
    }
}

// MARK: - Private methods

private extension MockAudioPlayerProvider {

    func tick() {
        currentTime += Self.tickInterval

        guard currentTime >= duration else {
            return
        }

        reset()

        // Mirrors `AVAudioPlayerDelegate` reporting the end of the clip
        onFinishPlaying?(true)
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        currentTime = 0
    }
}

#endif
