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

import CryptoKit
import Foundation

// `@unchecked Sendable` is intentional and permanent:
// - All mutable in-memory state is an `NSCache<NSString, NSData>`, which Apple
//   documents as safe for use from multiple threads without additional locking.
// - All disk writes use `Data.write(to:options:.atomic)` which writes to a
//   temporary file and renames it atomically, preventing partial reads.
// No additional synchronisation is required.
final class AttachmentCache: @unchecked Sendable {
    
    // MARK: - Properties
    
    static let shared = AttachmentCache()
    
    private let cache = NSCache<NSString, NSData>()

    private let diskCacheURL: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let url = urls[0].appendingPathComponent("AttachmentThumbnails")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        
        return url
    }()

    // MARK: - Methods
    
    func data(for key: String) -> Data? {
        // Check in-memory cache first
        if let data = cache.object(forKey: key as NSString) as Data? {
            return data
        }
        
        // Check disk cache
        let fileURL = diskCacheURL.appendingPathComponent(key.sha256())
        
        return try? Data(contentsOf: fileURL)
    }

    func set(_ data: Data, for key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
        let fileURL = diskCacheURL.appendingPathComponent(key.sha256())
        
        try? data.write(to: fileURL, options: .atomic)
    }
}

// MARK: - Helpers

private extension String {
    
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
