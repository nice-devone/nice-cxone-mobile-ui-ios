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

struct OfflineView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    
    let disconnectAction: () -> Void

    // MARK: - Builder
    
    var body: some View {
        ChatDefaultOverlayView(
            title: localization.liveChatOfflineTitle,
            subtitle: localization.liveChatOfflineMessage,
            cardImage: Asset.LiveChat.offline
        ) { _ in
            Button(action: disconnectAction) {
                Text(localization.alertDisconnectConfirm)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.destructive)
        }
    }
}

// MARK: - Previews

#Preview("Offline") {
    ChatDefaultOverlayPreview {
        OfflineView {}
    }
}
