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

// MARK: - Button<Text>

extension Button where Label == Text {
    /// Creates a button that generates its label from a localized string key.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button.
    ///   - role: An optional semantic role that describes the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil) {
        self.init(titleKey, role: role) {
            // No action
        }
    }
    
    /// Creates a button that generates its label from a string.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button.
    ///   - role: An optional semantic role that describes the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    init<S: StringProtocol>(_ title: S, role: ButtonRole? = nil) {
        self.init(title, role: role) {
            // No action
        }
    }
}

// MARK: - Button<Text, Image>

extension Button where Label == SwiftUI.Label<Text, Image> {
    /// Creates a button that generates its label from a localized string key
    /// and system image name.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - role: An optional semantic role that describes the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    init(_ titleKey: LocalizedStringKey, systemImage: String, role: ButtonRole? = nil) {
        self.init(titleKey, systemImage: systemImage, role: role) {
            // No action
        }
    }
    /// Creates a button that generates its label from a string and
    /// system image name.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - role: An optional semantic role that describes the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    init<S: StringProtocol>(_ title: S, systemImage: String, role: ButtonRole? = nil) {
        self.init(title, systemImage: systemImage, role: role) {
            // No action
        }
    }
}

// MARK: - Button<View>

extension Button where Label: View {
    /// Creates a button that displays a custom label.
    ///
    /// - Parameters:
    ///   - role: An optional semantic role that describes the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - label: A view that describes the purpose of the button's `action`.
    init(role: ButtonRole? = nil, @ViewBuilder label: () -> Label) {
        self.init(role: role, action: {}, label: label)
    }
}
