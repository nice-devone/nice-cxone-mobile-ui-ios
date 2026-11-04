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

import Combine
import CXoneChatSDK
import SwiftUI

struct InactivityPopupView: View, Themed {

    // MARK: - Constants

    private enum Constants {

        enum Sizing {
            static let headerImageDimension: CGFloat = 24
        }
        enum Spacing {
            static let contentVertical: CGFloat = 16
            static let headerTitleIconHorizontal: CGFloat = 0
            static let headerTitleIconSpacerMinLength: CGFloat = 8
            static let buttonsVertical: CGFloat = 0
        }
        enum Padding {
            static let headerImage: CGFloat = 10
        }
    }

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @SwiftUI.Environment(\.colorScheme) var scheme

    @State private var isTimedOut = false
    @State private var secondsRemaining: Int

    let title: String
    let message: String
    let refreshButtonText: String
    let expireButtonText: String
    let onRefresh: () -> Void
    let onExpire: () -> Void
    let onTimeout: () -> Void

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Init

    init(
        title: String,
        message: String,
        startedAt: Date,
        numberOfSeconds: Int,
        refreshButtonText: String,
        expireButtonText: String,
        onRefresh: @escaping () -> Void,
        onExpire: @escaping () -> Void,
        onTimeout: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self._secondsRemaining = State(initialValue: Self.calculateSecondsRemaining(from: startedAt, totalSeconds: numberOfSeconds))
        self.refreshButtonText = refreshButtonText
        self.expireButtonText = expireButtonText
        self.onRefresh = onRefresh
        self.onExpire = onExpire
        self.onTimeout = onTimeout
    }

    // MARK: - Builder

    var body: some View {
        BottomSheetView {
            VStack(alignment: .leading, spacing: Constants.Spacing.contentVertical) {
                header
                
                if !isTimedOut {
                    VStack(alignment: .leading, spacing: Constants.Spacing.buttonsVertical) {
                        BottomSheetButton(
                            image: Asset.LiveChat.Inactivity.refresh,
                            label: refreshButtonText,
                            action: onRefresh
                        )
                        .foregroundStyle(colors.brand.primary)
                        .accessibilityIdentifier(A11y.InactivityPopup.ButtonRefresh.identifier)
                        .accessibilityHint(A11y.InactivityPopup.ButtonRefresh.hint)

                        BottomSheetButton(
                            image: Asset.close,
                            label: expireButtonText,
                            isDividerVisible: false,
                            action: onExpire
                        )
                        .foregroundStyle(colors.content.tertiary)
                        .accessibilityIdentifier(A11y.InactivityPopup.ButtonExpire.identifier)
                        .accessibilityHint(A11y.InactivityPopup.ButtonExpire.hint)
                    }
                }
            }
            .accessibilityAddTraits(.isModal)
        }
        .onReceive(timer) { _ in
            guard !isTimedOut else {
                return
            }

            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                isTimedOut = true
                onTimeout()
            }
        }
        .animation(.default, value: isTimedOut)
    }
}

// MARK: - Subviews

private extension InactivityPopupView {

    var header: some View {
        HStack(spacing: Constants.Spacing.headerTitleIconHorizontal) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isTimedOut ? L10n.LiveChat.InactivityPopup.SessionTimeout.title : formattedTitle)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(colors.content.primary)

                Text(isTimedOut ? L10n.LiveChat.InactivityPopup.SessionTimeout.text : message)
                    .font(.callout)
                    .foregroundStyle(colors.content.tertiary)
            }

            Spacer(minLength: Constants.Spacing.headerTitleIconSpacerMinLength)

            Asset.Images.inactivityIcon.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: Constants.Sizing.headerImageDimension, height: Constants.Sizing.headerImageDimension)
                .foregroundStyle(colors.status.onWarningContainer)
                .padding(Constants.Padding.headerImage)
                .background {
                    Circle()
                        .fill(colors.status.warningContainer)
                }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(
            isTimedOut
                ? A11y.InactivityPopup.Header.TimedOut.identifier
                : A11y.InactivityPopup.Header.Active.identifier
        )
        .accessibilityLabel(
            isTimedOut
                ? A11y.InactivityPopup.Header.TimedOut.label
                : A11y.InactivityPopup.Header.Active.label
        )
        .accessibilityAddTraits(.isHeader)
        .if(!isTimedOut) { view in
            view
                .accessibilityValue(A11y.InactivityPopup.Header.Active.value(formattedTimeRemaining))
                .accessibilityAddTraits(.updatesFrequently)
        }
    }
}

// MARK: - Helpers

private extension InactivityPopupView {

    var formattedTimeRemaining: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedTitle: String {
        String(format: "%@ %@", title, formattedTimeRemaining)
    }

    static func calculateSecondsRemaining(from startedAt: Date, totalSeconds: Int) -> Int {
        let elapsedSeconds = Int(Date.now.timeIntervalSince(startedAt))
        let remaining = totalSeconds - elapsedSeconds

        return max(remaining, 0)
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    @Previewable @StateObject var overlayManager = OverlayManager()
    let style = ChatStyle()

    Color.clear
        .onAppear {
            overlayManager.show {
                InactivityPopupView(
                    title: "Your chat will expire in",
                    message: "When the time expires, the conversation is terminated. Would you like to continue?",
                    startedAt: Date.now.addingTimeInterval(-54),
                    numberOfSeconds: 60,
                    refreshButtonText: "Continue",
                    expireButtonText: "Cancel",
                    onRefresh: {},
                    onExpire: {},
                    onTimeout: {}
                )
                .environmentObject(style)
            }
        }
        .onDisappear {
            overlayManager.hide()
        }
        .environmentObject(style)
}
