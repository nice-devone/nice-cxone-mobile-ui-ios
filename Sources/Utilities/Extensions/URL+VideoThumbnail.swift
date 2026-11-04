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
import SwiftUI
import UIKit

// Video thumbnail generation for a video URL, consumed by `VideoThumbnailView`.
// Kept separate from the general-purpose `URL+Extensions` because it is a single
// cohesive concern with one call site and pulls in AVFoundation.
extension URL {

    // MARK: - Properties

    var videoThumbnailCacheKey: String {
        absoluteString + ":videoThumbnail"
    }

    // MARK: - Methods

    /// Returns a previously generated video thumbnail from the cache, if present.
    ///
    /// Synchronous and cache-only: lets an already-known thumbnail (a seeded snapshot
    /// fixture, or one generated on an earlier appearance) render on the first paint
    /// without waiting for asynchronous generation.
    func cachedVideoThumbnail() -> Image? {
        guard let data = AttachmentCache.shared.data(for: videoThumbnailCacheKey),
              let uiImage = UIImage(data: data) else {
            return nil
        }

        return Image(uiImage: uiImage)
    }

    /// Generates (or returns the cached) thumbnail for the video at this URL.
    ///
    /// Runs asynchronously off the main thread and works for both local files and
    /// remote URLs (the image generator streams remote assets). The previous
    /// synchronous `copyCGImage` could not extract a frame from a not-yet-downloaded
    /// remote URL — and blocked the main thread — so the thumbnail never appeared for
    /// remote videos.
    func getVideoThumbnail() async -> Image? {
        if let cached = cachedVideoThumbnail() {
            return cached
        }

        let asset = AVURLAsset(url: self)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        // Allow a nearby keyframe so generation is fast and doesn't require decoding to an exact frame.
        generator.requestedTimeToleranceBefore = CMTime(seconds: 1, preferredTimescale: 600)
        generator.requestedTimeToleranceAfter = CMTime(seconds: 1, preferredTimescale: 600)

        do {
            // Load the video tracks first. For remote URLs this performs the network
            // load the generator needs — without it, frame extraction fails immediately.
            _ = try await asset.loadTracks(withMediaType: .video)

            let cgImage = try await generator.image(at: CMTime(seconds: 1, preferredTimescale: 600)).image
            let uiImage = UIImage(cgImage: cgImage)

            if let data = uiImage.pngData() {
                AttachmentCache.shared.set(data, for: videoThumbnailCacheKey)
            }

            return Image(uiImage: uiImage)
        } catch {
            error.logError()
            return nil
        }
    }
}
