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
                    NavigationStack {
                        viewModel.sheet?()
                    }
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
        // Publishes the container's geometry to every `LayoutAware` view below, so a rotation or a
        // window resize invalidates the ones whose layout depends on the orientation.
        .measuringChatLayout()
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
            // The satisfaction survey presents itself via the `.sheet` below instead - per Figma,
            // it is a large system sheet, not a dimmed floating card like the loading/offline/
            // inactivity overlays this floating window is for. Only the show branch is skipped for
            // the survey: a `nil` overlay must still take down whatever floating window was up before it.
            if let overlay = viewModel.overlay, !viewModel.isSatisfactionSurveyActive {
                viewModel.safariURL = nil

                self.overlayManager.show {
                    overlay()
                        .environmentObject(style)
                }
            } else {
                overlayManager.hide()
            }
        }
        .sheet(isPresented: Binding(
            // Held back while a form sheet is up or still dismissing: UIKit presents one sheet per presenter,
            // and closing it from outside would leave its awaiting caller (pre-chat / transcript) hanging.
            get: {
                // Gated on the survey's own view being in the slot, not just on the flag - while the survey waits
                // for a previous overlay to hide, the slot can briefly hold something else (e.g. a loading overlay)
                viewModel.isSatisfactionSurveyActive
                    && viewModel.isSatisfactionSurveyOverlayInstalled
                    && viewModel.overlay != nil
                    && viewModel.sheet == nil
                    && !viewModel.isSheetDismissing
            },
            set: { isPresented in
                guard !isPresented else {
                    return
                }

                Task { @MainActor in
                    await viewModel.dismissSatisfactionSurvey()
                }
            }
        )) {
            viewModel.overlay?()
                .environmentObject(style)
                // The sheet is a separate presentation host - measure it so `LayoutAware` content follows rotation
                .measuringChatLayout()
                // Only the explicit Cancel closes the survey - the SDK never re-emits it, so an accidental swipe would lose it
                .interactiveDismissDisabled()
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
