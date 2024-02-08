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

import Foundation

extension String {
    
    // MARK: - Properties
    
    var isSingleEmoji: Bool {
        count == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        contains(where: \.isEmoji)
    }
    
    var containsOnlyEmoji: Bool {
        !isEmpty && !contains { !$0.isEmoji }
    }
    
    var emojiString: String {
        emojis.map(\.description).reduce("", +)
    }
    
    var emojis: [Character] {
        filter(\.isEmoji)
    }
    
    var emojiScalars: [UnicodeScalar] {
        filter(\.isEmoji)
            .flatMap(\.unicodeScalars)
    }
    
    // MARK: - Methods
    
    func nilIfEmpty() -> String? {
        isEmpty ? nil : self
    }
    
    func contains(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) != nil
    }
}

// MARK: - Optional

extension String? {

    var isNilOrEmpty: Bool {
        self?.isEmpty != false
    }
    
    func nilIfEmpty() -> String? {
        isNilOrEmpty ? nil : self
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
