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

/// A protocol for providing custom localization strings to the CXoneChatUI SDK.
///
/// Implement this protocol to programmatically override individual strings
/// without creating or modifying a `CXOneChatUI.strings` file.
/// Return `nil` for any key you do not want to override — the SDK will fall back
/// to the bundle lookup and then to its own built-in default.
///
/// String keys match the keys in `CXOneChatUI.strings` (e.g. `"common.confirm"`).
///
/// - Note: This is the programmatic counterpart to the bundle-based approach.
///   Use it for a small number of targeted overrides or for dynamic runtime resolution.
///   For full language support, the bundle-based approach with `.lproj` files is recommended.
///
/// ## Example
/// ```swift
/// class MyLocalizationProvider: LocalizationStringProvider {
///     func localizationString(forKey key: String) -> String? {
///         switch key {
///         case "common.confirm":
///             return "Done"
///         case "common.close_chat":
///             return "End chat"
///         default:
///             return nil
///         }
///     }
/// }
/// ```
public protocol LocalizationStringProvider {

    /// Returns a custom string for the given localization key, or `nil` to use the SDK default.
    ///
    /// - Parameter key: The localization string key (e.g. `"common.confirm"`).
    /// - Returns: A custom string, or `nil` to defer to the bundle lookup or SDK default.
    func localizationString(forKey key: String) -> String?
}
