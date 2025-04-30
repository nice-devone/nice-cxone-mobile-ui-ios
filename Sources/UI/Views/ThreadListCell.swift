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

struct ThreadListCell: View, Themed {
    
    // MARK: - Constants
    
    enum Constants {
        enum Size {
            static let circle: CGFloat = 40
            static let deleteButtonWidth: CGFloat = 100
            static let deleteButtonHeight: CGFloat = 50
        }
        
        enum Padding {
            static let spacerTop: CGFloat = 12
            static let spacerBottom: CGFloat = 13
            static let message: CGFloat = 6
            static let navigationArrowTop: CGFloat = 6
            static let navigationArrowLeading: CGFloat = 10
            static let navigationArrowTrailing: CGFloat = 16
            static let avatarTrailing: CGFloat = 12
            static let avatarLeading: CGFloat = 16
        }
        
        enum Threshold {
            static let swipe: CGFloat = -100
        }
        
        enum SwipeAction {
            static let iconSize: CGFloat = 32
        }
    }
    
    // MARK: - Properties
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization

    @State private var offset = CGFloat.zero
    
    let assignedAgent: ChatUser?
    let title: String
    let message: String?
    let timestamp: String
    let showDeleteButton: Bool
    let isArchived: Bool
    let onRename: () -> Void
    let onDelete: () -> Void
    
    // MARK: - Init
    
    init(
        assignedAgent: ChatUser?,
        title: String,
        message: String?,
        timestamp: String,
        showDeleteButton: Bool,
        isArchived: Bool = false,
        onRename: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.assignedAgent = assignedAgent
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.showDeleteButton = showDeleteButton
        self.isArchived = isArchived
        self.onRename = onRename
        self.onDelete = onDelete
    }
    
    // MARK: - Content
    
    var body: some View {
        ZStack {
            if showDeleteButton, !isIOS16OrNewer() {
                legacyDeleteButton
            }
            
            VStack {
                Spacer()
                    .frame(height: Constants.Padding.spacerTop)
                
                HStack(alignment: .top, spacing: 0) {
                    avatarView
                    
                    messageContentView

                    timeStampView
                    
                    navigationArrowView
                }
                
                Spacer()
                    .frame(height: Constants.Padding.spacerBottom)
                
                ColoredDivider(colors.customizable.onBackground.opacity(0.1))
            }
            .background(colors.customizable.background)
            .animation(.easeInOut, value: offset)
            .conditionalGesture(apply: showDeleteButton && !isIOS16OrNewer(), gesture: dragGesture)
            .if(!showDeleteButton) { view in
                view.highPriorityGesture(
                    DragGesture(minimumDistance: 1, coordinateSpace: .local)
                        .onChanged { gesture in
                            // Only block horizontal drags
                            let horizontalAmount = abs(gesture.translation.width)
                            let verticalAmount = abs(gesture.translation.height)
                            
                            if horizontalAmount > verticalAmount {
                                // This effectively cancels the horizontal swipe
                            }
                        }
                )
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .buttonStyle(.plain)
        .if(!isArchived) { view in
            view.contextMenu {
                Button(action: onRename) {
                    HStack {
                        Text(localization.chatThreadContextMenuRename)
                        
                        Asset.ChatThread.gear
                            .resizable()
                            .imageScale(.medium)
                    }
                }
                
                Button(action: onDelete) {
                    HStack {
                        Text(localization.chatThreadContextMenuArchive)
                        
                        Asset.Message.archive
                            .resizable()
                            .imageScale(.medium)
                    }
                }
            }
        }
        // If the delete button is enabled, add swipe actions on the trailing edge.
        // This enables a full swipe gesture that reveals both the archive and rename options.
        .if(showDeleteButton) { view in
            view.swipeActions(edge: .trailing, allowsFullSwipe: true) {
                archiveButton
                
                renameButton
            }
        }
        // For iOS 16 and newer when the delete button is not enabled,
        // attach empty swipe actions on both trailing and leading edges.
        // This effectively disables swipe gestures so that no actions are triggered.
        .if(!showDeleteButton && isIOS16OrNewer()) { view in
            view.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                // Empty content - no swipe actions
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                // Empty content - no swipe actions
            }
        }
    }
    
    private func isIOS16OrNewer() -> Bool {
        if #available(iOS 16, *) {
            return true
        } else {
            return false
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                let horizontalMovement = gesture.translation.width
                if horizontalMovement < 0 {
                    self.offset = horizontalMovement
                }
            }
            .onEnded { _ in
                if self.offset < Constants.Threshold.swipe {
                    self.offset = Constants.Threshold.swipe
                } else {
                    self.offset = .zero
                }
            }
    }
}

// MARK: - Subviews

private extension ThreadListCell {
    
    var messageContentView: some View {
        VStack(alignment: .leading, spacing: ThreadListCell.Constants.Padding.message) {
            Text(title)
                .foregroundColor(colors.customizable.onBackground)
                .bold()
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: dynamicYOffset(for: .subheadline))
            
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(colors.customizable.onBackground).opacity(0.5)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    var avatarView: some View {
        AvatarView(imageUrl: assignedAgent?.avatarURL, initials: assignedAgent?.initials)
            .frame(width: ThreadListCell.Constants.Size.circle, height: ThreadListCell.Constants.Size.circle)
            .padding(.trailing, ThreadListCell.Constants.Padding.avatarTrailing)
            .padding(.leading, ThreadListCell.Constants.Padding.avatarLeading)
    }
    
    var timeStampView: some View {
        VStack {
            Text(timestamp)
                .font(.subheadline)
                .foregroundColor(colors.customizable.onBackground).opacity(0.5)
                .offset(y: dynamicYOffset(for: .subheadline))
            
            Spacer()
        }
    }
    
    var navigationArrowView: some View {
        VStack {
            Asset.right
                .foregroundStyle(colors.customizable.primary)
                .offset(y: dynamicYOffset(for: .title1))
            
            Spacer()
        }
        .padding(.top, ThreadListCell.Constants.Padding.navigationArrowTop)
        .padding(.leading, ThreadListCell.Constants.Padding.navigationArrowLeading)
        .padding(.trailing, ThreadListCell.Constants.Padding.navigationArrowTrailing)
    }
    
    var legacyDeleteButton: some View {
        HStack {
            Spacer()
            
            Button(
                action: {
                    onDelete()
                    
                    withAnimation {
                        offset = .zero
                    }
                },
                label: {
                    Text(localization.chatThreadContextMenuArchive)
                        .frame(width: ThreadListCell.Constants.Size.deleteButtonWidth,
                               height: ThreadListCell.Constants.Size.deleteButtonHeight)
                        .foregroundColor(colors.foreground.staticLight)
                        .background(colors.foreground.error)
                }
            )
        }
    }
    
    var archiveButton: some View {
        Button(role: .destructive) {
            onDelete()
        } label: {
            ResizedSymbol(
                image: Asset.List.archive,
                targetSize: Constants.SwipeAction.iconSize
            )
        }
        .foregroundStyle(colors.customizable.onAccent)
        .tint(colors.customizable.accent)
    }

    var renameButton: some View {
        Button {
            onRename()
        } label: {
            ResizedSymbol(
                image: Asset.List.rename,
                targetSize: Constants.SwipeAction.iconSize
            )
        }
        .foregroundStyle(colors.customizable.onPrimary)
        .tint(colors.customizable.primary)
    }
}

// MARK: - Typography

private extension ThreadListCell {
    func dynamicYOffset(for textStyle: UIFont.TextStyle) -> CGFloat {
        let font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
        let capHeight = font.capHeight
        let lineHeight = font.lineHeight
        return -(lineHeight - capHeight) / 2
    }
}

// MARK: - Helpers

private extension View {
    @ViewBuilder func conditionalGesture<G: Gesture>(apply condition: Bool, gesture: G) -> some View {
        if condition {
            self.gesture(gesture)
        } else {
            self
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        ThreadListCell(
            assignedAgent: nil,
            title: "Customer Support",
            message: Lorem.sentence(),
            timestamp: Date().formatted(dateStyle: .none),
            showDeleteButton: false,
            isArchived: false,
            onRename: { },
            onDelete: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: nil, avatarURL: nil, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentence(),
            timestamp: Date().formatted(dateStyle: .none),
            showDeleteButton: false,
            isArchived: false,
            onRename: { },
            onDelete: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: nil, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentence(),
            timestamp: Date().formatted(dateStyle: .none),
            showDeleteButton: false,
            isArchived: false,
            onRename: { },
            onDelete: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: MockData.imageUrl, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentence(),
            timestamp: Date().formatted(dateStyle: .none),
            showDeleteButton: false,
            isArchived: false,
            onRename: { },
            onDelete: { }
        )
    }
    .listStyle(PlainListStyle())
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
