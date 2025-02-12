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

import Foundation
import SwiftUI

open class NavigationItem: ObservableObject {
    
    typealias Left = NavigationAction
    typealias Title = Text
    typealias Action = NavigationAction
    typealias Content = AnyView

    // MARK: - Properties
    
    @Published var left: Left?
    @Published var title: Title?
    @Published var right: [Action]
    @Published var content: () -> Content

    // MARK: - Init
    
    init(
        left: Left? = nil,
        title: Title? = nil,
        right: [NavigationAction] = [],
        @ViewBuilder content: @escaping () -> Content = { AnyView(EmptyView()) }
    ) {
        self.left = left
        self.title = title
        self.right = right
        self.content = content
    }

    convenience init<ActualContent: View>(
        left: Left? = nil,
        title: Title? = nil,
        right: [NavigationAction] = [],
        @ViewBuilder content: @escaping () -> ActualContent
    ) {
        self.init(left: left, title: title, right: right) { AnyView(content()) }
    }

    // MARK: - Methods
    
    func set(title: String) {
        self.title = Text(title)
    }
}
