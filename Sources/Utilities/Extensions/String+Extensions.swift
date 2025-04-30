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

import Foundation

extension String {
    
    // MARK: - Properties
    
    private static let maxEmojiCountForLargeTitle = 3
    
    var isLargeEmoji: Bool {
        self.containsOnlyEmoji && self.count <= Self.maxEmojiCountForLargeTitle
    }
    
    var containsOnlyEmoji: Bool {
        !isEmpty && !contains { !$0.isEmoji }
    }
    
    // MARK: - Methods
    
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
}

// MARK: - Helpers

private extension Character {
    
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else {
            return false
        }
        
        // 0x203C is the first instance of UTF16 emoji that requires no modifier.
        return firstScalar.properties.isEmoji && firstScalar.value > 0x203C
    }
    
    var isCombinedIntoEmoji: Bool {
        unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false
    }
    
    var isEmoji: Bool {
        isSimpleEmoji || isCombinedIntoEmoji
    }
}
