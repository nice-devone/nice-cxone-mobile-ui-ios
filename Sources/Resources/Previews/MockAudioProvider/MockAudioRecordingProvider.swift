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

// MARK: - MockAudioRecordingProvider

/// Preview replacement for `AVAudioRecorder` that captures nothing but tracks how long
/// a "recording" lasted, so the voice-message UI can be exercised in the canvas.
///
/// No file is ever written — `url` is only a placeholder that satisfies the recorder's
/// non-nil URL requirement.
///
/// @unchecked Sendable: only accessed from `AudioRecorder`, which is `@MainActor`.
final class MockAudioRecordingProvider: AudioRecordingProviding, @unchecked Sendable {

    // MARK: - Properties

    private var startDate: Date?

    private(set) var url: URL?

    /// Duration of the last finished recording; `0` until the first `stop()`.
    private(set) var recordedDuration: TimeInterval = 0

    var onFinishRecording: (@Sendable (Bool) -> Void)?
    var onEncodeError: (@Sendable (Error?) -> Void)?

    // MARK: - Methods

    func setupRecorder(url: URL, settings: [String: Any]) throws {
        LogManager.trace("[MOCK] Setup recorder at \(url.lastPathComponent)")

        self.url = url
    }

    func record() {
        LogManager.trace("[MOCK] Record")

        startDate = Date()
    }

    func stop() {
        LogManager.trace("[MOCK] Stop recording")

        if let startDate {
            recordedDuration = Date().timeIntervalSince(startDate)
        }

        startDate = nil

        // Mirrors `AVAudioRecorderDelegate` reporting a successful capture
        onFinishRecording?(true)
    }

    func deleteRecording() {
        LogManager.trace("[MOCK] Delete recording")

        recordedDuration = 0
    }
}

#endif
