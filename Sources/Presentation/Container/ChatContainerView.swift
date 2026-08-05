//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatSDK
import SwiftUI
import UIKit

struct ChatContainerView: View, Themed {

    // MARK: - Properties

    @ObservedObject var viewModel: ChatContainerViewModel
    
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @StateObject private var overlayManager = OverlayManager()
    
    // MARK: - Init

    init(viewModel: ChatContainerViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack {
            contentWrapper
                .alertable(isPresented: viewModel.showAlert, presenting: viewModel.alertType)
                .sheet(isPresented: viewModel.isSheetDisplayed) {
                    viewModel.sheet?()
                }
        }
        .sheet(item: $viewModel.safariURL) { item in
            SafariView(url: item.url)
        }
        .environment(\.openURL, OpenURLAction { url in
            if url.scheme?.contains("http") == true {
                viewModel.safariURL = IdentifiableURL(url: url)
                return .handled
            } else {
                return .systemAction
            }
        })
        .tint(colors.brand.primary)
        .background(colors.background.default)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear {
            overlayManager.hide()
            
            viewModel.onDisappear()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification),
            perform: viewModel.willEnterForeground
        )
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification),
            perform: viewModel.didEnterBackground
        )
        .onChange(of: viewModel.isOverlayDisplayed.wrappedValue) { _ in
            if let overlay = viewModel.overlay {
                viewModel.safariURL = nil

                self.overlayManager.show {
                    overlay()
                        .environmentObject(style)
                }
            } else {
                overlayManager.hide()
            }
        }
    }
}

// MARK: - Subviews

private extension ChatContainerView {
    
    @ViewBuilder
    var contentWrapper: some View {
        if viewModel.presentModally {
            NavigationStack {
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
                            .accessibilityIdentifier(A11y.ChatContainer.NavigationBar.ButtonClose.identifier)
                            .accessibilityLabel(A11y.ChatContainer.NavigationBar.ButtonClose.label)
                            .accessibilityHint(A11y.ChatContainer.NavigationBar.ButtonClose.hint)
                        }
                    }
            }
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
