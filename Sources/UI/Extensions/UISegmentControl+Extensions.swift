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

extension UISegmentedControl {
    
    static func chatAppearance(with customizableColors: any CustomizableStyleColors, for traitCollection: UITraitCollection) {
        LogManager.trace("Set UISegmentedControl appearance to chat appearance")
        
        UISegmentedControl.appearance(for: traitCollection).selectedSegmentTintColor = UIColor(customizableColors.background)
        UISegmentedControl.appearance(for: traitCollection).setTitleTextAttributes(
            [.foregroundColor: UIColor(customizableColors.onBackground.opacity(0.5))],
            for: .normal
        )
        UISegmentedControl.appearance(for: traitCollection).setTitleTextAttributes(
            [.foregroundColor: UIColor(customizableColors.onBackground)],
            for: .selected
        )
        UISegmentedControl.appearance(for: traitCollection).backgroundColor = UIColor(customizableColors.background)
    }
    
    func resetChatAppearance<Content: View>(with previousAppearance: ChatHostingController<Content>.SegmentControlAppearance?) {
        if let previousAppearance {
            LogManager.trace("Reset UISegmentedControl appearance to previous appearance")
            
            UISegmentedControl.appearance(for: traitCollection).selectedSegmentTintColor = previousAppearance.selectedSegmentTintColor
            UISegmentedControl.appearance(for: traitCollection).setTitleTextAttributes(
                [.foregroundColor: previousAppearance.normalTitleColor],
                for: .normal
            )
            UISegmentedControl.appearance(for: traitCollection).setTitleTextAttributes(
                [.foregroundColor: previousAppearance.selectedTitleColor],
                for: .selected
            )
            UISegmentedControl.appearance(for: traitCollection).backgroundColor = previousAppearance.backgroundColor
        } else {
            LogManager.trace("Reset UISegmentedControl appearance to default")
            
            UISegmentedControl.appearance(for: traitCollection).selectedSegmentTintColor = UIColor.systemBackground
            UISegmentedControl.appearance(for: traitCollection).setTitleTextAttributes(
                [.foregroundColor: UIColor.label.withAlphaComponent(0.5)],
                for: .normal
            )
            UISegmentedControl.appearance(for: traitCollection).setTitleTextAttributes(
                [.foregroundColor: UIColor.label],
                for: .selected
            )
            UISegmentedControl.appearance(for: traitCollection).backgroundColor = UIColor.systemBackground
        }
    }
}
