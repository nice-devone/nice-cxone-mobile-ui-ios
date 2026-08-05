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
    
    static var hasHomeButton: Bool {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        
        guard let safeAreaBottom = keyWindow?.safeAreaInsets.bottom else {
            return false
        }
        
        return safeAreaBottom <= 0
    }
    
    @MainActor
    static var isLandscape: Bool {
        UIWindowScene.activeWindowScene?.interfaceOrientation.isLandscape ?? false
    }
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

// MARK: - UIWindowScene

private extension UIWindowScene {

    /// Foreground-active window scene, with a fallback to the first connected window scene to handle
    /// pre-activation lifecycle and single-scene apps.
    @MainActor
    static var activeWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }
}
