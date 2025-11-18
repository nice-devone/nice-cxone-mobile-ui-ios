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

extension MessageGroupPosition {
  
    // MARK: - Constants
    
    private static let cornerRadiusBetweenMessages: CGFloat = 4
    
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
        
        return [.first, .inside].contains(self) ? Self.cornerRadiusBetweenMessages : StyleGuide.Sizing.Message.cornerRadius
    }
    
    func bottomRightCornerRadius(isUserAgent: Bool) -> CGFloat {
        guard self != .single, !isUserAgent else {
            return StyleGuide.Sizing.Message.cornerRadius
        }
        
        return [.first, .inside].contains(self) ? Self.cornerRadiusBetweenMessages : StyleGuide.Sizing.Message.cornerRadius
    }
}
