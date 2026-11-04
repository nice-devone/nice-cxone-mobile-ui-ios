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

import CoreGraphics

extension CGRect {

    /// The short edge — the height in landscape, the width in portrait.
    ///
    /// Orientation is itself derived from the bounds (`width > height`), so this is simply the smaller side.
    var shortEdge: CGFloat {
        min(width, height)
    }

    /// The long edge — the width in landscape, the height in portrait.
    var longEdge: CGFloat {
        max(width, height)
    }
}
