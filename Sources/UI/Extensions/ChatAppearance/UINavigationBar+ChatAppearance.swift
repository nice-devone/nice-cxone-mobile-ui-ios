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

extension UINavigationBar {
    
    func chatAppearance(with colors: StyleColors) {
        LogManager.trace("Set UINavigationBar appearance to chat appearance")
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(colors.background.default)
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = nil
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(colors.content.primary)
        ]
        
        appearance.titleTextAttributes = textAttributes
        appearance.largeTitleTextAttributes = textAttributes
        
        standardAppearance = appearance
        compactAppearance = appearance
        scrollEdgeAppearance = appearance
        tintColor = UIColor(colors.brand.primary)
        isTranslucent = false
    }
    
    func resetChatAppearance<Content: View>(with previousAppearance: ChatHostingController<Content>.NavigationBarAppearance?) {
        if let previousAppearance {
            LogManager.trace("Reset UINavigationBar appearance to previous appearance")
            
            standardAppearance = previousAppearance.standard
            compactAppearance = previousAppearance.compact
            scrollEdgeAppearance = previousAppearance.scrollEdge
            tintColor = previousAppearance.tintColor
            isTranslucent = previousAppearance.isTranslucent
        } else {
            LogManager.trace("Reset UINavigationBar appearance to default")
            
            standardAppearance.configureWithDefaultBackground()
            compactAppearance = nil
            scrollEdgeAppearance = nil
            tintColor = UIColor(Color.accentColor)
            isTranslucent = true
        }
    }
}

// MARK: - Previews

#Preview {
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
    
    NavigationView {
        VStack {
            EmptyView()
        }
        .navigationTitle("Conversations")
        .onAppear {
            UINavigationBar.appearance(for: .light).chatAppearance(with: style.colors.light)
            UINavigationBar.appearance(for: .dark).chatAppearance(with: style.colors.dark)
        }
    }
}
