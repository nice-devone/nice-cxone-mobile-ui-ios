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
import SwiftUI

struct ImageMessageCell: View, Themed {

    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @StateObject private var viewModel: ImageMessageCellViewModel

    @Binding var alertType: ChatAlertType?
    
    private let isMultiAttachment: Bool
    private let message: ChatMessage
    private let position: MessageGroupPosition
    
    // MARK: - Init
    
    init(
        message: ChatMessage,
        item: AttachmentItem,
        isMultiAttachment: Bool,
        position: MessageGroupPosition,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        self.message = message
        self.isMultiAttachment = isMultiAttachment
        self.position = position
        self._alertType = alertType
        
        _viewModel = StateObject(wrappedValue: ImageMessageCellViewModel(
            item: item,
            alertType: alertType,
            localization: localization
        ))
    }
    
    // MARK: - Builder
    
    var body: some View {
        LoadingImageMessageCell(item: viewModel.item, isMultiAttachment: isMultiAttachment, alertType: $alertType, localization: localization)
            .if(!isMultiAttachment) { view in
                view
                    .messageChatStyle(message, position: position)
                    .shareable(message, attachments: [viewModel.item], spacerLength: 0)
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 4) {
        ImageMessageCell(
            message: MockData.imageMessageWithText(user: MockData.agent),
            item: MockData.imageItem,
            isMultiAttachment: true,
            position: .single,
            alertType: .constant(nil),
            localization: ChatLocalization()
        )
        
        ImageMessageCell(
            message: MockData.imageMessage(user: MockData.customer),
            item: MockData.imageItem,
            isMultiAttachment: true,
            position: .single,
            alertType: .constant(nil),
            localization: ChatLocalization()
        )
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
