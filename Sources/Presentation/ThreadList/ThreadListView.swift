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

struct ThreadListView: View, Themed {

    // MARK: - Constants

    private enum Constants {
        
        enum Padding {
            static let pickerHorizontal: CGFloat = 16
            static let pickerVertical: CGFloat = 12
        }
    }

    // MARK: - Properties

    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @ObservedObject private var viewModel: ThreadListViewModel

    private let dateFormatter = AdaptiveDateFormatter()
    
    // MARK: - Init
    
    init(viewModel: ThreadListViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Content

    var body: some View {
        VStack {
            content

            // This NavigationLink allows programmatic navigation to the ThreadView to handle
            // the cases of direct to thread and thread creation.
            NavigationLink(
                destination: LazyView {
                    viewModel.viewModel(for: viewModel.threadToShow).map(ThreadView.init)
                        .environmentObject(localization)
                        .environmentObject(style)
                },
                isActive: viewModel.showThread
            ) { EmptyView() }
            
            NavigationLink(
                destination: LazyView {
                    viewModel.viewModel(for: viewModel.hiddenThreadToShow).map(ThreadView.init)
                        .environmentObject(localization)
                        .environmentObject(style)
                },
                isActive: viewModel.showHiddenThread
            ) { EmptyView() }
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .navigationTitle(localization.chatListTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.threadStatus == .current && viewModel.chatProvider.state.isChatAvailable {
                    Button {
                        Task { @MainActor in
                            await viewModel.onCreateNewThread()
                        }
                    } label: {
                        Asset.List.new
                    }
                }
            }
        }
        .background(colors.background.default)
        .alert(localization.alertUpdateThreadNameTitle, isPresented: $viewModel.isEditingThreadName) {
            AlertTextFieldView(isPresented: $viewModel.isEditingThreadName) { name in
                Task { @MainActor in
                    await viewModel.setThreadName(name)
                }
                
            }
        }
    }
}

// MARK: - Subviews

private extension ThreadListView {
    
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
        .padding(.vertical, Constants.Padding.pickerVertical)
        .padding(.horizontal, Constants.Padding.pickerHorizontal)
        
        if viewModel.chatThreads.isEmpty {
            Spacer()
            
            Text(localization.chatListEmpty)
                .foregroundColor(colors.content.tertiary)

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
            ForEach(viewModel.chatThreads, id: \.id) { chatThread in
                let title = chatThread.name?.nilIfEmpty()
                    ?? chatThread.assignedAgent?.fullName
                    ?? localization.commonUnassignedAgent
                let timestamp = chatThread.messages.last?.createdAt ?? Date.now
                
                ThreadListCell(
                    assignedAgent: ChatUserMapper.map(from: chatThread.assignedAgent),
                    title: title,
                    message: chatThread.messages.last?.getLocalizedContentOrFallbackText(basedOn: localization, useFallback: true),
                    timestamp: dateFormatter.string(from: timestamp),
                    statusType: viewModel.threadStatus,
                    // Read status is valid only for messages from an agent to a client
                    isRead: chatThread.messages.last?.direction == .toClient ? chatThread.messages.last?.customerStatistics?.seenAt != nil : true,
                    onRename: {
                        viewModel.onEditThreadName(for: chatThread)
                    },
                    onArchive: {
                        Task { @MainActor in
                            await viewModel.onArchive(chatThread)
                        }
                    }
                )
                .listRowBackground(colors.background.default)
                .onTapGesture {
                    // Note that we *could* use a NavigationLink here instead, but then
                    // we would be duplicating much of the code for the NavigationLink
                    // on or around line 43.
                    viewModel.show(thread: chatThread)
                }
            }
            .if(viewModel.threadStatus == .current) { view in
                view.onDelete(perform: viewModel.onSwipeToArchive)
            }
        }
        .listStyle(.plain)
        .background(colors.background.default)
    }
    
    var lazyStackContent: some View {
        LazyVStack {
            ForEach(viewModel.chatThreads) { chatThread in
                let title = chatThread.name?.nilIfEmpty()
                    ?? chatThread.assignedAgent?.fullName
                    ?? localization.commonUnassignedAgent
                let timestamp = chatThread.messages.last?.createdAt ?? Date.now
                
                ThreadListCell(
                    assignedAgent: ChatUserMapper.map(from: chatThread.assignedAgent),
                    title: title,
                    message: chatThread.messages.last?.getLocalizedContentOrFallbackText(basedOn: localization, useFallback: true),
                    timestamp: dateFormatter.string(from: timestamp),
                    statusType: viewModel.threadStatus,
                    // Read status is valid only for messages from an agent to a client
                    isRead: chatThread.messages.last?.direction == .toClient ? chatThread.messages.last?.customerStatistics?.seenAt != nil : true,
                    onRename: {
                        viewModel.onEditThreadName(for: chatThread)
                    },
                    onArchive: {
                        Task { @MainActor in
                            await viewModel.onArchive(chatThread)
                        }
                    }
                )
                .listRowBackground(colors.background.default)
                .onTapGesture {
                    viewModel.show(thread: chatThread)
                }
            }
        }
        .listStyle(.plain)
        .background(colors.background.default)
    }
}

// MARK: - Previews

#Preview("ThreadListView") {
    NavigationView {
        ThreadListView(
            viewModel: ThreadListViewModel(
                containerViewModel: ChatContainerViewModel(
                    chatProvider: CXoneChat.shared,
                    chatLocalization: ChatLocalization(),
                    chatStyle: ChatStyle(),
                    chatConfiguration: ChatConfiguration(),
                    presentModally: true
                ) {}
            )
        )
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
