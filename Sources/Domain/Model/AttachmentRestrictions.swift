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

import CXoneChatSDK

struct AttachmentRestrictions {
    
    /// Maximum size of allowed uploads in megabytes (1024x1024).
    let allowedFileSize: Int32
    
    /// Allowed file mime types.
    let allowedTypes: [String]
    
    /// True if attachment uploads are allowed.  If false, no uploads are allowed.
    let areAttachmentsEnabled: Bool
    
    /// True if audio files upload is allowed.
    ///
    /// Audio files are allowed if the allowed types contain `audio/*`
    /// or if the allowed types contain any of the audio mime types related to the currently used voice message file type.
    var areVoiceMessagesEnabled: Bool {
        allowedTypes.contains("audio/*") || allowedTypes.contains(AudioRecorder.currentAudioFile.mimeType)
    }
}

// MARK: - Mappers

extension AttachmentRestrictions {

    static func map(from entity: FileRestrictions) -> AttachmentRestrictions {
        AttachmentRestrictions(
            allowedFileSize: entity.allowedFileSize,
            allowedTypes: entity.allowedFileTypes.map(\.mimeType),
            areAttachmentsEnabled: entity.isAttachmentsEnabled
        )
    }
}
