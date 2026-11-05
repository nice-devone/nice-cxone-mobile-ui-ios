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

struct OfflineView: View, Themed {

    // MARK: - Constants

    private enum Constants {

        enum Sizing {
            static let headerCornerRadius: CGFloat = 16
            static let headerIconDimension: CGFloat = 34
            static let imageWidthScale: Double = 1.5
        }

        enum Spacing {
            static let headerContent: CGFloat = 16
            static let spacerMinLength: CGFloat = 30
        }

        enum Padding {
            static let contentTop: CGFloat = 24
            static let contentHorizontal: CGFloat = 16
            static let contentBottom: CGFloat = 12
            static let headerContent: CGFloat = 16
            static let headerIcon: CGFloat = 12
            static let buttonHorizontal: CGFloat = 36
        }
    }

    // MARK: - Properties

    @Environment(\.colorScheme) var scheme

    @EnvironmentObject var style: ChatStyle

    let onButtonTap: () -> Void

    // MARK: - Builder

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: .zero) {
                header

                Spacer(minLength: Constants.Spacing.spacerMinLength)

                Asset.Images.offline.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width / Constants.Sizing.imageWidthScale)
                    .accessibilityHidden(true)

                Spacer(minLength: Constants.Spacing.spacerMinLength)

                Button(role: .destructive, action: onButtonTap) {
                    Text(L10n.Common.closeChat)
                        .frame(maxWidth: StyleGuide.Sizing.Button.maxWidth, alignment: .center)
                }
                .buttonStyle(.destructive)
                .padding(.horizontal, Constants.Padding.buttonHorizontal)
                .accessibilityIdentifier(A11y.OfflineView.ButtonClose.identifier)
                .accessibilityHint(A11y.OfflineView.ButtonClose.hint)
            }
            .padding(.top, Constants.Padding.contentTop)
            .padding(.bottom, Constants.Padding.contentBottom)
            // The content is capped by `overlayMaxWidth`, so the stack has to be stretched explicitly
            // to fill the whole viewport – otherwise the background would only cover the content width
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // `OfflineView` is hosted in its own overlay `UIWindow` (see `OverlayManager`), so nothing
        // at the call site handles safe-area insets. Scoping `.ignoresSafeArea()` to the background
        // lets it bleed under the status bar / home indicator while the content above stays inset —
        // matching `ChatLoadingOverlay`'s full-bleed-background-plus-inset-content composition.
        .background(colors.background.default.ignoresSafeArea())
    }
}

// MARK: - Subviews

private extension OfflineView {

    var header: some View {
        HStack(spacing: Constants.Spacing.headerContent) {
            Asset.Images.clockBadgeZzz.swiftUIImage
                .renderingMode(.template)
                .frame(width: Constants.Sizing.headerIconDimension, height: Constants.Sizing.headerIconDimension)
                .padding(Constants.Padding.headerIcon)
                .foregroundStyle(colors.status.onError)
                .background {
                    Circle()
                        .fill(colors.status.error)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(L10n.LiveChat.Offline.title)
                    .fontWeight(.medium)
                    .foregroundStyle(colors.content.primary)
                
                Text(L10n.LiveChat.Offline.message)
                    .font(.subheadline)
                    .foregroundStyle(colors.content.secondary)
            }
            .multilineTextAlignment(.leading)
        }
        .padding(Constants.Padding.headerContent)
        .frame(maxWidth: StyleGuide.Sizing.overlayMaxWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Constants.Sizing.headerCornerRadius)
                .fill(colors.status.errorContainer)
        )
        .padding(.horizontal, Constants.Padding.contentHorizontal)
    }
}

// MARK: - Previews

// swiftlint:disable hardcoded_strings
@available(iOS 17.0, *)
#Preview {
    @Previewable @StateObject var overlayManager = OverlayManager()
    @Previewable @State var showOffline = false
    
    let chatStyle = ChatStyle()
    NavigationStack {
        VStack {
            Spacer()

            MessageInputView(
                attachmentRestrictions: MockData.attachmentRestrictions,
                attachments: .constant([]),
                isEditing: .constant(false),
                isInputEnabled: .constant(false),
                isSendingMessage: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in

            }
        }
        .onChange(of: showOffline) { show in
            if show {
                overlayManager.show {
                    OfflineView {
                        showOffline = false
                    }
                    .environmentObject(chatStyle)
                }
            } else {
                overlayManager.hide()
            }
        }
        .onAppear {
            showOffline = true
        }
        .navigationTitle("John Doe")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Show Offline") {
                    showOffline = true
                }
            }
        }
        .environmentObject(chatStyle)
    }
}
// swiftlint:enable hardcoded_strings
