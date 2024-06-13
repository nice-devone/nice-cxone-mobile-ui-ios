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
import GSPlayer
import SwiftUI

struct VideoPlayer {
    
    // MARK: - Models
    
    enum State {
        
        case loading
        
        case playing(totalDuration: Double)
        
        case paused(playProgress: Double, bufferProgress: Double)
        
        case error(NSError)
    }
    
    // MARK: - Properties
    
    @Binding private var play: Bool
    @Binding private var time: CMTime
    
    private(set) var url: URL
    
    private var mute: Bool = false
    private var onStateChanged: ((State) -> Void)?
    
    // MARK: - Init
    
    init(url: URL, play: Binding<Bool>, time: Binding<CMTime> = .constant(.zero)) {
        self.url = url
        self._play = play
        self._time = time
    }
}

// MARK: - Methods

extension VideoPlayer {
    
    func mute(_ isMuted: Bool) -> Self {
        LogManager.trace("\(isMuted ? "Muting" : "Unmuting") video player")
        
        var view = self
        view.mute = isMuted
        
        return view
    }
    
    func onStateChanged(_ handler: @escaping (State) -> Void) -> Self {
        var view = self
        view.onStateChanged = handler
        
        return view
    }
    
}

// MARK: - UIViewRepresentable

extension VideoPlayer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> VideoPlayerView {
        let uiView = VideoPlayerView()
        
        uiView.contentMode = .scaleAspectFit
        
        uiView.stateDidChanged = { [unowned uiView] _ in
            let state: State = uiView.convertState()
            
            if case .playing = state {
                context.coordinator.startObserver(uiView: uiView)
            } else {
                context.coordinator.stopObserver(uiView: uiView)
            }
            
            DispatchQueue.main.async {
                self.onStateChanged?(state)
            }
        }
        
        return uiView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: VideoPlayerView, context: Context) {
        if context.coordinator.observingURL != url {
            context.coordinator.stopObserver(uiView: uiView)
            context.coordinator.observerTime = nil
            context.coordinator.observingURL = url
        }
        
        if play {
            uiView.play(for: url)
        } else {
            uiView.pause(reason: .userInteraction)
        }
        
        uiView.isMuted = mute
        
        if let observerTime = context.coordinator.observerTime, time != observerTime {
            uiView.seek(to: time, toleranceBefore: time, toleranceAfter: time) { _ in }
        }
    }
    
    static func dismantleUIView(_ uiView: VideoPlayerView, coordinator: VideoPlayer.Coordinator) {
        uiView.pause(reason: .hidden)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject {
    
        // MARK: - Properties
        
        var videoPlayer: VideoPlayer
        var observingURL: URL?
        var observer: Any?
        var observerTime: CMTime?

        // MARK: - Init
        
        init(_ videoPlayer: VideoPlayer) {
            self.videoPlayer = videoPlayer
        }
        
        // MARK: - Methods
        
        func startObserver(uiView: VideoPlayerView) {
            guard observer == nil else {
                return
            }
            
            observer = uiView.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 60)) { [weak self] time in
                self?.videoPlayer.time = time
                self?.observerTime = time
            }
        }
        
        func stopObserver(uiView: VideoPlayerView) {
            guard let observer else {
                return
            }
            
            uiView.removeTimeObserver(observer)
            
            self.observer = nil
        }
    }
}

// MARK: - Helpers

private extension VideoPlayerView {
    
    func convertState() -> VideoPlayer.State {
        switch state {
        case .none, .loading:
            return .loading
        case .playing:
            return .playing(totalDuration: totalDuration)
        case .paused(let progress, let buffer):
            return .paused(playProgress: progress, bufferProgress: buffer)
        case .error(let error):
            return .error(error)
        }
    }
}
