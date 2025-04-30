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

struct EndConversationView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    
    let onStartNewTapped: () -> Void
    let onBackToConversationTapped: () -> Void
    let onCloseChatTapped: () -> Void
    let thread: ChatThread
    
    // MARK: - Builder
    
    var body: some View {
        ChatDefaultOverlayView(
            title: thread.assignedAgent?.fullName ?? thread.lastAssignedAgent?.fullName != nil
                ? self.localization.liveChatEndConversationAssignedAgent
                : self.localization.liveChatEndConversationDefaultTitle,
            subtitle: thread.assignedAgent?.fullName
                ?? thread.lastAssignedAgent?.fullName
                ?? nil,
            cardImage: Asset.LiveChat.personWithClock) { _ in
                VStack {
                    Button(action: self.onStartNewTapped) {
                        Text(self.localization.liveChatEndConversationNew)
                    }
                    .buttonStyle(.primary)
                    
                    Button(action: self.onBackToConversationTapped) {
                        Text(self.localization.liveChatEndConversationBack)
                    }
                    .buttonStyle(.primary)
                    
                    Button(action: self.onCloseChatTapped) {
                        Text(self.localization.liveChatEndConversationClose)
                    }
                    .buttonStyle(.destructive)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
    }
}
