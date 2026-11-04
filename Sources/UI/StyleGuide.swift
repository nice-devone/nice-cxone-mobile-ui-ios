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
import UIKit

enum StyleGuide {

    /// Provides screen bounds for layout calculations. Override in tests by assigning any
    /// `ScreenBoundsProviding` double — `MockScreenBoundsProvider` in the snapshot target, or a
    /// local conformance in `CXoneChatUITests`, which cannot reach that mock
    /// (see `ChatLayoutContextTests.FixedScreenBoundsProvider`).
    @MainActor static var screenBoundsProvider: any ScreenBoundsProviding = ScreenBoundsProvider()

    static let animationDuration: Double = 0.18

    // MARK: - Sizing

    enum Sizing {

        static let overlayMaxWidth: CGFloat = 640

        enum Button {
            static let tinyDimension: CGFloat = 20
            static let smallDimension: CGFloat = 32
            static let regularDimension: CGFloat = 44
            static let maxWidth: CGFloat = 320
        }

        enum Attachment {
            static let cornerRadius: CGFloat = 10
            static let borderWidth: CGFloat = 1

            /// The corner radius of content drawn inside the attachment's border.
            static var innerCornerRadius: CGFloat {
                cornerRadius - (2 * borderWidth)
            }

            /// The size of content drawn inside the border of an attachment thumbnail of the given `size`.
            static func innerSize(for size: CGSize) -> CGSize {
                CGSize(width: size.width - (2 * borderWidth), height: size.height - (2 * borderWidth))
            }

            /// The screen's short edge — the height in landscape, the width in portrait.
            @MainActor
            private static var screenShortEdge: CGFloat {
                StyleGuide.screenBoundsProvider.screenBounds.shortEdge
            }
            /// The screen's long edge — the width in landscape, the height in portrait.
            @MainActor
            private static var screenLongEdge: CGFloat {
                StyleGuide.screenBoundsProvider.screenBounds.longEdge
            }
            
            /// An eighth of the screen's short edge — roughly 49 pt on a 393 pt phone, 55 pt on the widest.
            /// Used by `AttachmentThumbnailDisplayMode.smallCompact` for the attachment strip while the
            /// keyboard is up on a landscape phone, where the regular size leaves no room for the input bar.
            @MainActor
            static var smallCompactDimension: CGFloat {
                screenShortEdge / 8
            }

            @MainActor
            static var smallDimension: CGFloat {
                screenShortEdge / 5
            }
            /// A quarter of the screen's short edge — the load-bearing constraint behind
            /// `MultipleAttachmentsContainer.gridWidth`, which is `2 * this + itemSpacing` and
            /// has to fit inside `Message.maxWidth` (60% of the screen width). At 402 pt wide
            /// that's 213 pt against a 241 pt bubble; the previous `/ 3` gave 280 pt and
            /// overflowed the bubble. Restoring `/ 3` reintroduces that clipping.
            @MainActor
            static var regularDimension: CGFloat {
                screenShortEdge / 4
            }
            @MainActor
            static var largeHeight: CGFloat {
                screenLongEdge / 4
            }
            @MainActor
            static var largeWidth: CGFloat {
                screenShortEdge / 2.5
            }
        }

        enum Message {
            static let cornerRadius: CGFloat = 20
            // 60% of the current screen width in whichever orientation is active.
            // `screenBounds` is orientation-aware (its `width` is the long edge in
            // landscape, the short edge in portrait), so this fills 60% of the actual
            // width in both — no orientation branch needed.
            @MainActor
            static var maxWidth: CGFloat {
                StyleGuide.screenBoundsProvider.screenBounds.width * 0.6
            }
        }
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        
        enum Message {
            static let groupCellSpacing: CGFloat = 2
        }
    }
    
    // MARK: - Padding
    
    enum Padding {
        enum Message {
            static let contentVertical: CGFloat = 12
            static let contentHorizontal: CGFloat = 12
        }
    }
}
