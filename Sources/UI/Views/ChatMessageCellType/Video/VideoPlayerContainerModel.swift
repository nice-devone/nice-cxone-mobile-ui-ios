//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

class VideoPlayerContainerModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var time: CMTime = .zero
    @Published var play = true
    @Published var mute = false
    @Published var totalDuration = 0.0
    @Published var waitingOverlayToHide = false
    @Published var showOverlay: Bool = false {
        didSet {
            if showOverlay && !waitingOverlayToHide {
                waitingOverlayToHide = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        self.showOverlay = false
                        self.waitingOverlayToHide = false
                    }
                }
            }
        }
    }
    
    private let formattedZeroDuration: String
    
    private var timeHMSFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        
        return formatter
    }()
    
    let videoUrl: URL

    var formattedTime: String {
        guard !time.seconds.isNaN, let text = timeHMSFormatter.string(from: time.seconds) else {
            return formattedZeroDuration
        }
        
        return text
    }
    var formattedDuration: String {
        guard !totalDuration.isNaN, let text = timeHMSFormatter.string(from: totalDuration) else {
            return formattedZeroDuration
        }
        
        return text
    }
    
    // MARK: - Init
    
    init(videoUrl: URL) {
        self.videoUrl = videoUrl
        self.formattedZeroDuration = timeHMSFormatter.string(from: 0) ?? ""
    }
    
    // MARK: - Methods
    
    func onStateChanged(_ state: VideoPlayer.State) {
        guard case .playing(let totalDuration) = state else {
            return
        }
        
        if time.seconds == totalDuration {
            self.time = CMTimeMakeWithSeconds(0, preferredTimescale: time.timescale)
        }
        
        self.totalDuration = totalDuration
    }
    
    func onRewind() {
        time = CMTimeMakeWithSeconds(max(0, time.seconds - 10), preferredTimescale: time.timescale)
    }
    
    func onAdvance() {
        time = CMTimeMakeWithSeconds(min(totalDuration, time.seconds + 10), preferredTimescale: time.timescale)
    }
}
