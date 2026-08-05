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

// MARK: - A11y Override Support
//
// These properties are set by ChatCoordinator before the chat UI is presented.
// The generated A11y.tr function reads them to resolve strings through the
// integrator's override bundle and/or provider before falling back to Bundle.module.
//
// The override chain is baked into the custom SwiftGen template at
// swiftgen-templates/accessibility-swift5.stencil, so running SwiftGen is always safe.

extension A11y {

    /// The integrator's bundle to search for `Accessibility.strings` overrides.
    /// Set by `ChatCoordinator` from `ChatAccessibility.bundle` before presenting the chat UI.
    /// Always written and read on the main thread via `ChatCoordinator.content()`.
    nonisolated(unsafe) internal static var overrideBundle: Bundle?

    /// The integrator's programmatic string provider.
    /// Set by `ChatCoordinator` from `ChatAccessibility.provider` before presenting the chat UI.
    /// Always written and read on the main thread via `ChatCoordinator.content()`.
    nonisolated(unsafe) internal static var overrideProvider: (any AccessibilityStringProvider)?
}
