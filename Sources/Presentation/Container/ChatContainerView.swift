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
import UIKit

struct ChatContainerView: View {

    // MARK: - Properties
    
    @SwiftUI.Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var viewModel: ChatContainerViewModel

    // MARK: - Init

    init(viewModel: ChatContainerViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Builder
    
    var body: some View {
        NavigationFrame(current: viewModel.currentChild)
            .onAppear(perform: viewModel.onAppear)
            .onDisappear(perform: viewModel.onDisappear)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: viewModel.willEnterForeground)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: viewModel.didEnterBackground)
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    let localization = ChatLocalization()
    
    return ChatContainerView(
        viewModel: ChatContainerViewModel(
            chatProvider: CXoneChat.shared,
            chatLocalization: localization
        ) {}
    )
    .environmentObject(ChatStyle())
    .environmentObject(localization)
}

#Preview("Dark Mode") {
    let localization = ChatLocalization()
    
    return ChatContainerView(
        viewModel: ChatContainerViewModel(
            chatProvider: CXoneChat.shared,
            chatLocalization: localization
        ) {}
    )
    .environmentObject(ChatStyle())
    .environmentObject(localization)
    .preferredColorScheme(.dark)
}
