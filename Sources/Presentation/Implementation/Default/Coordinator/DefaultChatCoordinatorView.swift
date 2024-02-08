//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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
import UIKit

struct DefaultChatCoordinatorView: View {

    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @ObservedObject var viewModel: DefaultChatCoordinatorViewModel
    
    var threadIdToOpen: UUID?
    
    // MARK: - Builder
    
    var body: some View {
        if viewModel.showThreadList {
            DefaultChatListView(viewModel: DefaultChatListViewModel(coordinator: viewModel.coordinator, threadIdToOpen: threadIdToOpen))
        } else if let thread = viewModel.chatThread {
            DefaultChatView(chatThread: thread, coordinator: viewModel.coordinator)
        } else {
            ZStack {
                style.backgroundColor
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: style.formTextColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear(perform: viewModel.onAppear)
        }
    }
}

// MARK: - Preview

struct DefaultChatCoordinatorView_Previews: PreviewProvider {
    
    @ObservedObject private static var viewModel = DefaultChatCoordinatorViewModel(
        coordinator: DefaultChatCoordinator(navigationController: UINavigationController())
    )
    
    static var previews: some View {
        DefaultChatCoordinatorView(viewModel: viewModel)
            .environmentObject(ChatStyle())
    }
}
