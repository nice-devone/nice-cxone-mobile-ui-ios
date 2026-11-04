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

extension View {

    /// Applies a chat screen's navigation title using the best mechanism per OS version and the
    /// requested ``ChatNavigationTitle/Style``.
    ///
    /// - Parameters:
    ///   - title: The title shown in the navigation bar.
    ///   - isAiAssistant: When `true` (``ChatNavigationTitle/Style/large`` only), the "AI Assistant"
    ///     authorship indicator is displayed alongside the title.
    ///   - style: How the title should be displayed. Defaults to ``ChatNavigationTitle/Style/large``.
    func chatNavigationTitle(_ title: String, isAiAssistant: Bool = false, style: ChatNavigationTitle.Style = .large) -> some View {
        modifier(ChatNavigationTitle(title: title, isAiAssistant: isAiAssistant, style: style))
    }
}

// MARK: - ChatNavigationTitle

/// Applies a chat screen's navigation title using the best mechanism per OS version and per
/// screen's desired title style.
///
/// ``Style/inline`` is OS-agnostic — it uses none of the iOS 26-only APIs that make ``Style/large``
/// fork on OS (the `.largeSubtitle` / `.subtitle` badge placements, and the compact-height title
/// fallback), so the same rendering applies on every supported version.
///
/// For ``Style/large``, the modifier picks one of two rendering strategies based on the runtime
/// OS, since the SwiftUI APIs available for placing a secondary label beneath the navigation
/// title differ significantly between iOS 26 and earlier versions:
///
/// - iOS 26+: keeps the standard ``SwiftUI/View/navigationTitle(_:)`` and
///   attaches the ``AiAssistantBadgeView`` as toolbar items at the `.largeSubtitle` and `.subtitle`
///   placements when `isAiAssistant` is `true`. This lets the system collapse the badge in sync
///   with the title when the navigation bar transitions between large and inline layouts.
/// - iOS < 26: those subtitle placements do not exist, so when `isAiAssistant` is `true` the title
///   is cleared and `navigationBarTitleDisplayMode(_:)` is forced to `.inline`. The title text and
///   ``AiAssistantBadgeView`` are then rendered together as a stacked `.principal` toolbar item.
///
/// Independently of the AI badge, ``Style/large`` also supplies a theme-aware `.principal` title
/// as a fallback on iOS 26, but only when the system forces the collapsed/inline navigation bar for
/// compact-height layouts (e.g. landscape iPhone): iOS 26's native inline title does not resolve its
/// color against the current color scheme correctly there when the content behind the bar extends
/// its own `.background(...)`. This fallback is scoped to iOS 26+ / compact height because that is
/// exactly where the native title breaks; regular-height layouts keep the SwiftUI-drawn large title,
/// and iOS < 26 never exhibited this bug.
struct ChatNavigationTitle: ViewModifier, Themed {

    /// How a screen wants its navigation title displayed.
    enum Style {

        /// Always renders the title as a theme-aware, inline `.principal` toolbar item; never
        /// shows the SwiftUI large title. For detail/viewer screens (e.g. `ImageViewer`) that
        /// never want a large title, in any color scheme or orientation.
        case inline

        /// Renders the standard SwiftUI large title in regular-height layouts, plus the AI badge
        /// (if requested) and the compact-height title-color fallback described above. For
        /// list/root screens (e.g. `ThreadListView`, `ThreadView`).
        case large
    }

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

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let title: String
    let isAiAssistant: Bool
    let titleStyle: Style

    // MARK: - Init

    init(title: String, isAiAssistant: Bool = false, style titleStyle: Style = .large) {
        self.title = title
        self.isAiAssistant = isAiAssistant
        self.titleStyle = titleStyle
    }

    // MARK: - Builder

    func body(content: Content) -> some View {
        switch titleStyle {
        case .inline:
            // Nothing about `.inline` varies by OS: it uses none of the iOS 26-only APIs
            // (the `.largeSubtitle` / `.subtitle` badge placements, and the compact-height
            // title fallback) that make `.large` fork on `#available`, so it's handled once
            // here instead of duplicated per OS.
            inlineBody(content)

        case .large:
            if #available(iOS 26.0, *) {
                modernLargeBody(content)
            } else {
                legacyLargeBody(content)
            }
        }
    }
}

// MARK: - Private Body Builders

private extension ChatNavigationTitle {

    func inlineBody(_ content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    themedPrincipalTitle
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }

    @available(iOS 26.0, *)
    func modernLargeBody(_ content: Content) -> some View {
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

                // Independent of the AI badge above: whenever the system forces the
                // collapsed/inline bar for compact-height layouts (e.g. landscape iPhone),
                // supply the theme-aware fallback regardless of `isAiAssistant` — the native
                // inline title's color-resolution bug applies to both cases equally.
                if verticalSizeClass == .compact {
                    ToolbarItem(placement: .principal) {
                        themedPrincipalTitle
                    }
                }
            }
    }

    func legacyLargeBody(_ content: Content) -> some View {
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

    var themedPrincipalTitle: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(colors.content.primary)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Preview

// swiftlint:disable hardcoded_strings
#Preview("Default") {
    NavigationStack {
        Color.clear
            .chatNavigationTitle("Peter Parker")
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
        .chatNavigationTitle("Chat Bot", isAiAssistant: true)
    }
    .environmentObject(ChatStyle())
}

#Preview("Inline") {
    NavigationStack {
        Color.clear
            .chatNavigationTitle("image.png", style: .inline)
    }
    .environmentObject(ChatStyle())
}
// swiftlint:enable hardcoded_strings
