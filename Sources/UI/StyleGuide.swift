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

    /// Provides screen bounds for layout calculations. Override in tests via `MockScreenBoundsProvider`.
    @MainActor static var screenBoundsProvider: any ScreenBoundsProviding = ScreenBoundsProvider()

    static let animationDuration: Double = 0.18

    // MARK: - Sizing

    enum Sizing {

        static let buttonTinyDimension: CGFloat = 20
        static let buttonSmallDimension: CGFloat = 32
        static let buttonRegularDimension: CGFloat = 44

        enum Attachment {
            @MainActor
            static var smallDimension: CGFloat { StyleGuide.screenBoundsProvider.screenBounds.width / 5 }
            @MainActor
            static var regularDimension: CGFloat { StyleGuide.screenBoundsProvider.screenBounds.width / 3 }
            @MainActor
            static var largeHeight: CGFloat { StyleGuide.screenBoundsProvider.screenBounds.height / 4 }
            @MainActor
            static var largeWidth: CGFloat { StyleGuide.screenBoundsProvider.screenBounds.width / 2.5 }
            static let cornerRadius: CGFloat = 10
            static let borderWidth: CGFloat = 1
        }

        enum Message {
            static let cornerRadius: CGFloat = 20
            @MainActor
            static var messageCellWidth: CGFloat {
                (StyleGuide.screenBoundsProvider.screenBounds.width / 2) * (UIDevice.isLandscape ? 0.4 : 0.9)
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
        // nav bar is typically 44 points + 20 points for sheet inset + 32 points for positioning
        static let overlayTop: CGFloat = 96
        
        enum Message {
            static let contentVertical: CGFloat = 12
            static let contentHorizontal: CGFloat = 12
        }
    }
    
    // MARK: - Colors
    
    enum Colors {
        static let dividerOpacity = 0.1
    }
}
