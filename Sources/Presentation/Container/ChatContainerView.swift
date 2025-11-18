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
import UIKit

struct ChatContainerView: View, Themed, Alertable {

    // MARK: - Properties

    @ObservedObject var viewModel: ChatContainerViewModel
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    // MARK: - Init

    init(viewModel: ChatContainerViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack {
            contentWrapper
                .alert(item: $viewModel.alertType, content: alertContent)
                .sheet(isPresented: viewModel.isSheetDisplayed) {
                    viewModel.sheet?()
                }
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification),
            perform: viewModel.willEnterForeground
        )
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification),
            perform: viewModel.didEnterBackground
        )
        .fullScreenCover(isPresented: viewModel.isOverlayDisplayed) {
            viewModel.overlay?()
                .presentationWithBackgroundColor(viewModel.chatProvider.state == .offline ? colors.background.default : .clear)
        }
        .tint(colors.brand.primary)
        .background(colors.background.default)
    }
}

// MARK: - Subviews

private extension ChatContainerView {
    
    @ViewBuilder
    var contentWrapper: some View {
        if viewModel.presentModally {
            NavigationView {
                content
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                Task { @MainActor in
                                    await viewModel.disconnect()
                                }
                            } label: {
                                Asset.down
                                    .foregroundStyle(colors.brand.primary)
                            }
                        }
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            content
        }
    }
    
    var content: some View {
         switch viewModel.chatProvider.mode {
         case .multithread:
             return AnyView(
                 ThreadListView(viewModel: viewModel.threadListViewModel())
             )
         case .singlethread, .liveChat:
             return AnyView(
                 ThreadView(viewModel: viewModel.viewModel(for: nil))
             )
         }
     }
}
