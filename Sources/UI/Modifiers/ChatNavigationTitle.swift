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

/// Applies the conversation title and the "AI Assistant" authorship indicator using the best mechanism per OS version.
///
/// The modifier picks one of two rendering strategies based on the runtime OS, since the SwiftUI APIs available for
/// placing a secondary label beneath the navigation title differ significantly between iOS 26 and earlier versions.
///
/// - iOS 26+: keeps the standard ``SwiftUI/View/navigationTitle(_:)`` and attaches the ``AiAssistantBadgeView`` as
///   toolbar items at the `.largeSubtitle` and `.subtitle` placements. This lets the system collapse the badge in
///   sync with the title when the navigation bar transitions between large and inline layouts.
/// - iOS < 26: those subtitle placements do not exist, so when ``isAiAssistant`` is `true` the title is cleared and
///   `navigationBarTitleDisplayMode(_:)` is forced to `.inline`. The title text and ``AiAssistantBadgeView`` are then
///   rendered together as a stacked `.principal` toolbar item. When ``isAiAssistant`` is `false` the modifier falls
///   through to the default large title with no badge.
///
/// - Parameters:
///   - title: The conversation title shown in the navigation bar.
///   - isAiAssistant: When `true`, the "AI Assistant" authorship indicator is displayed alongside the title.
struct ChatNavigationTitle: ViewModifier {

    // MARK: - Constants

    private enum Constants {
        enum Spacing {
            static let legacyBadgeContent: CGFloat = 4
        }
        enum Padding {
            static let legacyBadgeBottom: CGFloat = 10
        }
    }

    // MARK: - Properties

    let title: String
    let isAiAssistant: Bool

    // MARK: - Builder

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationTitle(title)
                .toolbar {
                    if isAiAssistant {
                        ToolbarItem(placement: .largeSubtitle) {
                            HStack(spacing: .zero) {
                                AiAssistantBadgeView()
                                
                                Spacer()
                            }
                        }
                        
                        ToolbarItem(placement: .subtitle) {
                            AiAssistantBadgeView()
                        }
                    }
                }
        } else {
            content
                .navigationTitle(isAiAssistant ? "" : title)
                .navigationBarTitleDisplayMode(isAiAssistant ? .inline : .large)
                .toolbar {
                    if isAiAssistant {
                        ToolbarItem(placement: .principal) {
                            VStack(spacing: Constants.Spacing.legacyBadgeContent) {
                                Text(title)
                                    .font(.headline)

                                AiAssistantBadgeView()
                            }
                            .padding(.bottom, Constants.Padding.legacyBadgeBottom)
                        }
                    }
                }
        }
    }
}

// MARK: - Preview

// swiftlint:disable hardcoded_strings
#Preview("Default") {
    NavigationStack {
        Color.clear
            .modifier(
                ChatNavigationTitle(
                    title: "Peter Parker",
                    isAiAssistant: false
                )
            )
    }
    .environmentObject(ChatStyle())
}

#Preview("AI Badge") {
    NavigationStack {
        VStack {
            Text("On iOS 26+, the AI badge appears alongside the large title. On legacy systems, it falls back to `.inline`.")

            Divider()

            Text("Device System Version: \(UIDevice.current.systemVersion)")
        }
        .padding(.horizontal, 12)
        .modifier(
            ChatNavigationTitle(
                title: "Chat Bot",
                isAiAssistant: true
            )
        )
    }
    .environmentObject(ChatStyle())
}
// swiftlint:enable hardcoded_strings
