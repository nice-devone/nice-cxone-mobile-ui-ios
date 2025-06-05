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

struct NavigationMenuView: View {
    
    // MARK: - Properties

    let items: [MenuBuilder.Item]

    static let maxInline = 1
    
    // MARK: - Builder
    
    var body: some View {
        HStack {
            if items.count > Self.maxInline {
                Menu {
                    ForEach(items, id: \.name) { item in
                        Button(action: item.action) {
                            HStack(alignment: .center) {
                                item.icon.padding(.leading)

                                Text(item.name)
                            }
                        }
                    }
                } label: {
                    Asset.menu.rotationEffect(.degrees(90))
                }
            } else {
                ForEach(items, id: \.name) { item in
                    Button(action: item.action) {
                        item.icon
                    }
                }
            }
        }
    }
}

// MARK: - Methods

extension MenuBuilder {

    func build(colors: StyleColors) -> some View {
        NavigationMenuView(items: items)
            .foregroundStyle(colors.customizable.primary)
    }
}

// MARK: - Previews

#Preview("one item") {
    let items = [
        MenuBuilder.Item(
            name: ChatLocalization().chatListNewThread,
            icon: Asset.List.new
        ) {}
    ]

    return NavigationView {
        VStack {
            Text("Background")
        }
        .navigationTitle("Page")
        .navigationBarItems(trailing: NavigationMenuView(items: items))
    }
}

#Preview("multiple items") {
    let items = [
        MenuBuilder.Item(
            name: "First",
            icon: Asset.List.new
        ) {},
        MenuBuilder.Item(
            name: "Second",
            icon: Asset.List.new
        ) {},
        MenuBuilder.Item(
            name: "Third",
            icon: Asset.List.new
        ) {}
    ]

    return NavigationView {
        VStack {
            Text("Background")
        }
        .navigationTitle("Page")
        .navigationBarItems(trailing: NavigationMenuView(items: items))
    }
}
