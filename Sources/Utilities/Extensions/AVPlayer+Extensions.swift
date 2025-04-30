//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
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

extension AVPlayer {

    var playProgress: Double {
        currentItem?.playProgress ?? -1
    }
    
    var currentDuration: Double {
        currentItem?.currentDuration ?? -1
    }
    
    var totalDuration: Double {
        currentItem?.totalDuration ?? -1
    }
}

private extension AVPlayerItem {
    
    var currentDuration: Double {
        Double(CMTimeGetSeconds(currentTime()))
    }

    var totalDuration: Double {
        Double(CMTimeGetSeconds(asset.duration))
    }

    var playProgress: Double {
        currentDuration / totalDuration
    }
}
