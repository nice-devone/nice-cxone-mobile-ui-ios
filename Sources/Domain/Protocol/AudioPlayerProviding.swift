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
protocol AudioPlayerProviding: AnyObject {

    // MARK: - Properties

    var currentTime: TimeInterval { get }
    var onFinishPlaying: (@Sendable (Bool) -> Void)? { get set }
    var onDecodeError: (@Sendable (Error?) -> Void)? { get set }

    // MARK: - Methods

    func loadAudio(from url: URL) throws
    func prepareToPlay()
    func play()
    func pause()
    func stop()
}

class DefaultAudioPlayerProvider: NSObject, AudioPlayerProviding {

    // MARK: - Properties

    private var avAudioPlayer: AVAudioPlayer?

    var currentTime: TimeInterval {
        avAudioPlayer?.currentTime ?? 0
    }

    var onFinishPlaying: (@Sendable (Bool) -> Void)?
    var onDecodeError: (@Sendable (Error?) -> Void)?

    // MARK: - Methods

    func loadAudio(from url: URL) throws {
        let player = try AVAudioPlayer(contentsOf: url)
        player.delegate = self
        avAudioPlayer = player
    }

    func prepareToPlay() {
        avAudioPlayer?.prepareToPlay()
    }

    func play() {
        avAudioPlayer?.play()
    }

    func pause() {
        avAudioPlayer?.pause()
    }

    func stop() {
        avAudioPlayer?.stop()
    }
}

// MARK: - AVAudioPlayerDelegate

extension DefaultAudioPlayerProvider: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinishPlaying?(flag)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        onDecodeError?(error)
    }
}
