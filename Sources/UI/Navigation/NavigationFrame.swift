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

struct NavigationFrame: View {
    
    // MARK: - Properties
    
    @ObservedObject var current: NavigationItem

    // MARK: - Init
    
    init(current: NavigationItem) {
        self.current = current
    }

    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: 0.0) {
            NavigationBar(item: $current)
            
            current.content()
                .frame(maxHeight: .infinity)
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    @ObservedObject var item = NavigationItem(
        left: .down(title: "down") { },
        title: Text("Title")
    ) {
        ZStack {
            Color.blue
            
            Text("Body")
        }
        .ignoresSafeArea()
    }

    return NavigationFrame(current: item)
}

#Preview("Dark Mode") {
    @ObservedObject var item = NavigationItem(
        left: .down(title: "down") { },
        title: Text("Title")
    ) {
        ZStack {
            Color.blue
            
            Text("Body")
        }
        .ignoresSafeArea()
    }

    return NavigationFrame(current: item)
        .preferredColorScheme(.dark)
}
