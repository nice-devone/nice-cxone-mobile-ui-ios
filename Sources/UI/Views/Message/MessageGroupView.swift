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

import CXoneChatSDK
import SwiftUI

struct MessageGroupView: View, Themed {

    // MARK: - Constants

    private enum Constants {

        enum Sizing {
            static let avatarDimension: CGFloat = 24
            static let avatarOffset: CGFloat = 12
        }
        enum Spacing {
            static let elementsVertical: CGFloat = .zero
            static let footerSeenOffset: CGFloat = -10
        }
        enum Padding {
            static let containerHorizontal: CGFloat = 16
            static let headerBottom: CGFloat = 8
            static let footerTop: CGFloat = 4
        }
    }

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @SwiftUI.Environment(\.colorScheme) var scheme

    @Binding private var alertType: ChatAlertType?

    private let group: MessageGroup
    private let isLastMessage: Bool
    private let onRichMessageElementSelected: (RichMessageSubElementType) -> Void

    // MARK: - Init

    init(
        group: MessageGroup,
        isLast: Bool,
        alertType: Binding<ChatAlertType?>,
        onRichMessageElementSelected: @escaping (RichMessageSubElementType) -> Void
    ) {
        self.group = group
        self.isLastMessage = isLast
        self._alertType = alertType
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }

    // MARK: - Builder

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.elementsVertical) {
            if group.shouldShowHeader {
                header
            }

            ZStack {
                VStack(spacing: StyleGuide.Spacing.Message.groupCellSpacing) {
                    ForEach(group.messages) { message in
                        let groupPosition: MessageGroupPosition = group.position(of: message)

                        ChatMessageCell(
                            message: message,
                            messageGroupPosition: groupPosition,
                            isLast: .constant(isLastMessage && groupPosition.isLastInGroup),
                            alertType: $alertType,
                            onRichMessageElementTapped: onRichMessageElementSelected
                        )
                        .accessibilityIdentifier(A11y.Conversation.MessageCell.identifier)
                        .accessibilityValue(textForA11yValue(for: message))
                        .onChange(of: message.status) { status in
                            guard !message.isUserAgent else {
                                return
                            }

                            A11y.announce(status.accessibilityValue)
                        }
                    }
                }

                if group.shouldShowAvatar {
                    avatar
                }
            }

            if group.shouldShowFooter {
                footer
            }
        }
        .padding(.horizontal, Constants.Padding.containerHorizontal)
        .padding(.bottom, group.shouldShowFooter ? .zero : StyleGuide.Padding.Message.contentVertical)
    }
}

// MARK: - Subviews

extension MessageGroupView {

    var header: some View {
        Text(group.date.formatted(useRelativeFormat: true))
            .font(.caption.bold())
            .foregroundStyle(colors.content.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.bottom, Constants.Padding.headerBottom)
    }

    var footer: some View {
        HStack {
            Spacer()

            switch group.status {
            case .sent:
                Asset.Message.sent
                    .foregroundStyle(colors.brand.primary)
            case .delivered:
                Asset.Message.delivered
                    .foregroundStyle(colors.brand.primary)
            case .seen:
                ZStack {
                    Asset.Message.delivered
                        .background(
                            Circle()
                                .foregroundStyle(colors.background.default)
                        )
                        .foregroundStyle(colors.brand.primary)
                        .offset(x: Constants.Spacing.footerSeenOffset)
                    
                    Asset.Message.delivered
                        .background(
                            Circle()
                                .foregroundStyle(colors.background.default)
                        )
                        .foregroundStyle(colors.brand.primary)
                }
            case .failed:
                Asset.Message.failed
                    .foregroundStyle(colors.status.error)
            }
        }
        .padding(.top, Constants.Padding.footerTop)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.Status.identifier)
        .accessibilityValue(group.status.accessibilityValue)
        .accessibilityHidden(true)
    }

    var avatar: some View {
        VStack {
            Spacer()
                .frame(maxWidth: .infinity)

            HStack {
                AvatarView(imageUrl: group.sender?.avatarURL, initials: group.sender?.initials)
                    .frame(width: Constants.Sizing.avatarDimension, height: Constants.Sizing.avatarDimension)
                    .offset(x: -Constants.Sizing.avatarOffset, y: Constants.Sizing.avatarOffset)

                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Helpers

private extension MessageStatus {

    /// A localised string describing this delivery status, used as a VoiceOver announcement
    /// when the status changes and as the `accessibilityValue` of the message footer element.
    ///
    /// - `.sent` → `"Sent"`
    /// - `.delivered` → `"Delivered"`
    /// - `.seen` → `"Seen"`
    /// - `.failed` → `"Failed"`
    var accessibilityValue: String {
        switch self {
        case .sent:
            A11y.Announcement.Message.Status.sent
        case .delivered:
            A11y.Announcement.Message.Status.delivered
        case .seen:
            A11y.Announcement.Message.Status.seen
        case .failed:
            A11y.Announcement.Message.Status.failed
        }
    }
}

// MARK: - Private methods

private extension MessageGroupView {

    /// Builds the accessibility value string for a single message cell.
    ///
    /// The returned string combines sender, timestamp, and delivery status into one
    /// VoiceOver-readable phrase, for example:
    /// - `"Message from John Doe, Today at 3:45 PM, Delivered"`
    /// - `"Message from agent, Yesterday at 9:00 AM, Seen"`
    /// - `"Message from You, Today at 3:46 PM, Sent"`
    ///
    /// - Parameter message: The chat message whose metadata is used to construct the value.
    /// - Returns: A localised string suitable for `accessibilityValue`.
    func textForA11yValue(for message: ChatMessage) -> String {
        // Agent name is optional (bots/system messages may omit it), so fall back to the generic "agent" label.
        let sender = message.isUserAgent
            ? A11y.Conversation.MessageCell.AgentMessage.value(message.user?.userName ?? L10n.Common.agent)
            : A11y.Conversation.MessageCell.CustomerMessage.value

        // Relative format produces "Today at 3:45 PM" instead of a full date string, which sounds more natural when spoken by VoiceOver.
        let formattedTime = message.date.formatted(useRelativeFormat: true)
        let time = A11y.Conversation.MessageCell.Timestamp.label(formattedTime)

        let status = switch message.status {
        case .sent:
            A11y.Conversation.MessageCell.Status.Sent.label
        case .delivered:
            A11y.Conversation.MessageCell.Status.Delivered.label
        case .seen:
            A11y.Conversation.MessageCell.Status.Seen.label
        case .failed:
            A11y.Conversation.MessageCell.Status.Failed.label
        }

        // Commas produce a natural VoiceOver pause between sender, time, and status.
        return "\(sender), \(time), \(status)"
    }
}

#if DEBUG

// MARK: - Preview

#Preview {
    let chatMessages = [
            MockData.textMessage(user: MockData.customer, date: Date.now.adding(.day, value: -2)),
            MockData.textMessage(user: MockData.customer, date: Date.now.adding(.day, value: -1)),
            MockData.listPickerMessage(date: Date.now.adding(.minute, value: -1)),
            MockData.textMessage(user: MockData.customer, date: Date.now.adding(.day, value: -2)),
            MockData.textMessage(user: MockData.agent, date: Date.now.adding(.minute, value: -1)),
            MockData.quickRepliesMessage(date: Date.now.adding(.minute, value: -1)),
            MockData.textMessage(user: MockData.customer, date: Date.now.adding(.minute, value: -1)),
            MockData.textMessage(user: MockData.customer)
        ]

    VStack {
        ScrollView {
            VStack {
                ForEach(chatMessages.groupMessages(interval: 2.0)) { message in
                    MessageGroupView(group: message, isLast: true, alertType: .constant(nil)) { _ in }
                }
            }
        }

        MessageInputView(
            attachmentRestrictions: MockData.attachmentRestrictions,
            attachments: .constant([]),
            isEditing: .constant(false),
            isInputEnabled: .constant(true),
            isSendingMessage: .constant(false),
            alertType: .constant(nil),
            audioRecorder: .preview()
        ) { _, _ in }
    }
    .environmentObject(ChatStyle())
}

#endif
