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
        
        enum SwipeAction {
            static let iconSize: CGFloat = 32
        }
    }
    
    // MARK: - Properties
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization

    @State private var cellHeight = CGFloat.zero
    @State private var offset = CGFloat.zero
    
    let assignedAgent: ChatUser?
    let title: String
    let message: String?
    let timestamp: String
    let statusType: ThreadStatusType
    let onRename: () -> Void
    let onArchive: () -> Void
    
    // MARK: - Init
    
    init(
        assignedAgent: ChatUser?,
        title: String,
        message: String?,
        timestamp: String,
        statusType: ThreadStatusType,
        onRename: @escaping () -> Void,
        onArchive: @escaping () -> Void
    ) {
        self.assignedAgent = assignedAgent
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.statusType = statusType
        self.onRename = onRename
        self.onArchive = onArchive
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if !isIOS16OrNewer, statusType == .current {
                    legacyButtons
                }
                
                content
            }
            
            ColoredDivider(colors.customizable.onBackground.opacity(0.1))
        }
        .readSize { size in
            self.cellHeight = size.height
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .buttonStyle(.plain)
        .if(statusType == .current) { view in
            view.contextMenu {
                contextMenu
            }
        }
        // If the buttons are enabled (statusType == .current) and the device is iOS 16 or newer, add swipe actions on the trailing edge.
        // This enables a full swipe gesture that reveals both the archive and rename options.
        .if(statusType == .current && isIOS16OrNewer) { view in
            view.swipeActions(edge: .trailing, allowsFullSwipe: true) {
                archiveButton
                
                renameButton
            }
        }
        // For iOS 16 and newer when the rename and archive buttons are not enabled (statusType == .archived),
        // attach empty swipe actions on both trailing and leading edges.
        // This effectively disables swipe gestures so that no actions are triggered.
        .if(statusType == .archived && isIOS16OrNewer) { view in
            view.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                // Empty content - no swipe actions
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                // Empty content - no swipe actions
            }
        }
    }
}

// MARK: - Subviews

private extension ThreadListCell {
    
    var content: some View {
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
        }
        .background(colors.customizable.background)
        .offset(x: self.offset)
        .animation(.easeInOut, value: offset)
        .conditionalGesture(apply: statusType == .current && !isIOS16OrNewer, gesture: dragGesture)
        .if(statusType == .archived) { view in
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
    
    var legacyButtons: some View {
        HStack(spacing: 0) {
            Spacer()
            
            legacyButton(Asset.List.rename, action: onRename)
                .foregroundStyle(colors.customizable.onAccent)
                .background(colors.customizable.accent)
            
            legacyButton(Asset.List.archive, action: onArchive)
                .foregroundStyle(colors.customizable.onPrimary)
                .background(colors.customizable.primary)
        }
    }
    
    func legacyButton(_ image: Image, action: @escaping () -> Void) -> some View {
        Button(
            action: {
                action()
                
                withAnimation {
                    offset = .zero
                }
            },
            label: {
                image
                    .font(.title3)
                    .frame(width: cellHeight, height: cellHeight)
            }
        )
    }
    
    var archiveButton: some View {
        Button(role: .destructive, action: onArchive) {
            ResizedSymbol(
                image: Asset.List.archive,
                targetSize: Constants.SwipeAction.iconSize
            )
        }
        .foregroundStyle(colors.customizable.onAccent)
        .tint(colors.customizable.accent)
    }

    var renameButton: some View {
        Button(action: onRename) {
            ResizedSymbol(
                image: Asset.List.rename,
                targetSize: Constants.SwipeAction.iconSize
            )
        }
        .foregroundStyle(colors.customizable.onPrimary)
        .tint(colors.customizable.primary)
    }
    
    @ViewBuilder
    var contextMenu: some View {
        Button(action: onRename) {
            HStack {
                Text(localization.chatThreadContextMenuRename)
                
                Asset.ChatThread.gear
                    .resizable()
                    .imageScale(.medium)
            }
        }
        
        Button(action: onArchive) {
            HStack {
                Text(localization.chatThreadContextMenuArchive)
                
                Asset.Message.archive
                    .resizable()
                    .imageScale(.medium)
            }
        }
    }
}

// MARK: - Private methods

private extension ThreadListCell {
    
    var isIOS16OrNewer: Bool {
        if #available(iOS 16, *) {
            return true
        } else {
            return false
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                let horizontalMovement = gesture.translation.width
                if horizontalMovement < 0 {
                    self.offset = horizontalMovement
                }
            }
            .onEnded { _ in
                // Calculate the offset based on the cell height
                // This is the threshold for the rename and archive buttons
                let buttonOffset = cellHeight * 2
                
                if self.offset < -buttonOffset {
                    self.offset = -buttonOffset
                } else {
                    self.offset = .zero
                }
            }
    }
    
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
            statusType: .current,
            onRename: { },
            onArchive: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: nil, avatarURL: nil, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentence(),
            timestamp: Date().formatted(dateStyle: .none),
            statusType: .current,
            onRename: { },
            onArchive: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: nil, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentence(),
            timestamp: Date().formatted(dateStyle: .none),
            statusType: .current,
            onRename: { },
            onArchive: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: MockData.imageUrl, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentence(),
            timestamp: Date().formatted(dateStyle: .none),
            statusType: .current,
            onRename: { },
            onArchive: { }
        )
    }
    .listStyle(PlainListStyle())
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
