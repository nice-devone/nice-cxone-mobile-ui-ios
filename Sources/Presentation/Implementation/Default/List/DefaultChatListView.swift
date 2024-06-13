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

struct DefaultChatListView: View, Alertable {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    
    @EnvironmentObject var localization: ChatLocalization

    @SwiftUI.Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject private var viewModel: DefaultChatListViewModel

    // MARK: - Init
    
    init(viewModel: DefaultChatListViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Content

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: style.formTextColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                content
            }
        }
        .background(style.backgroundColor)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: viewModel.willEnterForeground)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: viewModel.didEnterBackground)
        .alert(item: $viewModel.alertType, content: alertContent)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.alertType = .disconnect(localization: localization, primaryAction: viewModel.onDisconnectTapped)
                } label: {
                    Asset.disconnect
                }
                .foregroundColor(style.navigationBarElementsColor)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.onCreateNewThread) {
                    Asset.List.new
                }
                .foregroundColor(style.navigationBarElementsColor)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitle(localization.chatListTitle)
    }
}

// MARK: - Subviews

private extension DefaultChatListView {
    
    @ViewBuilder
    var content: some View {
        Picker("", selection: $viewModel.threadStatus) {
            ForEach(ThreadStatusType.allCases, id: \.self) {
                Text(localization.string(for: $0)).tag($0.rawValue)
            }
        }
        .onChange(of: viewModel.threadStatus) { newValue in
            viewModel.updateThreadStatus(newValue)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()

        if viewModel.chatThreads.isEmpty {
            Spacer()
            
            Text(localization.chatListEmpty)
                .foregroundColor(style.formTextColor)
            
            Spacer()
        } else {
            if #available(iOS 16.0, *) {
                listContent
            } else {
                lazyStackContent
                
                Spacer()
            }
        }
    }
    
    var listContent: some View {
        List {
            ForEach($viewModel.chatThreads) { chatThread in
                DefaultChatListCell(
                    title: listName(thread: chatThread.wrappedValue),
                    message: chatThread.wrappedValue.messages.last?.getLocalizedContentOrFallbackText(basedOn: localization, useFallback: true)
                )
                .listRowBackground(Color.clear)
                .onTapGesture {
                    viewModel.onThreadTapped(chatThread.wrappedValue)
                }
            }
            .if(viewModel.threadStatus == .current) { view in
                view.onDelete(perform: viewModel.onSwipeToDelete)
            }
        }
        .listStyle(.plain)
        .background(style.backgroundColor)
    }
    
    var lazyStackContent: some View {
        LazyVStack {
            ForEach($viewModel.chatThreads) { chatThread in
                DefaultChatListCell(
                    title: listName(thread: chatThread.wrappedValue),
                    message: chatThread.wrappedValue.messages.last?.getLocalizedContentOrFallbackText(basedOn: localization, useFallback: true),
                    showDeleteButton: viewModel.threadStatus == .current
                ) {
                    viewModel.onDelete(chatThread.wrappedValue)
                }
                .padding(.horizontal, 12)
                .listRowBackground(Color.clear)
                .onTapGesture {
                    viewModel.onThreadTapped(chatThread.wrappedValue)
                }
            }
            .listStyle(.plain)
            .background(style.backgroundColor)
        }
        .background(style.backgroundColor)
    }
}

// MARK: - Helpers

private extension DefaultChatListView {

    func listName(thread: ChatThread) -> String {
        thread.name?.nilIfEmpty()
            ?? thread.assignedAgent?.fullName
            ?? localization.commonUnassignedAgent
    }
}

// MARK: - Previews

struct DefaultChatListView_Previews: PreviewProvider {

    static let viewModel = DefaultChatListViewModel(
        coordinator: DefaultChatCoordinator(navigationController: UINavigationController()), 
        localization: ChatLocalization()
    )
    
    static var previews: some View {
        Group {
            NavigationView {
                DefaultChatListView(viewModel: viewModel)
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                DefaultChatListView(viewModel: viewModel)
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
