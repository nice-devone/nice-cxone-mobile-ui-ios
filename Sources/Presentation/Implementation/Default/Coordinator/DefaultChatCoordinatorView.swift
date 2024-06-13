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

import SwiftUI
import UIKit

struct DefaultChatCoordinatorView: View {

    // MARK: - Properties
    
    @SwiftUI.Environment(\.presentationMode) private var presentationMode
    
    private var localization: ChatLocalization
    
    @EnvironmentObject private var style: ChatStyle
    
    @ObservedObject var viewModel: DefaultChatCoordinatorViewModel
    
    var threadIdToOpen: UUID?
    
    // MARK: - Builder
    
    init(viewModel: DefaultChatCoordinatorViewModel,
         threadIdToOpen: UUID? = nil,
         localization: ChatLocalization
    ) {
        self.viewModel = viewModel
        self.threadIdToOpen = threadIdToOpen
        self.localization = localization
    }
    
    var body: some View {
        content
    }
}

// MARK: - Subviews

private extension DefaultChatCoordinatorView {

    @ViewBuilder
    var content: some View {
        if viewModel.showOfflineLiveChat {
            OfflineView(onCloseTapped: viewModel.onBackButtonTapped)
        } else if viewModel.showThreadList, let chatListVM = viewModel.chatListViewModel {
            DefaultChatListView(viewModel: chatListVM)
        } else if viewModel.chatViewModel?.thread != nil, let chatVM = viewModel.chatViewModel {
            DefaultChatView(viewModel: chatVM)
        } else {
            ZStack {
                style.backgroundColor
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: style.formTextColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear(perform: viewModel.onAppear)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: viewModel.onBackButtonTapped) {
                        Text(localization.commonClose)
                    }
                    .foregroundColor(style.navigationBarElementsColor)
                }
            }
        }
    }
}

// MARK: - Preview

struct DefaultChatCoordinatorView_Previews: PreviewProvider {
    
    @ObservedObject private static var viewModel = DefaultChatCoordinatorViewModel(
        coordinator: DefaultChatCoordinator(navigationController: UINavigationController())
    )
    
    static var previews: some View {
        DefaultChatCoordinatorView(viewModel: viewModel, localization: ChatLocalization())
            .environmentObject(ChatStyle())
            .environmentObject(ChatLocalization())
    }
}
