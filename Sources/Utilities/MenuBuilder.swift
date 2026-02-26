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

/// Build a list of optional and non optional menu items.
struct MenuBuilder {

    // MARK: - Sub Objects

    struct Item {
        let name: String
        let icon: Image
        let role: ButtonRole?
        let action: () -> Void
        
        init(name: String, icon: Image, role: ButtonRole? = nil, action: @escaping () -> Void) {
            self.name = name
            self.icon = icon
            self.role = role
            self.action = action
        }
    }

    // MARK: - Properties

    let items: [Item]

    // MARK: - Init

    private init(items: [Item]) {
        self.items = items
    }

    init() {
        self.items = []
    }

    // MARK: - Methods
    
    func add(if condition: Bool = true, name: String, icon: Image, role: ButtonRole? = nil, action: @escaping () -> Void) -> Self {
        if condition {
            Self(items: items + [Item(name: name, icon: icon, role: role, action: action)])
        } else {
            self
        }
    }
}
