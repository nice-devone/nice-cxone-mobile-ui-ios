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

import SwiftUI

extension Asset {
    
    // MARK: - Common
    
    /// `square.and.arrow.up`
    static let share = Image(systemName: "square.and.arrow.up")
    /// `doc.on.doc`
    static let copy = Image(systemName: "doc.on.doc")
    /// `xmark`
    static let close = Image(systemName: "xmark")
    /// `checkmark`
    static let check = Image(systemName: "checkmark")
    /// `"ellipsis`
    static let menu = Image(systemName: "ellipsis")
    /// `chevron.down`
    static let down = Image(systemName: "chevron.down")
    /// `chevron.right`
    static let right = Image(systemName: "chevron.right")
    /// 'exclamationmark.triangle'
    static let warning = Image(systemName: "exclamationmark.triangle")
    
    // MARK: - List
    
    enum List {
        /// `plus`
        static let new = Image(systemName: "plus")
        /// `gearshape`
        static let rename = Image(systemName: "gearshape")
        /// `archivebox`
        static let archive = Image(systemName: "archivebox")
    }
    
    // MARK: - Chat Thread
    
    enum ChatThread {
        /// `rectangle.stack.badge.person.crop`
        static let editPrechatCustomFields = Image(systemName: "rectangle.stack.badge.person.crop")
        /// `rectangle.and.pencil.and.ellipsis.rtl`
        static let editThreadName = Image(systemName: "rectangle.and.pencil.and.ellipsis.rtl")
        /// `gearshape`
        static let gear = Image(systemName: "gearshape")
    }
    
    // MARK: - Message
    
    enum Message {
        /// `checkmark.circle`
        static let sent = Image(systemName: "checkmark.circle")
        /// `checkmark.circle.fill`
        static let delivered = Image(systemName: "checkmark.circle.fill")
        /// `paperplane.circle.fill`
        static let send = Image(systemName: "paperplane.circle.fill")
        /// `exclamationmark.circle`
        static let failed = Image(systemName: "exclamationmark.circle")
        /// `archivebox.fill`
        static let archiveFill = Image(systemName: "archivebox.fill")
        /// `archivebox`
        static let archive = Image(systemName: "archivebox")
        /// `person.fill`
        static let fallbackAvatar = Image(systemName: "person.fill")
        
        enum RichContent {
            /// `link`
            static let link = Image(systemName: "link")
        }
    }
    
    // MARK: - Attachments
    
    enum Attachment {
        /// `xmark.circle.fill`
        static let remove = Image(systemName: "xmark.circle.fill")
        /// `play.fill`
        static let play = Image(systemName: "play.fill")
        /// `pause.fill`
        static let pause = Image(systemName: "pause.fill")
        /// `stop.circle.fill`
        static let stop = Image(systemName: "stop.circle.fill")
        /// `gobackward.10`
        static let rewind = Image(systemName: "gobackward.10")
        /// `goforward.10`
        static let advance = Image(systemName: "goforward.10")
        /// `photo`
        static let placeholder = Image(systemName: "photo")
        /// `paperclip`
        static let file = Image(systemName: "paperclip")
        /// `mic.fill`
        static let recordVoice = Image(systemName: "mic.circle.fill")
        /// `trash.fill`
        static let deleteVoice = Image(systemName: "trash.fill")
        /// `waveform`
        static let voiceIndicator = Image(systemName: "waveform")
        /// `play.circle.fill`
        static let playButtonSymbol = Image(systemName: "play.circle.fill")
    }
    
    // MARK: - LiveChat - End Conversation
    
    enum LiveChat {
        /// `moon.zzz`
        static let offline = Image(systemName: "moon.zzz.fill")
        /// `person.crop.circle.badge.clock`
        static let personWithClock = Image(systemName: "person.crop.circle.badge.clock")
    }
}
