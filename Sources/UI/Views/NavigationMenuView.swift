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
    let colors: StyleColors
    
    // MARK: - Builder
    
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            Menu {
                ForEach(items, id: \.name) { item in
                    Button(role: item.role, action: item.action) {
                        Text(item.name)
                        
                        item.icon
                    }
                    // Applies color on the icon, not on the text. The text color is done via NavigationBar appearance update
                    .tint(item.role == .destructive ? colors.status.error : colors.content.primary)
                }
            } label: {
                Asset.menu
            }
        }
    }
}

// MARK: - Methods

extension MenuBuilder {

    func build(colors: StyleColors) -> some View {
        NavigationMenuView(items: items, colors: colors)
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview("one item") {
    @Previewable @Environment(\.colorScheme) var scheme
    let style = ChatStyle()
    
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
        .navigationBarItems(trailing: NavigationMenuView(items: items, colors: style.colors(for: scheme)))
    }
}

@available(iOS 17.0, *)
#Preview("multiple items") {
    @Previewable @Environment(\.colorScheme) var scheme
    let style = ChatStyle()
    
    let items = [
        MenuBuilder.Item(
            name: "First",
            icon: Asset.List.new
        ) {},
        MenuBuilder.Item(
            name: "Second",
            icon: Asset.List.new,
            role: .cancel
        ) {},
        MenuBuilder.Item(
            name: "Third",
            icon: Asset.List.new,
            role: .destructive
        ) {}
    ]

    return NavigationView {
        VStack {
            Text("Background")
        }
        .onAppear {
            UINavigationBar.appearance(for: .light).chatAppearance(with: style.colors.light)
            UINavigationBar.appearance(for: .dark).chatAppearance(with: style.colors.dark)
        }
        .navigationTitle("Page")
        .navigationBarItems(trailing: NavigationMenuView(items: items, colors: style.colors(for: scheme)))
    }
}
