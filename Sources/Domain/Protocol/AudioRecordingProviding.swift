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
import Mockable

@Mockable
protocol AudioRecordingProviding: AnyObject {

    // MARK: - Properties

    var url: URL? { get }
    var onFinishRecording: (@Sendable (Bool) -> Void)? { get set }
    var onEncodeError: (@Sendable (Error?) -> Void)? { get set }

    // MARK: - Methods

    func setupRecorder(url: URL, settings: [String: Any]) throws
    func record()
    func stop()
    func deleteRecording()
}

// @unchecked Sendable: only accessed from AudioRecorder which is @MainActor; AVAudioRecorder? is mutable but never shared.
final class DefaultAudioRecordingProvider: NSObject, AudioRecordingProviding, @unchecked Sendable {

    // MARK: - Properties

    private var audioRecorder: AVAudioRecorder?

    var url: URL? {
        audioRecorder?.url
    }

    var onFinishRecording: (@Sendable (Bool) -> Void)?
    var onEncodeError: (@Sendable (Error?) -> Void)?

    // MARK: - Methods

    func setupRecorder(url: URL, settings: [String: Any]) throws {
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.delegate = self
    }

    func record() {
        audioRecorder?.record()
    }

    func stop() {
        audioRecorder?.stop()
    }

    func deleteRecording() {
        audioRecorder?.deleteRecording()
    }
}

// MARK: - AVAudioRecorderDelegate

extension DefaultAudioRecordingProvider: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        onFinishRecording?(flag)
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        onEncodeError?(error)
    }
}
