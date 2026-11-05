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

extension CGFloat {

    /// `true` when this value, read as a safe-area inset, means there is no inset.
    ///
    /// SwiftUI's measured insets are not exact: a `GeometryReader` on a home-button device can
    /// report a bottom inset like `4.3e-14` instead of `0`. Comparing against `0` would treat that
    /// rounding error as a real inset.
    var isNegligibleSafeAreaInset: Bool {
        self < 0.5
    }
}
