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

import SwiftUI

struct LivechatPositionInQueueView: View, Themed {
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var scheme
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @State private var isHeaderVisible = true
    
    let positionInQueue: Int

    private static let cornerRadius: CGFloat = 32
    private static let containerShadowRadius: CGFloat = 8
    private static let containerShadowPositionX: CGFloat = 0
    private static let containerShadowPositionY: CGFloat = 4
    private static let containerShadowColor = Color.black.opacity(0.25)
    
    // MARK: - Init
    
    init(position: Int) {
        self.positionInQueue = position
    }
    
    // MARK: - Builder
    
    var body: some View {
        ChatDefaultOverlayView(
            title: positionInQueue > 0 ? String(format: localization.liveChatQueueTitle, positionInQueue) : nil,
            subtitle: localization.liveChatQueueSubtitle,
            cardImage: Asset.LiveChat.personWithClock,
            isHeaderVisible: $isHeaderVisible
        )
        .cornerRadius(Self.cornerRadius)
        .shadow(
            color: Self.containerShadowColor,
            radius: Self.containerShadowRadius,
            x: Self.containerShadowPositionX,
            y: Self.containerShadowPositionY
        )
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification), perform: handleKeyboardVisibility)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification), perform: handleKeyboardVisibility)
    }
}

// MARK: - Helpers

private extension LivechatPositionInQueueView {
    
    func handleKeyboardVisibility(_ notification: Notification) {
        self.isHeaderVisible = notification.name != UIApplication.keyboardWillShowNotification
    }
}

// MARK: - Previews

#Preview {
    let localization = ChatLocalization()
    
    NavigationView {
        VStack {
            LivechatPositionInQueueView(position: 1)
                .padding(.top, 32)
                .padding(.horizontal, 16)
            
            Spacer()
            
            MessageInputView(
                attachmentRestrictions: MockData.attachmentResrictions,
                isEditing: .constant(false),
                alertType: .constant(nil),
                localization: localization
            ) { _, _ in
                // Do nothing
            }
        }
        .navigationTitle("No Agent")
    }
    .environmentObject(ChatStyle())
    .environmentObject(localization)
}
