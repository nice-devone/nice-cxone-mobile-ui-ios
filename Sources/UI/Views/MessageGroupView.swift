//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

struct MessageGroupView: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    
    @Binding private var isProcessDialogVisible: Bool
    @Binding private var alertType: ChatAlertType?

    var group: MessageGroup

    let onRichMessageElementSelected: (_ textToSend: String?, RichMessageSubElementType) -> Void
    
    // MARK: - Init
    
    init(
        group: MessageGroup,
        isProcessDialogVisible: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        onRichMessageElementSelected: @escaping (_: String?, RichMessageSubElementType) -> Void
    ) {
        self.group = group
        self._isProcessDialogVisible = isProcessDialogVisible
        self._alertType = alertType
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }

    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if group.shouldShowHeader {
                header
            }
            
            ZStack {
                VStack(spacing: 2) {
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
        .padding(.leading, 16)
        .padding(.trailing, 10)
        .padding(.bottom, group.shouldShowFooter ? 0 : StyleGuide.Message.paddingVertical)
    }
}

// MARK: - Subviews

extension MessageGroupView {

    var header: some View {
        Text(group.date.formatted(useRelativeFormat: true))
            .font(.footnote.bold())
            .foregroundColor(style.formTextColor.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)
    }

    var footer: some View {
        HStack {
            Spacer()

            switch group.status {
            case .sent:
                Asset.Message.sent
                    .foregroundColor(style.customerCellColor)
            case .delivered:
                Asset.Message.delivered
                    .foregroundColor(style.customerCellColor)
            case .seen:
                ZStack {
                    Asset.Message.delivered
                        .background(
                            Circle()
                                .foregroundColor(style.backgroundColor)
                        )
                        .foregroundColor(style.customerCellColor)
                        .offset(x: -10)
                    
                    Asset.Message.delivered
                        .background(
                            Circle()
                                .foregroundColor(style.backgroundColor)
                        )
                        .foregroundColor(style.customerCellColor)
                }
            }
        }
        .padding(.top, 2)
    }

    var avatar: some View {
        VStack {
            Spacer()
                .frame(maxWidth: .infinity)
        
            HStack {
                MessageAvatarView(
                    avatarUrl: group.sender.avatarURL,
                    initials: group.sender.initials
                )
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(style.backgroundColor, lineWidth: 2)
                    )
                    .offset(x: -12, y: 12)

                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview

struct MessageGroupView_Previews: PreviewProvider {
    
    static let manager = ChatManager(
        messages: [
            MockData.textMessage(user: MockData.customer, date: Date.now.adding(.day, value: -2)),
            MockData.textMessage(user: MockData.customer, date: Date.now.adding(.day, value: -1)),
            MockData.textMessage(user: MockData.customer, date: Date.now.adding(.day, value: -1)),
            MockData.textMessage(user: MockData.agent, date: Date.now.adding(.minute, value: -2)),
            MockData.textMessage(user: MockData.customer, date: Date.now.adding(.minute, value: -1)),
            MockData.textMessage(user: MockData.customer)
        ]
    )
    
    static var previews: some View {
        ScrollView {
            VStack {
                ForEach(manager.groupMessages()) { message in
                    MessageGroupView(group: message, isProcessDialogVisible: .constant(false), alertType: .constant(nil)) { _, _ in }
                }
            }
        }
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
    }
}
