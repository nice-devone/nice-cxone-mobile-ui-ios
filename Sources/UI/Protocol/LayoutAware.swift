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

import SwiftUI

/// Adopted by views whose layout depends on the device orientation.
///
/// Conformers declare
/// ```swift
/// @Environment(\.chatLayout) var chatLayout
/// ```
/// and reach every orientation-derived value through the helpers below rather than through
/// `UIDevice.isLandscape` or `StyleGuide` directly. Routing the read through ``chatLayout`` is what
/// registers the view as a dependent of the container's geometry — without it SwiftUI has nothing to
/// invalidate, and the view keeps the value it resolved on its last body evaluation. See
/// ``ChatLayoutContext``.
///
/// Mirrors ``Themed``, which supplies `colors` the same way.
@MainActor
protocol LayoutAware {

    // MARK: - Properties

    var chatLayout: ChatLayoutContext { get }
}

// MARK: - Helpers

extension LayoutAware {

    var screenBounds: CGRect {
        chatLayout.screenBounds
    }

    var isLandscape: Bool {
        chatLayout.isLandscape
    }

    var isCompactHeight: Bool {
        chatLayout.isCompactHeight
    }

    /// Short edge of the screen — the height in landscape, the width in portrait.
    var screenShortEdge: CGFloat {
        screenBounds.shortEdge
    }

    var messageMaxWidth: CGFloat {
        chatLayout.messageMaxWidth
    }

    func attachmentSize(for mode: AttachmentThumbnailDisplayMode) -> CGSize {
        chatLayout.attachmentSize(for: mode)
    }
}
