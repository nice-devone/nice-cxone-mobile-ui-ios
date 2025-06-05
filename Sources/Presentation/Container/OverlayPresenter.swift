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

final class OverlayPresenter {

    // MARK: - Properties
    
    static let shared = OverlayPresenter()
    
    private var overlayWindow: UIWindow?
    
    // MARK: - Methods

    func present<Content: View>(@ViewBuilder content: () -> Content) {
        // Avoid multiple overlays
        if overlayWindow != nil {
            return
        }

        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = hostingController
        window.windowLevel = .alert + 1 // Ensures it's above everything
        window.isHidden = false
        window.makeKeyAndVisible()

        overlayWindow = window
    }

    func dismiss() {
        guard overlayWindow != nil else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.isHidden = true
            self?.overlayWindow = nil
        }
    }
}
