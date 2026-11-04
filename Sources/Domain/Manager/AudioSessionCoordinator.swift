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

/// Hands the single shared `AVAudioSession` between the voice-message recorder in the input bar and the
/// audio attachment players in the conversation.
///
/// Only one of them can own the session at a time: activating `.playback` for an attachment takes the
/// input route away from an in-progress recording, and `AVAudioRecorder` then reports failure — the path
/// that discards the capture. So instead of claiming the session outright, a component announces the
/// hand-over first and the current owner steps aside gracefully: a recording is finalized (the clip stays
/// on disk and remains sendable) and playback is paused.
///
/// This coordinates *in-app* hand-overs only. Changing the category on the process's own shared session
/// posts no interruption notification, so system interruptions (a call, Siri, another app) are handled
/// separately by `AudioRecorder`'s interruption observer.
@MainActor
class AudioSessionCoordinator {

    // MARK: - Properties

    /// The instance every audio component in the module talks to by default.
    static let shared = AudioSessionCoordinator()

    /// Yields the session on behalf of the voice-message recorder, keeping whatever it captured.
    ///
    /// Registered by the input bar while it is on screen — see ``setPlaybackClaimHandler(owner:_:)``.
    private var onPlaybackClaim: (() -> Void)?
    /// The recorder whose handler is currently registered, so a departing input bar cannot remove another's.
    private weak var claimHandlerOwner: AnyObject?

    /// The attachment player currently holding the session, if any.
    private weak var activePlayer: AudioPlayer?

    // MARK: - Methods

    /// Registers the handler that yields the session on behalf of `owner`.
    ///
    /// - Parameters:
    ///   - owner: The object the handler belongs to; only it can remove the handler again.
    ///   - handler: Called before another component claims the session.
    func setPlaybackClaimHandler(owner: AnyObject, _ handler: @escaping () -> Void) {
        claimHandlerOwner = owner
        onPlaybackClaim = handler
    }

    /// Removes `owner`'s handler, but only while it is still the registered one.
    ///
    /// The guard matters during a navigation transition: the incoming input bar's `onAppear` can run before
    /// the outgoing one's `onDisappear`, and an unconditional removal would wipe the handler the new bar just
    /// registered — leaving attachment playback free to destroy an in-progress recording again.
    ///
    /// - Parameter owner: The object whose handler should be removed.
    func resignPlaybackClaimHandler(owner: AnyObject) {
        // `claimHandlerOwner` is weak, so a nil one means the registering bar is already gone and the stale
        // handler is nobody's to keep — clearing it there stops it lingering until the next registration
        guard claimHandlerOwner === owner || claimHandlerOwner == nil else {
            LogManager.trace("Keeping the playback claim handler - it belongs to another voice message")
            return
        }

        claimHandlerOwner = nil
        onPlaybackClaim = nil
    }

    /// Announces that `player` is about to claim the session for playback.
    ///
    /// - Parameter player: The player taking over the session.
    func claimForPlayback(_ player: AudioPlayer) {
        LogManager.trace("Handing the audio session over to playback")

        // The outgoing attachment stops first — only one can own the session, so the previous one would
        // otherwise play on inaudibly underneath the new one. Doing it before announcing the hand-over also
        // means the recorder's own release lands on an idle session: `setActive(false)` fails with
        // `AVAudioSessionErrorCodeIsBusy` while another player is still running
        if activePlayer !== player {
            activePlayer?.pause()
        }

        onPlaybackClaim?()

        activePlayer = player
    }

    /// Announces that the voice-message input bar is about to claim the session — to capture a new
    /// recording, or to play back one it already captured.
    func claimForVoiceMessage() {
        LogManager.trace("Handing the audio session over to the voice message")

        activePlayer?.pause()
        activePlayer = nil
    }
}
