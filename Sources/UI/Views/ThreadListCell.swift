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
    
    private enum Constants {
        
        enum Sizing {
            static let circle: CGFloat = 40
            static let titleTimestampSpacerMinLength: CGFloat = 8
            static let messageLineLimit = 2
        }
        enum Spacing {
            static let bodyVertical: CGFloat = 0
            static let contentHorizontal: CGFloat = 12
            static let messageContentVertical: CGFloat = 6
            static let messageContentHorizontal: CGFloat = 2
            static let timestampChevronHorizontal: CGFloat = 6
            static let legacyButtonsHorizontal: CGFloat = 0
        }
        enum Padding {
            static let contentVertical: CGFloat = 12
            static let contentHorizontal: CGFloat = 16
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
    let isRead: Bool
    let onRename: () -> Void
    let onArchive: () -> Void
    
    // MARK: - Init
    
    init(
        assignedAgent: ChatUser?,
        title: String,
        message: String?,
        timestamp: String,
        statusType: ThreadStatusType,
        isRead: Bool,
        onRename: @escaping () -> Void,
        onArchive: @escaping () -> Void
    ) {
        self.assignedAgent = assignedAgent
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.statusType = statusType
        self.isRead = isRead
        self.onRename = onRename
        self.onArchive = onArchive
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack(spacing: Constants.Spacing.bodyVertical) {
            ZStack {
                if !isIOS16OrNewer, statusType == .current {
                    legacyButtons
                }
                
                content
            }
            
            ColoredDivider(colors.border.default)
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
        HStack(alignment: .top, spacing: Constants.Spacing.contentHorizontal) {
            AvatarView(imageUrl: assignedAgent?.avatarURL, initials: assignedAgent?.initials)
                .frame(width: ThreadListCell.Constants.Sizing.circle, height: ThreadListCell.Constants.Sizing.circle)
                
            messageContentView
        }
        .padding(.vertical, Constants.Padding.contentVertical)
        .padding(.horizontal, Constants.Padding.contentHorizontal)
        .background(colors.background.default)
        .offset(x: self.offset)
        .animation(.easeInOut, value: offset)
        .animation(.easeInOut, value: isRead)
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
        VStack(alignment: .leading, spacing: Constants.Spacing.messageContentVertical) {
            HStack(alignment: .firstTextBaseline, spacing: Constants.Spacing.messageContentHorizontal) {
                if !isRead, statusType == .current {
                    Asset.List.unreadIndicator
                        .font(.footnote)
                        .foregroundStyle(colors.brand.primary)
                        .accessibilityIdentifier("thread_unread_indicator")
                }
                
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(colors.content.primary)
                
                Spacer(minLength: Constants.Sizing.titleTimestampSpacerMinLength)
                
                timestampChevronView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let message {
                Text(message)
                    .font(.subheadline)
                    .if(!isRead && statusType == .current) { view in
                        view.bold()
                    }
                    .foregroundStyle(colors.content.secondary)
                    .lineLimit(Constants.Sizing.messageLineLimit)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    var timestampChevronView: some View {
        HStack(alignment: .firstTextBaseline, spacing: Constants.Spacing.timestampChevronHorizontal) {
            Text(timestamp)
                .font(.subheadline)
                .if(!isRead && statusType == .current) { view in
                    view.bold()
                }
                .foregroundStyle(colors.content.secondary)
            
            Asset.right
                .font(.body.weight(.medium))
                .foregroundStyle(colors.brand.primary)
        }
    }
    
    var legacyButtons: some View {
        HStack(spacing: Constants.Spacing.legacyButtonsHorizontal) {
            Spacer()
            
            legacyButton(Asset.List.rename, action: onRename)
                .foregroundStyle(colors.status.onSuccess)
                .background(colors.status.success)
            
            legacyButton(Asset.List.archive, action: onArchive)
                .foregroundStyle(colors.status.onWarning)
                .background(colors.status.warning)
        }
    }
    
    func legacyButton(_ image: Image, action: @escaping () -> Void) -> some View {
        Button {
            action()
                
            withAnimation {
                offset = .zero
            }
        } label: {
            image
                .font(.title3)
                .frame(width: cellHeight, height: cellHeight)
        }
    }
    
    var archiveButton: some View {
        Button(role: .destructive, action: onArchive) {
            ResizedSymbol(
                image: Asset.List.archive,
                targetSize: StyleGuide.Sizing.buttonSmallDimension
            )
        }
        .foregroundStyle(colors.status.onWarning)
        .tint(colors.status.warning)
    }

    var renameButton: some View {
        Button(action: onRename) {
            ResizedSymbol(
                image: Asset.List.rename,
                targetSize: StyleGuide.Sizing.buttonSmallDimension
            )
        }
        .foregroundStyle(colors.status.onSuccess)
        .tint(colors.status.success)
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
}

// MARK: - Helpers

private extension View {
    
    @ViewBuilder
    func conditionalGesture<G: Gesture>(apply condition: Bool, gesture: G) -> some View {
        if condition {
            self.gesture(gesture)
        } else {
            self
        }
    }
}

// MARK: - Preview

#Preview {
    let dateFormatter = AdaptiveDateFormatter()
    
    List {
        ThreadListCell(
            assignedAgent: nil,
            title: "Alessandro Giovanni Matteo Jiménez",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date().adding(.year, value: -2)),
            statusType: .current,
            isRead: true,
            onRename: { },
            onArchive: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: nil, avatarURL: nil, isAgent: true),
            title: "Peter Parker",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date().adding(.day, value: -10)),
            statusType: .current,
            isRead: true,
            onRename: { },
            onArchive: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: nil, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date().adding(.day, value: -3)),
            statusType: .current,
            isRead: true,
            onRename: { },
            onArchive: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: nil, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date().adding(.day, value: -1)),
            statusType: .current,
            isRead: true,
            onRename: { },
            onArchive: { }
        )
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: MockData.imageUrl, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date()),
            statusType: .current,
            isRead: false,
            onRename: { },
            onArchive: { }
        )
    }
    .listStyle(PlainListStyle())
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
