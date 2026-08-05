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

/// Controls the accessibility strings used by the CXoneChatUI SDK.
///
/// Pass a custom instance to ``ChatCoordinator`` to override individual accessibility strings
/// or to provide full localization in additional languages via your own bundle.
///
/// ## String resolution order
/// 1. ``provider`` — programmatic overrides (highest priority)
/// 2. ``bundle`` — your app or framework bundle's `Accessibility.strings` (supports `.lproj` localization)
/// 3. SDK's own `Accessibility.strings` — built-in defaults (lowest priority)
///
/// ## Bundle-based localization (recommended for full language support)
/// Add an `Accessibility.strings` file to your app target for each language you support.
/// The SDK will automatically pick the correct `.lproj` based on the device locale.
///
/// ```swift
/// // In your app target, add:
/// // en.lproj/Accessibility.strings   →  "form.button_confirm.valid.hint" = "Double-tap to submit";
/// // fr.lproj/Accessibility.strings   →  "form.button_confirm.valid.hint" = "Touchez deux fois pour soumettre";
///
/// coordinator = ChatCoordinator(
///     chatAccessibility: ChatAccessibility(bundle: .main)
/// )
/// ```
///
/// ## Programmatic overrides (for targeted changes)
/// ```swift
/// class MyProvider: AccessibilityStringProvider {
///     func accessibilityString(forKey key: String) -> String? {
///         key == "form.button_confirm.valid.hint" ? "Double-tap to submit" : nil
///     }
/// }
///
/// coordinator = ChatCoordinator(
///     chatAccessibility: ChatAccessibility(provider: MyProvider())
/// )
/// ```
///
/// ## Framework bundle
/// If your integration lives in a separate framework bundle (not the app target directly):
/// ```swift
/// coordinator = ChatCoordinator(
///     chatAccessibility: ChatAccessibility(bundle: Bundle(for: MyFrameworkClass.self))
/// )
/// ```
public class ChatAccessibility: ObservableObject {

    // MARK: - Properties

    /// The bundle in which the SDK looks for `Accessibility.strings` overrides.
    ///
    /// Defaults to `Bundle.main`. Set this to your own framework bundle when your
    /// `Accessibility.strings` file lives in a separate bundle rather than the app target.
    public let bundle: Bundle

    /// An optional provider for fine-grained programmatic accessibility string overrides.
    ///
    /// When non-nil, this is consulted first — before the bundle lookup and before the SDK default.
    /// Return `nil` from ``AccessibilityStringProvider/accessibilityString(forKey:)`` for any key
    /// you do not want to override.
    public let provider: (any AccessibilityStringProvider)?

    // MARK: - Init

    /// Creates a new `ChatAccessibility` instance.
    ///
    /// - Parameters:
    ///   - bundle: The bundle to search for `Accessibility.strings` overrides. Defaults to `Bundle.main`.
    ///   - provider: An optional ``AccessibilityStringProvider`` for programmatic overrides. Defaults to `nil`.
    public init(bundle: Bundle = .main, provider: (any AccessibilityStringProvider)? = nil) {
        self.bundle = bundle
        self.provider = provider
    }
}
