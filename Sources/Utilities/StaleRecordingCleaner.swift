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

/// Removes voice-message recordings left behind in the recordings directory.
///
/// A clip captured but never sent becomes unreachable as soon as its input bar goes away: the replacement
/// bar starts with a fresh recorder and no `attachmentItem`, so nothing would ever delete the file. The
/// recorder sweeps those up when a new recording starts — an abandoned clip only exists because somebody
/// recorded, so that is the one place the sweep is earned.
///
/// Scoped to `AudioRecorder.recordingsDirectory` rather than the caches root. Downloaded audio attachments
/// cache into the root, and a sent voice message caches under a name that differs from the local recording
/// only in its separators — so a name-based sweep of the root would delete an attachment's cache along with
/// the recordings, leaving a previously playable message unplayable offline.
struct StaleRecordingCleaner: Sendable {

    // MARK: - Properties

    /// Prefix shared by every recorded voice-message file name.
    static let recordingPrefix = "voice_message_"

    /// How old an abandoned recording must be before it is treated as unreachable.
    ///
    /// Deliberately generous. A clip belonging to an input bar that is still on screen — or one whose upload
    /// is still in flight — is minutes old at most, so this age can never delete a file that is still in use,
    /// including one owned by a second input bar alive during a navigation transition.
    static let staleAge: TimeInterval = 60 * 60 * 24

    private let directory: URL?
    private let now: @Sendable () -> Date

    // MARK: - Init

    /// - Parameters:
    ///   - directory: Directory to sweep — `AudioRecorder.recordingsDirectory` in production. Deliberately
    ///     has no default: sweeping the caches root would reach files owned by other subsystems.
    ///   - now: Returns the current date. Injected so the age comparison can be tested.
    init(
        directory: URL?,
        now: @Sendable @escaping () -> Date = { Date.now }
    ) {
        self.directory = directory
        self.now = now
    }

    // MARK: - Methods

    /// Deletes recordings last modified more than `age` ago.
    ///
    /// Best effort throughout — a directory that cannot be listed, or a file that cannot be removed, is
    /// skipped rather than reported, since nothing the customer asked for depends on this succeeding.
    ///
    /// - Parameter age: How old a recording must be to be removed.
    /// - Returns: The number of files removed.
    @discardableResult
    func removeRecordings(olderThan age: TimeInterval) -> Int {
        guard let directory else {
            return 0
        }

        let fileManager = FileManager.default

        guard let files = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else {
            return 0
        }

        let cutoff = now().addingTimeInterval(-age)
        var removedCount = 0

        for file in files where file.lastPathComponent.hasPrefix(Self.recordingPrefix) {
            guard let modificationDate = try? file.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                  modificationDate < cutoff else {
                continue
            }

            do {
                try fileManager.removeItem(at: file)

                removedCount += 1
            } catch {
                error.logError()
            }
        }

        if removedCount > 0 {
            LogManager.trace("Removed \(removedCount) stale voice message recording(s)")
        }

        return removedCount
    }
}
