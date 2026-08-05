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

/// A protocol for providing custom accessibility strings to the CXoneChatUI SDK.
///
/// Implement this protocol to programmatically override individual accessibility strings
/// without replacing the entire `Accessibility.strings` file.
/// Return `nil` for any key you do not want to override — the SDK will fall back to its own default.
///
/// String keys match the keys in `Accessibility.strings` (e.g. `"message_input.button_send.hint_enabled"`).
///
/// - Note: Parameterized strings (e.g. `"Agent %1$@ has joined the conversation"`) must use
///   the same `%1$@` positional format as the SDK's own strings.
///
/// ## Example
/// ```swift
/// class MyA11yProvider: AccessibilityStringProvider {
///
///     func accessibilityString(forKey key: String) -> String? {
///         switch key {
///         case "form.button_confirm.valid.hint":
///             return "Double-tap to submit"
///         default:
///             return nil
///         }
///     }
/// }
/// ```
public protocol AccessibilityStringProvider {

    /// Returns a custom string for the given accessibility key, or `nil` to use the SDK default.
    ///
    /// - Parameter key: The accessibility string key (e.g. `"message_input.button_send.hint_enabled"`).
    /// - Returns: A custom string, or `nil` to defer to the SDK default.
    func accessibilityString(forKey key: String) -> String?
}
