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

import CXoneChatSDK
import SwiftUI

struct DefaultChatListView: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.willEnterForeground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewModel.didEnterBackgroundNotification()
        }
        .alert(isPresented: $viewModel.presentGenericError)
        .alert(isPresented: $viewModel.presentUnableToCreateThreadError, title: "Attention", message: "Unable to create new thread")
        .alert(isPresented: $viewModel.presentUnknownThreadFromDeeplinkError, message: "Received remote notification from unknown thread.")
        .alert(
            isPresented: $viewModel.presentDisconnectAlert,
            title: "Attention",
            message: "Do you want to disconnect from the CXone services?",
            primaryButton: .destructive(Text("Disconnect"), action: viewModel.onDisconnectTapped),
            secondaryButton: .cancel()
        )
        .onChange(of: viewModel.dismiss) { _ in
            presentationMode.wrappedValue.dismiss()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.presentDisconnectAlert = true
                } label: {
                    Asset.List.disconnect
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
        .navigationBarTitle("Threads")
    }
}

// MARK: - Subviews

private extension DefaultChatListView {
    
    @ViewBuilder
    var content: some View {
        Picker("", selection: $viewModel.threadsStatus.onChange(viewModel.updateThreadsStatus)) {
            ForEach(ThreadsStatusType.allCases, id: \.self) {
                Text($0.rawValue)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()

        if viewModel.chatThreads.isEmpty {
            Spacer()
            
            Text("No Threads")
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
            ForEach($viewModel.chatThreads, id: \.id) { chatThread in
                DefaultChatListCell(title: chatThread.wrappedValue.listName, message: chatThread.wrappedValue.messages.last?.message)
                    .if(viewModel.threadsStatus == .current) { view in
                        view.onTapGesture {
                            viewModel.onThreadTapped(chatThread.wrappedValue)
                        }
                    }
                    .listRowBackground(Color.clear)
            }
            .if(viewModel.threadsStatus == .current) { view in
                view.onDelete(perform: viewModel.onSwipeToDelete)
            }
        }
        .listStyle(.plain)
        .background(style.backgroundColor)
    }
    
    var lazyStackContent: some View {
        LazyVStack {
            ForEach($viewModel.chatThreads, id: \.id) { chatThread in
                let thread = chatThread.wrappedValue
                
                DefaultChatListCell(title: thread.listName, message: thread.messages.last?.message, showDeleteButton: viewModel.threadsStatus == .current) {
                    viewModel.onDelete(chatThread.wrappedValue)
                }
                .padding(.horizontal, 12)
                .if(viewModel.threadsStatus == .current) { view in
                    view.onTapGesture {
                        viewModel.onThreadTapped(chatThread.wrappedValue)
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .background(style.backgroundColor)
    }
}

// MARK: - Helpers

private extension ChatThread {
    
    var listName: String {
        name?.nilIfEmpty()
            ?? assignedAgent?.fullName
            ?? "No Agent"
    }
}

// MARK: - Previews

struct DefaultChatListView_Previews: PreviewProvider {

    static let viewModel = DefaultChatListViewModel(coordinator: DefaultChatCoordinator(navigationController: UINavigationController()))
    
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
    }
}
