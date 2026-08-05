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

extension AVPlayer {

    /// Fractional playback progress in `[0, 1]`, or `0` when no item is loaded or the
    /// active asset's duration hasn't loaded yet (`<= 0` always means "unknown").
    var playProgress: Double {
        currentItem?.playProgress ?? 0
    }

    /// Current playback time in seconds, or `0` when no item is loaded or the underlying
    /// `CMTime` is non-finite. Callers can rely on a finite, non-negative value.
    var currentDuration: Double {
        currentItem?.currentDuration ?? 0
    }

    /// Total duration of the active item in seconds, or `0` when no item is loaded or
    /// the asset's duration hasn't loaded yet. Callers should treat `<= 0` as "unknown".
    var totalDuration: Double {
        currentItem?.totalDuration ?? 0
    }
}

private extension AVPlayerItem {

    /// `currentTime` in seconds with a finite-and-non-negative guarantee. Non-finite or
    /// negative `CMTime` values (e.g. before the asset is ready) collapse to `0`.
    var currentDuration: Double {
        let seconds = CMTimeGetSeconds(currentTime())

        return seconds.isFinite && seconds >= 0 ? seconds : 0
    }

    /// Total `duration` in seconds. `AVPlayerItem.duration` is `CMTime.indefinite` until
    /// the underlying asset finishes loading, which produces `NaN` through
    /// `CMTimeGetSeconds`; this guard ensures callers never see `NaN` or negative values.
    var totalDuration: Double {
        let seconds = CMTimeGetSeconds(duration)

        return seconds.isFinite && seconds >= 0 ? seconds : 0
    }

    /// `currentDuration / totalDuration`, normalised so an unloaded asset returns `0`
    /// rather than a division-by-zero `NaN` or `inf`. Always falls in `[0, 1]` when the
    /// asset is loaded; returns `0` when unknown.
    var playProgress: Double {
        let total = totalDuration
        guard total > 0 else {
            return 0
        }

        return min(max(0, currentDuration / total), 1)
    }
}
