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

extension URL {

    /// A stable, launch-independent digest of the absolute URL, usable as a
    /// filesystem-safe directory name for per-URL attachment caches.
    ///
    /// Swift's `hashValue` is per-process randomized (so it can't be persisted across
    /// launches); this fixed FNV-1a hash is deterministic and needs no crypto
    /// dependency for a cache key. Shared by the document and video caches so two
    /// attachments that happen to share a friendly filename never collide on disk.
    var stableCacheDigest: String {
        var digest: UInt64 = 14_695_981_039_346_656_037 // FNV-1a offset basis
        for byte in absoluteString.utf8 {
            digest = (digest ^ UInt64(byte)) &* 1_099_511_628_211 // FNV-1a prime
        }

        return String(digest, radix: 16)
    }

    /// The on-disk location an attachment is cached at: a per-URL subdirectory — named
    /// from `stableCacheDigest` so two attachments that share a friendly `fileName`
    /// (e.g. two `Scan.pdf` / `video.mov` from different senders) never collide —
    /// containing the file under its friendly name so previews show a meaningful title.
    ///
    /// Shared by the document and video caches so both read and write resolve through
    /// the same layout and can't drift. Carries no actor isolation, so background download
    /// tasks can compute it off the main actor.
    func attachmentCacheURL(fileName: String) -> URL? {
        guard let cachesPath = FileManager.default.cachesDirectory else {
            return nil
        }

        return cachesPath
            .appendingPathComponent(stableCacheDigest, isDirectory: true)
            .appendingPathComponent(fileName)
    }
}
