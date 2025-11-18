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
    
    static func chatAppearance(with colors: StyleColors, for traitCollection: UITraitCollection) {
        LogManager.trace("Set UISegmentedControl appearance to chat appearance")
        
        UISegmentedControl.appearance(for: traitCollection).selectedSegmentTintColor = UIColor(colors.background.default)
        UISegmentedControl.appearance(for: traitCollection).setTitleTextAttributes(
            [
                .foregroundColor: UIColor(colors.content.secondary),
                .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium)
            ],
            for: .normal
        )
        UISegmentedControl.appearance(for: traitCollection).setTitleTextAttributes(
            [
                .foregroundColor: UIColor(colors.content.primary),
                .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .bold)
            ],
            for: .selected
        )
        UISegmentedControl.appearance(for: traitCollection).backgroundColor = UIColor(colors.background.surface.default)
    }
    
    func resetChatAppearance<Content: View>(with previousAppearance: ChatHostingController<Content>.SegmentControlAppearance?) {
        if let previousAppearance {
            LogManager.trace("Reset UISegmentedControl appearance to previous appearance")
            
            var normalAttributes = [NSAttributedString.Key: Any]()
            var selectedAttributes = [NSAttributedString.Key: Any]()
            
            if let color = previousAppearance.normalTitleColor {
                normalAttributes[.foregroundColor] = color
            }
            if let font = previousAppearance.normalFont {
                normalAttributes[.font] = font
            }
            if let color = previousAppearance.selectedTitleColor {
                selectedAttributes[.foregroundColor] = color
            }
            if let font = previousAppearance.normalFont {
                selectedAttributes[.font] = font
            }
            
            selectedSegmentTintColor = previousAppearance.selectedSegmentTintColor
            setTitleTextAttributes(normalAttributes, for: .normal)
            setTitleTextAttributes(selectedAttributes, for: .selected)
            backgroundColor = previousAppearance.backgroundColor
        } else {
            LogManager.trace("Reset UISegmentedControl appearance to default")
            
            selectedSegmentTintColor = UIColor.systemBackground
            setTitleTextAttributes(
                [.foregroundColor: UIColor.label.withAlphaComponent(0.5)],
                for: .normal
            )
            setTitleTextAttributes(
                [.foregroundColor: UIColor.label],
                for: .selected
            )
            backgroundColor = UIColor.systemBackground
        }
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selection = 0
    
    let style = ChatStyle(
        colorsManager: StyleColorsManager(
            light: StyleColorsImpl(
                background: BackgroundStyleColorsImpl(
                    default: .red,
                    inverse: .red,
                    surface: BackgroundSurfaceStyleColorsImpl.defaultLight
                ),
                content: ContentStyleColorsImpl(
                    primary: .black,
                    secondary: Color(.darkGray),
                    tertiary: .gray,
                    inverse: .white
                ),
                brand: BrandStyleColorsImpl.defaultLight,
                border: BorderStyleColorsImpl.defaultLight,
                status: StatusStyleColorsImpl.defaultLight
            ),
            dark: StyleColorsImpl(
                background: BackgroundStyleColorsImpl(
                    default: .red,
                    inverse: .red,
                    surface: BackgroundSurfaceStyleColorsImpl.defaultDark
                ),
                content: ContentStyleColorsImpl(
                    primary: .white,
                    secondary: Color(.darkGray),
                    tertiary: .gray,
                    inverse: .black
                ),
                brand: BrandStyleColorsImpl.defaultDark,
                border: BorderStyleColorsImpl.defaultDark,
                status: StatusStyleColorsImpl.defaultDark
            )
        )
    )
    
    Picker(selection: $selection, label: Text("Picker")) {
        Text("Option 1").tag(0)
        Text("Option 2").tag(1)
        Text("Option 3").tag(2)
    }
    .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 24)
        .onAppear {
            UISegmentedControl.chatAppearance(with: style.colors.light, for: .light)
            UISegmentedControl.chatAppearance(with: style.colors.dark, for: .dark)
        }
}
