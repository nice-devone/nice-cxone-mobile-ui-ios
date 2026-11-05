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

import CXoneChatSDK
import UniformTypeIdentifiers

extension UTType {
    
    static let imagePrefix = "image/"
    static let videoPrefix = "video/"
    static let audioPrefix = "audio/"
    
    static func resolve(for mimeType: String) -> UTType? {
        guard mimeType.contains("*") else {
            return UTType(mimeType: mimeType)
        }
        guard let contentType = mimeType.split(separator: "/").first else {
            return nil
        }
        
        // UTType(mimeType:) resolves "image/*" as "dyn.agq80w5pbq7ww8nu" UTType which is a representation of dynamic UTType
        // that is not appliable for MediaPicker and DocumentPicker
        return UTType("public.\(contentType)")
    }
    
    static func resolve(for allowedFileType: [String]) -> [UTType] {
        var result = allowedFileType.compactMap(UTType.resolve)
        
        let allowsVideo = allowedFileType.contains { fileType in
            fileType.contains(UTType.videoPrefix)
        }

        if allowsVideo {
            result.append(UTType.movie)
        }
        
        return result
    }
}
