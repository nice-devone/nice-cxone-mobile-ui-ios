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

struct NavigationMenuView: View {
    
    // MARK: - Properties

    let items: [MenuBuilder.Item]
    let colors: StyleColors
    
    // MARK: - Builder
    
    @ViewBuilder
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            menuContent
        }
    }

    private var menuContent: some View {
        Menu {
            ForEach(items, id: \.name) { item in
                menuButton(for: item)
            }
        } label: {
            Asset.menu
                .accessibilityHidden(true)
        }
        .accessibilityIdentifier(A11y.ChatContainer.NavigationBar.ButtonMenu.identifier)
        .accessibilityLabel(A11y.ChatContainer.NavigationBar.ButtonMenu.label)
        .accessibilityHint(A11y.ChatContainer.NavigationBar.ButtonMenu.hint)
    }

    private func menuButton(for item: MenuBuilder.Item) -> some View {
        Button(role: item.role, action: item.action) {
            Text(item.name)

            item.icon
        }
        // Applies color on the icon, not on the text. The text color is done via NavigationBar appearance update
        .tint(item.role == .destructive ? colors.status.error : colors.content.primary)
        .accessibilityIdentifier(A11y.ChatContainer.NavigationBar.ButtonMenu.Option.identifier(item.name))
        .accessibilityHint(A11y.ChatContainer.NavigationBar.ButtonMenu.Option.hint)
    }
}

// MARK: - Methods

extension MenuBuilder {

    @MainActor
    func build(colors: StyleColors) -> some View {
        NavigationMenuView(items: items, colors: colors)
    }
}

// MARK: - Preview

// swiftlint:disable hardcoded_strings
@available(iOS 17.0, *)
#Preview {
    @Previewable @Environment(\.colorScheme) var scheme
    let style = ChatStyle()

    let items = [
        MenuBuilder.Item(
            name: L10n.Chat.MenuOption.updateName,
            icon: Asset.ChatThread.editThreadName
        ) {},
        MenuBuilder.Item(
            name: L10n.Chat.MenuOption.editCustomFields,
            icon: Asset.ChatThread.editPrechatCustomFields
        ) {},
        MenuBuilder.Item(
            name: L10n.Chat.MenuOption.sendTranscript,
            icon: Asset.sendTranscript
        ) {},
        MenuBuilder.Item(
            name: L10n.Chat.MenuOption.endConversation,
            icon: Asset.close,
            role: .destructive
        ) {}
    ]

    return NavigationStack {
        VStack {
            Text("Background")
        }
        .navigationTitle("Page")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationMenuView(items: items, colors: style.colors(for: scheme))
            }
        }
    }
}
// swiftlint:enable hardcoded_strings
