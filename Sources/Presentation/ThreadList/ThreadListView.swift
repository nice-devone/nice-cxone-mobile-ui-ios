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

struct ThreadListView: View, Themed {

    // MARK: - Constants

    private enum Constants {
        
        enum Padding {
            static let pickerHorizontal: CGFloat = 16
            static let pickerVertical: CGFloat = 12
        }

        enum Sizing {
            // Intentionally the same value as `StyleGuide.Sizing.overlayMaxWidth`; named
            // separately so the picker's width cap reads as its own intent at the call site.
            static let pickerMaxWidth: CGFloat = StyleGuide.Sizing.overlayMaxWidth
        }
    }

    // MARK: - Properties

    @SwiftUI.Environment(\.colorScheme) var scheme

    @EnvironmentObject var style: ChatStyle
    
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
        }
        .background(colors.background.default)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .chatNavigationTitle(L10n.ChatList.title)
        .chatToolbarBackground()
        // The navigationDestination allows programmatic navigation to the ThreadView to handle
        // the cases of direct to thread and thread creation.
        //
        // The `.id(currentThread?.id)` modifier forces SwiftUI to tear down and recreate the inner
        // view when the active thread changes (e.g. a local push for thread B arrives while the user
        // is on thread A). Without it, SwiftUI keeps the same `ThreadView` instance and only swaps
        // the injected view model — `onDisappear` for thread A and `onAppear` for thread B never
        // fire, so thread B's view model never registers its chat delegate or loads its initial state.
        .navigationDestination(isPresented: viewModel.threadDestination) {
            LazyView {
                viewModel.viewModel(for: viewModel.currentThread).map(ThreadView.init)
                    .environmentObject(style)
            }
            .id(viewModel.currentThread?.id)
        }
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
                    .accessibilityIdentifier(A11y.ThreadList.NavigationBar.ButtonNew.identifier)
                    .accessibilityLabel(A11y.ThreadList.NavigationBar.ButtonNew.label)
                    .accessibilityHint(A11y.ThreadList.NavigationBar.ButtonNew.hint)
                }
            }
        }
        .alert(L10n.Alert.UpdateThreadName.title, isPresented: $viewModel.isEditingThreadName) {
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
            ForEach(ThreadStatusType.allCases, id: \.self) { status in
                Text(pickerString(for: status))
                    .tag(status.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: Constants.Sizing.pickerMaxWidth)
        .padding(.vertical, Constants.Padding.pickerVertical)
        .padding(.horizontal, Constants.Padding.pickerHorizontal)
        .onChange(of: viewModel.threadStatus) { newValue in
            viewModel.updateThreadStatus(newValue)
        }
        
        if viewModel.chatThreads.isEmpty {
            Spacer()
            
            Text(L10n.ChatList.empty)
                .foregroundStyle(colors.content.tertiary)
                .accessibilityIdentifier(A11y.ThreadList.EmptyState.identifier)

            Spacer()
        } else {
            List(viewModel.chatThreads, id: \.id) { chatThread in
                listCell(chatThread: chatThread)
            }
            .listStyle(.plain)
            .background(colors.background.default)
        }
    }

    func listCell(chatThread: ChatThread) -> some View {
        let title = chatThread.titleForConversation
        let latestMessage = chatThread.latestMessage
        let timestamp = latestMessage?.createdAt ?? Date.now
        let formattedTimestamp = dateFormatter.string(from: timestamp)
        let messagePreview = latestMessage?.getLocalizedContentOrFallbackText(useFallback: true)
        let isRead = isRead(chatThread)
        let hasPendingSatisfactionSurvey = viewModel.threadIdsWithPendingSurvey.contains(chatThread.id)
        let showsUnreadIndicator = ThreadListCell.showsUnreadIndicator(
            isRead: isRead, statusType: viewModel.threadStatus, hasPendingSatisfactionSurvey: hasPendingSatisfactionSurvey
        )

        return Button {
            viewModel.show(thread: chatThread)
        } label: {
            ThreadListCell(
                assignedAgent: ChatUserMapper.map(from: chatThread.assignedAgent),
                title: title,
                message: messagePreview,
                timestamp: formattedTimestamp,
                statusType: viewModel.threadStatus,
                isRead: isRead,
                hasPendingSatisfactionSurvey: hasPendingSatisfactionSurvey
            )
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(colors.background.default)
        .if(viewModel.threadStatus == .current) { view in
            view.cellActions(
                colors: colors,
                onRename: {
                    viewModel.onEditThreadName(for: chatThread)
                },
                onArchive: {
                    Task { @MainActor in
                        await viewModel.onArchive(chatThread)
                    }
                }
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.ThreadList.Cell.identifier(chatThread.id))
        .accessibilityLabel(
            messagePreview?.isEmpty == false
                ? A11y.ThreadList.Cell.label(title, messagePreview ?? "", formattedTimestamp)
                : A11y.ThreadList.Cell.Label.noMessage(title, formattedTimestamp)
        )
        // The row ignores its children, so the unread indicator's own label never reaches VoiceOver
        .accessibilityValue(showsUnreadIndicator ? A11y.ThreadList.Cell.UnreadIndicator.label : "")
        .accessibilityHint(A11y.ThreadList.Cell.hint)
    }
}

// MARK: - Helpers

private extension ThreadListView {
    
    func isRead(_ chatThread: CXoneChatUI.ChatThread) -> Bool {
        // Read status is valid only for messages from an agent to a client
        chatThread.latestMessage?.direction == .toClient
            ? chatThread.latestMessage?.isSeenByCustomer == true
            : true
    }

    func pickerString(for status: ThreadStatusType) -> String {
        switch status {
        case .current:
            return L10n.ChatList.ThreadStatus.current
        case .archived:
            return L10n.ChatList.ThreadStatus.archived
        }
    }
}

private extension View {

    func cellActions(colors: StyleColors, onRename: @escaping () -> Void, onArchive: @escaping () -> Void) -> some View {
        self
            .contextMenu {
                Button(action: onRename) {
                    Label {
                        Text(L10n.ChatThread.ContextMenu.rename)
                    } icon: {
                        Asset.ChatThread.gear
                            .accessibilityHidden(true)
                    }
                }

                Button(role: .destructive, action: onArchive) {
                    Label {
                        Text(L10n.ChatThread.ContextMenu.archive)
                    } icon: {
                        Asset.Message.archive
                            .accessibilityHidden(true)
                    }
                    .tint(colors.status.error)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive, action: onArchive) {
                    ResizedSymbol(
                        image: Asset.List.archive,
                        targetSize: StyleGuide.Sizing.Button.smallDimension
                    )
                }
                .foregroundStyle(colors.status.onWarning)
                .tint(colors.status.warning)
                .accessibilityIdentifier(A11y.ThreadList.Cell.ButtonArchive.identifier)
                .accessibilityLabel(A11y.ThreadList.Cell.ButtonArchive.label)
                .accessibilityHint(A11y.ThreadList.Cell.ButtonArchive.hint)

                Button(action: onRename) {
                    ResizedSymbol(
                        image: Asset.List.rename,
                        targetSize: StyleGuide.Sizing.Button.smallDimension
                    )
                }
                .foregroundStyle(colors.status.onSuccess)
                .tint(colors.status.success)
                .accessibilityIdentifier(A11y.ThreadList.Cell.ButtonRename.identifier)
                .accessibilityLabel(A11y.ThreadList.Cell.ButtonRename.label)
                .accessibilityHint(A11y.ThreadList.Cell.ButtonRename.hint)
            }
    }
}

// MARK: - Previews

#Preview("ThreadListView") {
    ChatContainerView(
        viewModel: ChatContainerViewModel(
            chatProvider: MockChatProvider(state: .prepared, mode: .multithread),
            chatConfiguration: ChatConfiguration(),
            presentModally: true
        )
    )
    .environmentObject(ChatStyle())
}
