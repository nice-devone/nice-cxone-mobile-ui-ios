//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

struct NavigationAction: View {
    
    // MARK: - Properties
    
    // Note that id is necessary to distinguish between two buttons with the same image
    // and title but different actions, e.g. stacked back buttons.  Otherwise, NavigationBar
    // doesn't detect the button change so doesn't use the correct action.
    private let id = UUID()
    
    let title: String
    let image: Image
    let action: () -> Void

    // MARK: - Init
    
    init(title: String, image: Image, action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.action = action
    }
    
    // MARK: - Builder
    
    var body: some View {
        Button(action: action) {
            HStack {
                image
                    .imageScale(.large)
                
                Text(title)
            }
        }
    }
}

// MARK: - Hashable

extension NavigationAction: Hashable {

    static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.image == rhs.image
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

// MARK: - Helpers

extension NavigationAction {
    
    static func back(title: String, action: @escaping () -> Void) -> NavigationAction {
        NavigationAction(title: title, image: Image(systemName: "chevron.backward"), action: action)
    }

    static func down(title: String, action: @escaping () -> Void) -> NavigationAction {
        NavigationAction(title: title, image: Image(systemName: "chevron.down"), action: action)
    }
}
