//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
    /// `chevron.left`
    static let back = Image(systemName: "chevron.left")
    /// `"ellipsis`
    static let menu = Image(systemName: "ellipsis")
    /// `bolt.slash.fill`
    static let disconnect = Image(systemName: "bolt.slash.fill")
    /// `chevron.right`
    static let disclosure = Image(systemName: "chevron.right")
    
    // MARK: - Chat Example
    
    enum ChatExample {
        /// `bubble.left.and.bubble.right`
        static let exampleNavigationIcon = Image(systemName: "bubble.left.and.bubble.right")
    }
    
    // MARK: - List
    
    enum List {
        /// `plus`
        static let new = Image(systemName: "plus")
        /// `trash`
        static let delete = Image(systemName: "trash")
    }
    
    // MARK: - Chat Thread
    
    enum ChatThread {
        /// `rectangle.stack.badge.person.crop`
        static let editPrechatCustomFields = Image(systemName: "rectangle.stack.badge.person.crop")
        /// `rectangle.and.pencil.and.ellipsis.rtl`
        static let editThreadName = Image(systemName: "rectangle.and.pencil.and.ellipsis.rtl")
    }
    
    // MARK: - Message
    
    enum Message {
        /// `bubble.left`
        static let toastIcon = Image(systemName: "bubble.left")
        /// `checkmark.circle`
        static let sent = Image(systemName: "checkmark.circle")
        /// `checkmark.circle.fill`
        static let delivered = Image(systemName: "checkmark.circle.fill")
        /// `paperplane.fill`
        static let send = Image(systemName: "paperplane.fill")
        /// `archivebox.fill`
        static let archived = Image(systemName: "archivebox.fill")
    }
    
    // MARK: - Attachments
    
    enum Attachment {
        /// `arrow.up.doc`
        static let image = Image(systemName: "arrow.up.doc")
        /// `xmark.circle.fill`
        static let remove = Image(systemName: "xmark.circle.fill")
        /// `play.fill`
        static let play = Image(systemName: "play.fill")
        /// `pause.fill`
        static let pause = Image(systemName: "pause.fill")
        /// `stop.fill`
        static let stop = Image(systemName: "stop.fill")
        /// `play.circle.fill`
        static let playCircle = Image(systemName: "play.circle.fill")
        /// `pause.fill.circle`
        static let pauseCircle = Image(systemName: "pause.circle.fill")
        /// `speaker.slash`
        static let mute = Image(systemName: "speaker.slash")
        /// `speaker.2`
        static let unmute = Image(systemName: "speaker.2")
        /// `gobackward.10`
        static let rewind = Image(systemName: "gobackward.10")
        /// `goforward.10`
        static let advance = Image(systemName: "goforward.10")
        /// `rectangle.on.rectangle.angled`
        static let videoInFullScreen = Image(systemName: "rectangle.on.rectangle.angled")
        /// `photo`
        static let placeholder = Image(systemName: "photo")
        /// `paperclip`
        static let file = Image(systemName: "paperclip")
        /// `mic.fill`
        static let recordVoice = Image(systemName: "mic.fill")
        /// `trash.fill`
        static let deleteVoice = Image(systemName: "trash.fill")
        /// `rectangle.portrait.and.arrow.right`
        static let openLink = Image(systemName: "rectangle.portrait.and.arrow.right")
        /// `doc.text`
        static let linkPlaceholder = Image(systemName: "doc.text")
        /// `waveform`
        static let voiceIndicator = Image(systemName: "waveform")
    }
    
    // MARK: - LiveChat - End Conversation
    
    enum LiveChat {
        /// `moon.zzz`
        static let offline = Image(systemName: "moon.zzz")
        /// `person.crop.circle.badge.clock`
        static let personWithClock = Image(systemName: "person.crop.circle.badge.clock")
        /// `bubble.left.and.bubble.right.fill`
        static let newChat = Image(systemName: "bubble.left.and.bubble.right.fill")
    }
}
