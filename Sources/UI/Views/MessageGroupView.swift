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
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @Binding private var isProcessDialogVisible: Bool
    @Binding private var alertType: ChatAlertType?

    let group: MessageGroup
    let onRichMessageElementSelected: (_ textToSend: String?, RichMessageSubElementType) -> Void
    
    private static let containerHorizontalPadding: CGFloat = 16
    private static let headerPaddingBottom: CGFloat = 8
    private static let footerTopPadding: CGFloat = 2
    private static let avatarDimension: CGFloat = 24
    private static let avatarOffset: CGFloat = 12
    
    // MARK: - Init
    
    init(
        group: MessageGroup,
        isProcessDialogVisible: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        onRichMessageElementSelected: @escaping (_ textToSend: String?, RichMessageSubElementType) -> Void
    ) {
        self.group = group
        self._isProcessDialogVisible = isProcessDialogVisible
        self._alertType = alertType
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }

    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if group.shouldShowHeader {
                header
            }
            
            ZStack {
                VStack(spacing: StyleGuide.Message.groupCellSpacing) {
                    ForEach(group.messages) { message in
                        ChatMessageCell(
                            message: message,
                            messageGroupPosition: group.position(of: message),
                            isProcessDialogVisible: $isProcessDialogVisible,
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
        .padding(.horizontal, Self.containerHorizontalPadding)
        .padding(.bottom, group.shouldShowFooter ? .zero : StyleGuide.Message.paddingVertical)
    }
}

// MARK: - Subviews

extension MessageGroupView {

    var header: some View {
        Text(group.date.formatted(useRelativeFormat: true))
            .font(.caption.bold())
            .foregroundColor(colors.customizable.onBackground.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.bottom, Self.headerPaddingBottom)
    }

    var footer: some View {
        HStack {
            Spacer()

            switch group.status {
            case .sent:
                Asset.Message.sent
                    .foregroundColor(colors.customizable.onBackground.opacity(0.5))
            case .delivered:
                Asset.Message.delivered
                    .foregroundColor(colors.customizable.customerBackground)
            case .seen:
                ZStack {
                    Asset.Message.delivered
                        .background(
                            Circle()
                                .foregroundColor(colors.customizable.background)
                        )
                        .foregroundColor(colors.customizable.customerBackground)
                        .offset(x: -10)
                    
                    Asset.Message.delivered
                        .background(
                            Circle()
                                .foregroundColor(colors.customizable.background)
                        )
                        .foregroundColor(colors.customizable.customerBackground)
                }
            case .failed:
                Asset.Message.failed
                    .foregroundColor(colors.foreground.error)
            }
        }
        .padding(.top, Self.footerTopPadding)
    }

    var avatar: some View {
        VStack {
            Spacer()
                .frame(maxWidth: .infinity)
        
            HStack {
                AvatarView(imageUrl: group.sender?.avatarURL, initials: group.sender?.initials)
                    .frame(width: Self.avatarDimension, height: Self.avatarDimension)
                    .offset(x: -Self.avatarOffset, y: Self.avatarOffset)

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
                    MessageGroupView(group: message, isProcessDialogVisible: .constant(false), alertType: .constant(nil)) { _, _ in }
                }
            }
        }
        
        MessageInputView(
            attachmentRestrictions: MockData.attachmentResrictions,
            isEditing: .constant(false),
            isInputEnabled: .constant(true),
            alertType: .constant(nil),
            localization: localization
        ) { _, _ in }
    }
    .environmentObject(localization)
    .environmentObject(ChatStyle())
}
