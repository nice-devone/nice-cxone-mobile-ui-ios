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

import SwiftUI
import UIKit

extension UIView {
    
    static func defaultAlertAppearance(with customizableColors: any CustomizableStyleColors, for traitCollection: UITraitCollection) {
        LogManager.trace("Reset UIAlertController appearance to chat appearance")
        
        UIView.appearance(for: traitCollection, whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(customizableColors.primary)
    }
    
    static func resetChatAppearance<Content: View>(
        with previousAppearance: ChatHostingController<Content>.AlertControllerAppearance?,
        for traitCollection: UITraitCollection
    ) {
        if let previousAppearance {
            LogManager.trace("Resetting UIAlertController appearance to previous appearance")
            
            UIView.appearance(for: traitCollection, whenContainedInInstancesOf: [UIAlertController.self]).tintColor = previousAppearance.tintColor
        } else {
            LogManager.trace("Resetting UIAlertController appearance to default")
            
            UIView.appearance(for: traitCollection, whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.accentColor)
        }
    }
}
