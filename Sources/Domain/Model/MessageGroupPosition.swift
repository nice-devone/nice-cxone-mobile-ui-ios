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

/// Enumerates different positions of a message within a message group
public enum MessageGroupPosition {

    /// Indicates that the message group contains only a single message
    case single
    
    /// Indicates that the message is positioned at the beginning of the message group
    case first
    
    /// Indicates that the message is positioned neither at the beginning nor at the end of the message group
    case inside
    
    /// Indicates that the message is positioned at the end of the message group
    case last
}
