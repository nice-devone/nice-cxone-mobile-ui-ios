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

    @EnvironmentObject var style: ChatStyle

    @SwiftUI.Environment(\.colorScheme) var scheme

    let agentName: String?
    let agentImageUrl: URL?
    let isSendTranscriptEnabled: Bool
    let onStartNewChatTapped: () -> Void
    let onBackToConversationTapped: () -> Void
    let onSendTranscriptTapped: () -> Void
    let onCloseChatTapped: () -> Void

    // MARK: - Init

    init(
        thread: ChatThread,
        isSendTranscriptEnabled: Bool,
        onStartNewChatTapped: @escaping () -> Void,
        onBackToConversationTapped: @escaping () -> Void,
        onSendTranscriptTapped: @escaping () -> Void,
        onCloseChatTapped: @escaping () -> Void
    ) {
        // Prefer the currently assigned agent, falling back to the last assigned one.
        let agent = thread.assignedAgent ?? thread.lastAssignedAgent
        // When an agent is present but its personal information is hidden, show the localized
        // "Agent" fallback. When no agent exists at all, keep `nil` so the closed-conversation state is shown.
        self.agentName = agent.map { agent in
            agent.nickname?.nilIfEmpty() ?? agent.fullName ?? L10n.Common.agent
        }
        // Reuse the same default-placeholder filtering applied elsewhere so a hidden/default avatar
        // falls back to the placeholder rather than rendering the backend's generic image.
        self.agentImageUrl = agent?.nonDefaultAvatarImageUrl
        self.isSendTranscriptEnabled = isSendTranscriptEnabled
        self.onStartNewChatTapped = onStartNewChatTapped
        self.onBackToConversationTapped = onBackToConversationTapped
        self.onSendTranscriptTapped = onSendTranscriptTapped
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
                        label: L10n.LiveChat.EndConversation.new,
                        action: onStartNewChatTapped
                    )
                    .foregroundStyle(colors.brand.primary)
                    .accessibilityIdentifier(A11y.EndConversationPopup.ButtonNewChat.identifier)
                    .accessibilityHint(A11y.EndConversationPopup.ButtonNewChat.hint)

                    BottomSheetButton(
                        image: Asset.LiveChat.EndConversation.backToConversation,
                        label: L10n.LiveChat.EndConversation.back,
                        action: onBackToConversationTapped
                    )
                    .foregroundStyle(colors.brand.primary)
                    .accessibilityIdentifier(A11y.EndConversationPopup.ButtonBack.identifier)
                    .accessibilityHint(A11y.EndConversationPopup.ButtonBack.hint)

                    if isSendTranscriptEnabled {
                        BottomSheetButton(
                            image: Asset.sendTranscript,
                            label: L10n.Chat.MenuOption.sendTranscript,
                            action: onSendTranscriptTapped
                        )
                        .foregroundStyle(colors.brand.primary)
                        .accessibilityIdentifier(A11y.EndConversationPopup.ButtonSendTranscript.identifier)
                        .accessibilityHint(A11y.EndConversationPopup.ButtonSendTranscript.hint)
                    }

                    BottomSheetButton(
                        image: Asset.close,
                        label: L10n.Common.closeChat,
                        isDividerVisible: false,
                        action: onCloseChatTapped
                    )
                    .foregroundStyle(colors.content.secondary)
                    .accessibilityIdentifier(A11y.EndConversationPopup.ButtonClose.identifier)
                    .accessibilityHint(A11y.EndConversationPopup.ButtonClose.hint)
                }
            }
            .accessibilityAddTraits(.isModal)
        }
    }
}

// MARK: - Subviews

private extension EndConversationView {

    @ViewBuilder
    var header: some View {
        HStack(spacing: Constants.Spacing.headerTitleIconHorizontal) {
            Text(agentName != nil
                 ? L10n.LiveChat.EndConversation.assignedAgent
                 : L10n.LiveChat.EndConversation.defaultTitle
            )
            .font(.title2.weight(.medium))
            .foregroundStyle(colors.content.primary)
            .accessibilityIdentifier(A11y.EndConversationPopup.Header.Title.identifier)
            .accessibilityAddTraits(.isHeader)

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
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, Constants.Padding.headerHorizontal)

        if let agentName {
            HStack(spacing: Constants.Spacing.agentNameContainerHorizontal) {
                AvatarView(imageUrl: agentImageUrl, initials: agentName == L10n.Common.agent ? nil : initials(from: agentName))
                    .frame(width: Constants.Sizing.agentImageDimension, height: Constants.Sizing.agentImageDimension)

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
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(A11y.EndConversationPopup.Header.AgentInfo.identifier)
            .accessibilityLabel(A11y.EndConversationPopup.Header.AgentInfo.label(agentName))
        }
    }
}

// MARK: - Helpers

private extension EndConversationView {

    func initials(from agentName: String) -> String? {
        // Remove quoted substrings
        let pattern = "\"[^\"]*\""
        let cleaned = agentName.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        let words = cleaned.split(whereSeparator: \.isWhitespace)
        
        // Safely get the first word and its initial; return nil so the avatar falls back to its icon
        guard let first = words.first, let firstInitial = first.first else {
            return nil
        }

        // Single-word username: use only the first initial
        if words.count == 1 {
            return String(firstInitial).uppercased()
        }

        // Ensure there's at least one word and get its initial
        guard let last = words.last, let lastInitial = last.first else {
            return nil
        }
        return (String(firstInitial) + String(lastInitial)).uppercased()
    }
}

// MARK: - Previews

#if DEBUG
import CXoneChatSDK

#Preview("Agent - Image + Name") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                thread: ChatThread(
                    id: LowercaseUUID().uuidString,
                    name: nil,
                    messages: [],
                    assignedAgent: Agent(
                        id: 1,
                        firstName: "John",
                        surname: "Doe",
                        nickname: nil,
                        isBotUser: false,
                        isSurveyUser: false,
                        imageUrl: MockData.imageUrl().absoluteString
                    ),
                    lastAssignedAgent: nil,
                    ownerAssignee: nil,
                    scrollToken: "",
                    state: .closed,
                    positionInQueue: nil
                ),
                isSendTranscriptEnabled: true,
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onSendTranscriptTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
}

#Preview("Agent - Image") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                thread: ChatThread(
                    id: LowercaseUUID().uuidString,
                    name: nil,
                    messages: [],
                    assignedAgent: Agent(
                        id: 1,
                        firstName: nil,
                        surname: nil,
                        nickname: nil,
                        isBotUser: false,
                        isSurveyUser: false,
                        imageUrl: MockData.imageUrl().absoluteString
                    ),
                    lastAssignedAgent: nil,
                    ownerAssignee: nil,
                    scrollToken: "",
                    state: .closed,
                    positionInQueue: nil
                ),
                isSendTranscriptEnabled: true,
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onSendTranscriptTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
}

#Preview("Agent - Name") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                thread: ChatThread(
                    id: LowercaseUUID().uuidString,
                    name: nil,
                    messages: [],
                    assignedAgent: Agent(
                        id: 1,
                        firstName: "John",
                        surname: "Doe",
                        nickname: nil,
                        isBotUser: false,
                        isSurveyUser: false,
                        imageUrl: nil
                    ),
                    lastAssignedAgent: nil,
                    ownerAssignee: nil,
                    scrollToken: "",
                    state: .closed,
                    positionInQueue: nil
                ),
                isSendTranscriptEnabled: true,
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onSendTranscriptTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
}

#Preview("Agent - Hidden Personal Data") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                thread: ChatThread(
                    id: LowercaseUUID().uuidString,
                    name: nil,
                    messages: [],
                    assignedAgent: Agent(
                        id: 1,
                        firstName: nil,
                        surname: nil,
                        nickname: nil,
                        isBotUser: false,
                        isSurveyUser: false,
                        imageUrl: nil
                    ),
                    lastAssignedAgent: nil,
                    ownerAssignee: nil,
                    scrollToken: "",
                    state: .closed,
                    positionInQueue: nil
                ),
                isSendTranscriptEnabled: true,
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onSendTranscriptTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
}

#Preview("No Agent") {
    Color.clear
        .fullScreenCover(isPresented: .constant(true)) {
            EndConversationView(
                thread: ChatThread(
                    id: LowercaseUUID().uuidString,
                    name: nil,
                    messages: [],
                    assignedAgent: nil,
                    lastAssignedAgent: nil,
                    ownerAssignee: nil,
                    scrollToken: "",
                    state: .closed,
                    positionInQueue: nil
                ),
                isSendTranscriptEnabled: true,
                onStartNewChatTapped: { },
                onBackToConversationTapped: { },
                onSendTranscriptTapped: { },
                onCloseChatTapped: { }
            )
        }
    .environmentObject(ChatStyle())
}
#endif
