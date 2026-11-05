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

import SwiftUI

#if DEBUG

extension AudioRecorder {

    /// Creates a recorder wired to the in-memory preview providers instead of the audio hardware.
    ///
    /// Previews run inside `XCPreviewAgent`, which has no `NSMicrophoneUsageDescription` in its
    /// `Info.plist` — the real `AVAudioSession` permission check terminates the agent with a TCC
    /// privacy violation as soon as the record button is tapped. The preview providers simulate the
    /// whole record → play → delete flow without touching the microphone or the file system.
    ///
    /// - Parameter alertType: Binding used by the recorder to surface errors.
    /// - Returns: A recorder safe to drive from a SwiftUI preview.
    static func preview(alertType: Binding<ChatAlertType?> = .constant(nil)) -> AudioRecorder {
        let audioRecording = MockAudioRecordingProvider()

        return AudioRecorder(
            alertType: alertType,
            audioSession: MockAudioSessionProvider(),
            audioRecording: audioRecording,
            audioPlayer: MockAudioPlayerProvider(recordingProvider: audioRecording),
            // No cleaner, so the canvas never enumerates or deletes anything in the preview agent's caches
            staleRecordingCleaner: nil
        )
    }
}

#endif
