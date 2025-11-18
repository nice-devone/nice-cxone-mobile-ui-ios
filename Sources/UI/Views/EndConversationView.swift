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

import CXoneChatSDK
import Kingfisher
import SwiftUI

struct EndConversationView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
    
        enum Sizing {
            static let headerImageDimension: CGFloat = 22
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
            static let headerImagefallback: CGFloat = 10
            static let agentNameContainerInner: CGFloat = 16
            static let agentNameContainerOuterHorizontal: CGFloat = 16
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    let agentName: String?
    let agentImageUrl: String?
    let onStartNewChatTapped: () -> Void
    let onBackToConversationTapped: () -> Void
    let onCloseChatTapped: () -> Void
    
    private var title: String {
        agentName != nil
            ? self.localization.liveChatEndConversationAssignedAgent
            : self.localization.liveChatEndConversationDefaultTitle
    }
    
    // MARK: - Init
    
    init(
        agentName: String?,
        agentImageUrl: String?,
        onStartNewChatTapped: @escaping () -> Void,
        onBackToConversationTapped: @escaping () -> Void,
        onCloseChatTapped: @escaping () -> Void
    ) {
        self.agentName = agentName
        self.agentImageUrl = agentImageUrl
        self.onStartNewChatTapped = onStartNewChatTapped
        self.onBackToConversationTapped = onBackToConversationTapped
        self.onCloseChatTapped = onCloseChatTapped
    }
    
    init(
        thread: ChatThread,
        onStartNewChatTapped: @escaping () -> Void,
        onBackToConversationTapped: @escaping () -> Void,
        onCloseChatTapped: @escaping () -> Void
    ) {
        self.agentName = thread.assignedAgent?.fullName ?? thread.lastAssignedAgent?.fullName
        self.agentImageUrl = thread.assignedAgent?.imageUrl ?? thread.lastAssignedAgent?.imageUrl
        self.onStartNewChatTapped = onStartNewChatTapped
        self.onBackToConversationTapped = onBackToConversationTapped
        self.onCloseChatTapped = onCloseChatTapped
    }
    
    // MARK: - Builder
    
    var body: some View {
        BottomSheetView {
            VStack(alignment: .leading, spacing: Constants.Spacing.contentVertical) {
                header
                
                VStack(alignment: .leading, spacing: Constants.Spacing.buttonsVertical) {
                    BottomSheetButton(
                        image: Asset.LiveChat.EndConversation.startNewChat,
                        label: localization.liveChatEndConversationNew,
                        action: onStartNewChatTapped
                    )
                    .foregroundStyle(colors.brand.primary)
                    
                    BottomSheetButton(
                        image: Asset.LiveChat.EndConversation.backToConversation,
                        label: localization.liveChatEndConversationBack,
                        action: onBackToConversationTapped
                    )
                    .foregroundStyle(colors.brand.primary)
                    
                    BottomSheetButton(
                        image: Asset.close,
                        label: localization.commonCloseChat,
                        isDividerVisible: false,
                        action: onCloseChatTapped
                    )
                    .foregroundStyle(colors.content.secondary)
                }
            }
        }
    }
}

// MARK: - Subviews

private extension EndConversationView {

    @ViewBuilder
    var header: some View {
        HStack(spacing: Constants.Spacing.headerTitleIconHorizontal) {
            Text(title)
                .font(.title2.weight(.medium))
                .foregroundStyle(colors.content.primary)
            
            if agentName == nil {
                Spacer(minLength: Constants.Spacing.headerTitleIconSpacerMinLength)
                
                Asset.Images.closedConversation.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.Sizing.headerImageDimension, height: Constants.Sizing.headerImageDimension)
                    .foregroundStyle(colors.status.onErrorContainer)
                    .padding(Constants.Padding.headerImage)
                    .background {
                        Circle()
                            .fill(colors.status.errorContainer)
                    }
            }
        }
        .padding(.horizontal, Constants.Padding.headerHorizontal)
        
        if let agentName {
            HStack(spacing: Constants.Spacing.agentNameContainerHorizontal) {
                if let agentImageUrl, let url = URL(string: agentImageUrl) {
                    KFImage(url)
                        .placeholder { progress in
                            ProgressView(value: progress.fractionCompleted)
                                .background {
                                    Circle()
                                        .strokeBorder(colors.border.default, lineWidth: Constants.Sizing.agentImagePlaceholderBorderWidth)
                                }
                        }
                        .onFailureView {
                            Asset.Message.fallbackAvatar
                                .font(.title3)
                                .foregroundStyle(colors.content.primary)
                                .padding(Constants.Padding.headerImagefallback)
                                .background {
                                    Circle()
                                        .fill(colors.brand.primaryContainer)
                                }
                        }
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.Sizing.agentImageDimension, height: Constants.Sizing.agentImageDimension)
                        .clipShape(.circle)
                }
                
                Text(agentName)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(colors.content.primary)
                
                Spacer()
            }
            .padding(Constants.Padding.agentNameContainerInner)
            .background {
                RoundedRectangle(cornerRadius: Constants.Sizing.agentNameContainerCornerRadius)
                    .strokeBorder(colors.border.default, lineWidth: Constants.Sizing.agentNameContainerBorderWidth)
            }
            .padding(.horizontal, Constants.Padding.agentNameContainerOuterHorizontal)
        }
    }
}

// MARK: - Previews

#Preview("Agent with URL") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                agentName: "John Doe",
                agentImageUrl: MockData.imageUrl.absoluteString,
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}

#Preview("Agent with incorrect URL") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                agentName: "John Doe",
                agentImageUrl: "https://www.google.com",
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}

#Preview("Agent without URL") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                agentName: "John Doe",
                agentImageUrl: nil,
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}

#Preview("No Agent") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                agentName: nil,
                agentImageUrl: nil,
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
