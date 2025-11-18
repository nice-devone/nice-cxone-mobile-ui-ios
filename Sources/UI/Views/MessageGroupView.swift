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
        
        enum Colors {
            static let dateOpacity: Double = 0.5
            static let footerSentOpacity: Double = 0.5
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @Binding private var alertType: ChatAlertType?
    
    private let group: MessageGroup
    private let isLastMessage: Bool
    private let onRichMessageElementSelected: (_ textToSend: String?, RichMessageSubElementType) -> Void
    
    // MARK: - Init
    
    init(
        group: MessageGroup,
        isLast: Bool,
        alertType: Binding<ChatAlertType?>,
        onRichMessageElementSelected: @escaping (_ textToSend: String?, RichMessageSubElementType) -> Void
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
                        let isLastInGroup: Bool = [.single, .last].contains(groupPosition)
                        
                        ChatMessageCell(
                            message: message,
                            messageGroupPosition: groupPosition,
                            isLast: .constant(isLastMessage && isLastInGroup),
                            alertType: $alertType,
                            onRichMessageElementTapped: onRichMessageElementSelected
                        )
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
            .foregroundColor(colors.content.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.bottom, Constants.Padding.headerBottom)
    }

    var footer: some View {
        HStack {
            Spacer()

            switch group.status {
            case .sent:
                Asset.Message.sent
                    .foregroundColor(colors.brand.primary)
            case .delivered:
                Asset.Message.delivered
                    .foregroundColor(colors.brand.primary)
            case .seen:
                ZStack {
                    Asset.Message.delivered
                        .background(
                            Circle()
                                .foregroundColor(colors.background.default)
                        )
                        .foregroundColor(colors.brand.primary)
                        .offset(x: Constants.Spacing.footerSeenOffset)
                    
                    Asset.Message.delivered
                        .background(
                            Circle()
                                .foregroundColor(colors.background.default)
                        )
                        .foregroundColor(colors.brand.primary)
                }
            case .failed:
                Asset.Message.failed
                    .foregroundColor(colors.status.error)
            }
        }
        .padding(.top, Constants.Padding.footerTop)
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

// MARK: - Preview

#Preview {
    let localization = ChatLocalization()
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
                    MessageGroupView(group: message, isLast: true, alertType: .constant(nil)) { _, _ in }
                }
            }
        }
        
        MessageInputView(
            attachmentRestrictions: MockData.attachmentRestrictions,
            isEditing: .constant(false),
            isInputEnabled: .constant(true),
            alertType: .constant(nil),
            localization: localization
        ) { _, _ in }
    }
    .environmentObject(localization)
    .environmentObject(ChatStyle())
}
