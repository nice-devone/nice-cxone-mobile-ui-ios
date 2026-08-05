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

import SwiftUI

extension View {

    /// Forces the navigation bar to always render an opaque, themed background material for chat surfaces on iOS < 26.
    ///
    /// Before the Swift 6 strict-concurrency migration (#755), the SDK configured
    /// `UINavigationBar.scrollEdgeAppearance` with an opaque ``StyleColors/background``.default
    /// fill via `ChatHostingController` + a `UINavigationBar` extension. That UIKit bridge was
    /// removed without a SwiftUI replacement, so on iOS 16 — where the default
    /// `scrollEdgeAppearance` is transparent — chat and thread-list content bleeds up over the nav
    /// bar whenever the underlying `ScrollView`/`List` is at the top. iOS 17+ already renders the
    /// system material at every scroll offset, so the regression only surfaces on iOS 16.
    ///
    /// This modifier restores the pre-migration behavior in view-scoped SwiftUI form: it draws the
    /// theme's ``StyleColors/background``.default as the nav bar background and marks it
    /// permanently visible so the material is present at every scroll offset. This preserves the
    /// SDK's theming contract — integrators whose `ChatStyle` diverges from the system default
    /// continue to see their custom background on the nav bar rather than the system material.
    ///
    /// - Note: On iOS 26+ this modifier is a no-op. iOS 26 already renders an opaque nav bar
    ///   background natively, and applying `.toolbarBackground(.visible, for: .navigationBar)`
    ///   there conflicts with the `.largeSubtitle` / `.subtitle` toolbar item placements used by
    ///   ``ChatNavigationTitle`` — the navigation title and AI Assistant badge would fail to
    ///   render.
    /// - Note: Scoped to the SDK's chat views (no global `UIAppearance` override), so host apps
    ///   that also use `NavigationStack` retain their own toolbar styling everywhere else.
    func chatToolbarBackground() -> some View {
        modifier(ChatToolbarBackground())
    }
}

// MARK: - ChatToolbarBackground

private struct ChatToolbarBackground: ViewModifier, Themed {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    // MARK: - Builder

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .toolbarBackground(colors.background.default, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
