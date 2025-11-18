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

import Combine
import CXoneChatSDK
import SwiftUI

struct InactivityPopupView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
    
        enum Sizing {
            static let headerImageDimension: CGFloat = 24
            static let agentImageDimension: CGFloat = 40
            static let agentImagePlaceholderBorderWidth: CGFloat = 1
            static let agentNameContainerCornerRadius: CGFloat = 12
            static let agentNameContainerBorderWidth: CGFloat = 1
        }
        enum Spacing {
            static let contentVertical: CGFloat = 16
            static let headerTitleIconHorizontal: CGFloat = 0
            static let headerTitleIconSpacerMinLength: CGFloat = 8
            static let agentNameContainerHorizontal: CGFloat = 16
            static let buttonsVertical: CGFloat = 0
        }
        enum Padding {
            static let headerHorizontal: CGFloat = 24
            static let headerImage: CGFloat = 10
            static let agentNameContainerInner: CGFloat = 16
            static let agentNameContainerOuterHorizontal: CGFloat = 16
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
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
        onExpire: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self._secondsRemaining = State(initialValue: Self.calculateSecondsRemaining(from: startedAt, totalSeconds: numberOfSeconds))
        self.refreshButtonText = refreshButtonText
        self.expireButtonText = expireButtonText
        self.onRefresh = onRefresh
        self.onExpire = onExpire
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
                        
                        BottomSheetButton(
                            image: Asset.close,
                            label: expireButtonText,
                            isDividerVisible: false,
                            action: onExpire
                        )
                        .foregroundStyle(colors.content.tertiary)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                isTimedOut = true
                timer.upstream
                    .connect()
                    .cancel()
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
                Text(isTimedOut ? localization.liveChatInactivityTimeoutTitle : formattedTitle)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(colors.content.primary)
                
                Text(isTimedOut ? localization.liveChatInactivityTimeoutText : message)
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
        .padding(.horizontal, Constants.Padding.headerHorizontal)
    }
}

// MARK: - Helpers

private extension InactivityPopupView {
    
    var formattedTitle: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        let timeText = String(format: "%d:%02d", minutes, seconds)
        
        return String(format: "%@ %@", title, timeText)
    }
    
    static func calculateSecondsRemaining(from startedAt: Date, totalSeconds: Int) -> Int {
        let elapsedSeconds = Int(Date.now.timeIntervalSince(startedAt))
        let remaining = totalSeconds - elapsedSeconds
        
        return max(remaining, 0)
    }
}

// MARK: - Preview

#Preview {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            InactivityPopupView(
                title: "Your chat will expire in",
                message: "When the time expires, the conversation is terminated. Would you like to continue?",
                startedAt: Date.now.addingTimeInterval(-54),
                numberOfSeconds: 60,
                refreshButtonText: "Continue",
                expireButtonText: "Cancel",
                onRefresh: {},
                onExpire: {}
            )
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
