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

extension UIWindowScene {

    /// The window scene to read screen geometry from or present into.
    ///
    /// Prefers, in order: the foreground-active scene, the scene hosting the key window, and the first
    /// connected window scene — the last two cover the pre-activation lifecycle and single-scene apps.
    @MainActor
    static var activeWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { scene in
            scene as? UIWindowScene
        }

        let foregroundActiveScene = scenes.first { scene in
            scene.activationState == .foregroundActive
        }
        let keyWindowScene = scenes.first { scene in
            scene.windows.contains(where: \.isKeyWindow)
        }

        if let foregroundActiveScene {
            return foregroundActiveScene
        } else if let keyWindowScene {
            return keyWindowScene
        } else {
            return scenes.first
        }
    }
}
