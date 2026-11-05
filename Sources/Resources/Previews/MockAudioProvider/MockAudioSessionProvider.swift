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

#if DEBUG

// MARK: - MockAudioSessionProvider

/// Preview replacement for `AVAudioSession` that never touches the audio hardware.
///
/// Reading `AVAudioSession.recordPermission` or calling `requestRecordPermission` inside
/// `XCPreviewAgent` terminates the preview process with a TCC privacy violation, because the
/// agent's `Info.plist` has no `NSMicrophoneUsageDescription`. This stub reports the permission
/// as already granted and no-ops every session mutation.
///
/// @unchecked Sendable: stateless — all members are constants or no-ops.
final class MockAudioSessionProvider: AudioSessionProviding, @unchecked Sendable {

    // MARK: - Properties

    var recordPermission: AVAudioSession.RecordPermission { .granted }

    // MARK: - Methods

    func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws {
        LogManager.trace("[MOCK] Set audio session category: \(category.rawValue), mode: \(mode.rawValue)")
    }

    func setCategory(_ category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions) throws {
        LogManager.trace("[MOCK] Set audio session category: \(category.rawValue)")
    }

    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
        LogManager.trace("[MOCK] Set audio session active: \(active)")
    }

    func requestRecordPermission(_ response: @escaping (Bool) -> Void) {
        LogManager.trace("[MOCK] Request record permission")

        response(true)
    }
}

#endif
