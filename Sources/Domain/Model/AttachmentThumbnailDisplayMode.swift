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
import SwiftUI
import UIKit

enum AttachmentThumbnailDisplayMode {
    
    // MARK: - Cases
    
    /// Small thumbnail display mode used in attachment list above input field.
    case small
    /// Regular thumbnail display mode used in message bubble.
    case regular
    /// Large thumbnail display mode used in `AttachmentsView`.
    case large
    
    // MARK: - Computed Properties
    
    var font: Font {
        switch self {
        case .small:
            return .headline
        case .regular:
            return .title
        case .large:
            return .largeTitle
        }
    }
    
    var size: CGSize {
        switch self {
        case .small:
            return CGSize(width: StyleGuide.Sizing.Attachment.smallDimension, height: StyleGuide.Sizing.Attachment.smallDimension)
        case .regular:
            return CGSize(width: StyleGuide.Sizing.Attachment.regularDimension, height: StyleGuide.Sizing.Attachment.regularDimension)
        case .large:
            return CGSize(width: StyleGuide.Sizing.Attachment.largeWidth, height: StyleGuide.Sizing.Attachment.largeHeight)
        }
    }
}
