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
import UIKit

enum VideoThumbnailDisplayMode {
    case small, multipleContainer, attachmentsOverflow, large
    
    var fontSize: CGFloat {
        switch self {
        case .small:
            return 18
        case .multipleContainer:
            return 28
        case .attachmentsOverflow, .large:
            return 54
        }
    }
    
    var width: CGFloat {
        size.width
    }
    
    var height: CGFloat {
        size.height
    }
    
    private var size: CGSize {
        switch self {
        case .small:
            return CGSize(width: 72, height: 72)
        case .multipleContainer:
            return CGSize(width: 112, height: 112)
        case .attachmentsOverflow:
            return CGSize(width: UIScreen.main.messageCellWidth, height: UIScreen.main.messageCellWidth)
        case .large:
            return CGSize(width: 242, height: 285)
        }
    }
}
