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

import UIKit

extension UIDevice {

    @MainActor
    static var isLandscape: Bool {
        // Derive orientation from the screen bounds — the same source the layout
        // sizing uses — rather than the window scene. This stays equivalent in the
        // app (`screenBounds` is orientation-aware) while remaining deterministic and
        // mockable in snapshot tests, where there is no active window scene.
        let bounds = StyleGuide.screenBoundsProvider.screenBounds

        return bounds.width > bounds.height
    }

    /// `true` when the screen is too short to show a full-size message input alongside the keyboard —
    /// in practice, an iPhone in landscape.
    ///
    /// A landscape iPhone leaves roughly 150 pt between the navigation bar and the top of the keyboard.
    /// The attachment strip at its regular size (~128 pt) plus the input bar (~52 pt) does not fit in
    /// that space, so the strip switches to a compact geometry — see
    /// `StyleGuide.Sizing.Attachment.smallCompactDimension`. iPad landscape keeps at least 744 pt of
    /// height and is deliberately excluded by the threshold.
    @MainActor
    static var isCompactHeight: Bool {
        let bounds = StyleGuide.screenBoundsProvider.screenBounds

        return isLandscape && bounds.height < compactHeightThreshold
    }

    /// Short-edge cut-off separating a phone in landscape from a tablet. The widest iPhone short edge
    /// is 440 pt (16 Pro Max) and the narrowest iPad short edge is 744 pt (mini), so any value between
    /// the two splits them; 600 pt sits in the middle of that gap.
    private static let compactHeightThreshold: CGFloat = 600
}

// MARK: - UIScreen

extension UIScreen {

    /// Bounds of the current foreground scene's screen.
    ///
    /// Falls back to the deprecated `UIScreen.main.bounds` if no `UIWindowScene` is available
    /// (cold launch, SwiftUI previews, headless test contexts). The fallback is intentional:
    /// many `@MainActor static let` layout constants in `StyleGuide` derive from this property and
    /// would collapse to zero permanently if first evaluated before any scene is connected.
    @MainActor
    static var currentBounds: CGRect {
        UIWindowScene.activeWindowScene?.screen.bounds ?? UIScreen.main.bounds
    }
}
