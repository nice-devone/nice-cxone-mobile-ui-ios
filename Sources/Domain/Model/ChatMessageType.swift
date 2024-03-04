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

import AVFoundation
import SwiftUI
import UIKit

/// Representation of different types of messages used in chat instance
///
/// This enum is designed for categorizing and representing various types of messages in chat systems.
/// It allows for the display of text, multimedia, links, rich content, and more, providing versatility in message content and presentation.
public enum ChatMessageType: Hashable {
    
    // MARK: - Cases
    
    case text(String)
    
    case image(AttachmentItem)
    
    case video(AttachmentItem)
    
    case audio(AttachmentItem)
    
    case linkPreview(AttachmentItem)
    
    case richContent(ChatRichMessageType)
    
    // MARK: - Properties
    
    /// Indicates whether the message is of a rich content type (e.g., multimedia, rich link, satisfaction survey).
    public var isRichContent: Bool {
        switch self {
        case .text:
            return false
        default:
            return true
        }
    }
    
    /// Indicates whether a text message contains plain text (excluding emojis).
    public var isPlainText: Bool {
        guard case .text(let text) = self else {
            return false
        }
        
        return !text.containsOnlyEmoji
    }
}

// MARK: - Rich Message Type

/// Types of supported rich content messages
///
/// This enum is designed to categorize and represent different types of rich messages that can be used in chat systems.
/// It provides flexibility in displaying various types of content and interactions within chat applications.
public enum ChatRichMessageType: Hashable {
    
    case gallery([ChatRichMessageType])
    
    case menu([RichMessageSubElementType])
    
    case quickReplies(QuickRepliesItem)
    
    case listPicker(ListPickerItem)
    
    case richLink(RichLinkItem)
    
    case satisfactionSurvey(SatisfactionSurveyItem)
    
    case custom(CustomPluginMessageItem)
}
