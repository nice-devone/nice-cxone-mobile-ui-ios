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

import Foundation

extension MessageGroupPosition {
  
    // MARK: - Constants
    
    private static let cornerRadiusBetweenMessages: CGFloat = 4
    
    // MARK: - Properties

    /// Whether the message closes its group — it is either alone or the last one in it.
    var isLastInGroup: Bool {
        self == .single || self == .last
    }
    
    // MARK: - Methods
    
    func topLeftCornerRadius(isUserAgent: Bool) -> CGFloat {
        guard self != .single, isUserAgent else {
            return StyleGuide.Sizing.Message.cornerRadius
        }
        
        return self == .first ? StyleGuide.Sizing.Message.cornerRadius : Self.cornerRadiusBetweenMessages
    }
    
    func topRightCornerRadius(isUserAgent: Bool) -> CGFloat {
        guard self != .single, !isUserAgent else {
            return StyleGuide.Sizing.Message.cornerRadius
        }
        
        return self == .first ? StyleGuide.Sizing.Message.cornerRadius : Self.cornerRadiusBetweenMessages
    }
    
    func bottomLeftCornerRadius(isUserAgent: Bool) -> CGFloat {
        guard self != .single, isUserAgent else {
            return StyleGuide.Sizing.Message.cornerRadius
        }
        
        return isLastInGroup ? StyleGuide.Sizing.Message.cornerRadius : Self.cornerRadiusBetweenMessages
    }
    
    func bottomRightCornerRadius(isUserAgent: Bool) -> CGFloat {
        guard self != .single, !isUserAgent else {
            return StyleGuide.Sizing.Message.cornerRadius
        }

        return isLastInGroup ? StyleGuide.Sizing.Message.cornerRadius : Self.cornerRadiusBetweenMessages
    }

    /// The bubble-matched rounded-rectangle clip shape for a cell at this position.
    ///
    /// Single source of the per-corner radius mapping shared by the image, video,
    /// document, and multiple-attachment cells so their corners stay in sync.
    func clipShape(isUserAgent: Bool, insetAmount: CGFloat = 0) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeft: topLeftCornerRadius(isUserAgent: isUserAgent),
            topRight: topRightCornerRadius(isUserAgent: isUserAgent),
            bottomLeft: bottomLeftCornerRadius(isUserAgent: isUserAgent),
            bottomRight: bottomRightCornerRadius(isUserAgent: isUserAgent),
            insetAmount: insetAmount
        )
    }
}

// MARK: - Optional clip shape

extension Optional where Wrapped == MessageGroupPosition {

    /// The clip shape for an attachment cell that may be standalone or grouped:
    /// `nil` (e.g. inside the multiple-attachment grid) → fully-rounded corners using
    /// the attachment corner radius; a concrete position → the bubble-matched shape.
    func attachmentClipShape(isUserAgent: Bool) -> UnevenRoundedRectangle {
        guard let self else {
            let radius = StyleGuide.Sizing.Attachment.cornerRadius

            return UnevenRoundedRectangle(topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius)
        }

        return self.clipShape(isUserAgent: isUserAgent)
    }
}
