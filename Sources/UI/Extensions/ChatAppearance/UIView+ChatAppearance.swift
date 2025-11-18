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
    
    static func chatAlertAppearance(with colors: StyleColors, for traitCollection: UITraitCollection) {
        LogManager.trace("Reset UIAlertController appearance to chat appearance")
        
        UIView.appearance(for: traitCollection, whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .red
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

// MARK: - Previews

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var showAlert = false
    
    let localization = ChatLocalization()
    let style = ChatStyle(
        colorsManager: StyleColorsManager(
            light: StyleColorsImpl(
                background: BackgroundStyleColorsImpl.defaultLight,
                content: ContentStyleColorsImpl.defaultLight,
                brand: BrandStyleColorsImpl(
                    primary: Asset.Colors.Brand.Secondary.base,
                    onPrimary: Asset.Colors.Base.white,
                    primaryContainer: Asset.Colors.Brand.Secondary._200,
                    onPrimaryContainer: Asset.Colors.Brand.Secondary._700,
                    secondary: Asset.Colors.Brand.Primary.base,
                    onSecondary: Asset.Colors.Base.black,
                    secondaryContainer: Asset.Colors.Brand.Primary._100,
                    onSecondaryContainer: Asset.Colors.Brand.Primary._900
                ),
                border: BorderStyleColorsImpl.defaultLight,
                status: StatusStyleColorsImpl.defaultLight
            ),
            dark: StyleColorsImpl(
                background: BackgroundStyleColorsImpl.defaultDark,
                content: ContentStyleColorsImpl.defaultDark,
                brand: BrandStyleColorsImpl(
                    primary: Asset.Colors.Brand.Secondary.base,
                    onPrimary: Asset.Colors.Base.white,
                    primaryContainer: Asset.Colors.Brand.Secondary._200,
                    onPrimaryContainer: Asset.Colors.Brand.Secondary._700,
                    secondary: Asset.Colors.Brand.Primary.base,
                    onSecondary: Asset.Colors.Base.black,
                    secondaryContainer: Asset.Colors.Brand.Primary._100,
                    onSecondaryContainer: Asset.Colors.Brand.Primary._900
                ),
                border: BorderStyleColorsImpl.defaultDark,
                status: StatusStyleColorsImpl.defaultDark
            )
        )
    )
    
    Color.clear
        .alert(localization.commonError, isPresented: $showAlert, actions: {
            Button(localization.commonCancel) { }
        }, message: {
            Text(localization.alertGenericErrorMessage)
        })
        .onAppear {
            UISegmentedControl.chatAppearance(with: style.colors.light, for: .light)
            UISegmentedControl.chatAppearance(with: style.colors.dark, for: .dark)
        }
        .task {
            await Task.sleep(seconds: 1)
            
            showAlert = true
        }
}
