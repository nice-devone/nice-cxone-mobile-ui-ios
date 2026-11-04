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
        }
        enum Padding {
            static let contentVertical: CGFloat = 12
            static let contentHorizontal: CGFloat = 16
        }
    }
    
    // MARK: - Properties
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle

    let assignedAgent: ChatUser?
    let title: String
    let message: String?
    let timestamp: String
    let statusType: ThreadStatusType
    let isRead: Bool
    let hasPendingSatisfactionSurvey: Bool
    
    // MARK: - Init
    
    init(
        assignedAgent: ChatUser?,
        title: String,
        message: String?,
        timestamp: String,
        statusType: ThreadStatusType,
        isRead: Bool,
        hasPendingSatisfactionSurvey: Bool = false
    ) {
        self.assignedAgent = assignedAgent
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.statusType = statusType
        self.isRead = isRead
        self.hasPendingSatisfactionSurvey = hasPendingSatisfactionSurvey
    }
    
    // MARK: - Content
    
    var body: some View {
        VStack(spacing: Constants.Spacing.bodyVertical) {
            HStack(alignment: .top, spacing: Constants.Spacing.contentHorizontal) {
                AvatarView(imageUrl: assignedAgent?.avatarURL, initials: assignedAgent?.initials)
                    .frame(width: ThreadListCell.Constants.Sizing.circle, height: ThreadListCell.Constants.Sizing.circle)
                    
                messageContentView
            }
            .padding(.vertical, Constants.Padding.contentVertical)
            .padding(.horizontal, Constants.Padding.contentHorizontal)
            .background(colors.background.default)
            .animation(.easeInOut, value: isRead)

            ColoredDivider(colors.border.default)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Subviews

private extension ThreadListCell {
    
    var messageContentView: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.messageContentVertical) {
            HStack(alignment: .firstTextBaseline, spacing: Constants.Spacing.messageContentHorizontal) {
                if showsUnreadIndicator {
                    Asset.List.unreadIndicator
                        .font(.footnote)
                        .foregroundStyle(colors.brand.primary)
                        .accessibilityIdentifier(A11y.ThreadList.Cell.UnreadIndicator.identifier)
                        .accessibilityLabel(A11y.ThreadList.Cell.UnreadIndicator.label)
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
                    .if(showsUnreadIndicator) { view in
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
                .if(showsUnreadIndicator) { view in
                    view.bold()
                }
                .foregroundStyle(colors.content.secondary)
            
            Asset.right
                .font(.body.weight(.medium))
                .foregroundStyle(colors.brand.primary)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Methods

extension ThreadListCell {

    /// Whether the cell shows the unread indicator - also used for the row's VoiceOver value.
    ///
    /// Unread messages count only in the current list, but a held satisfaction survey counts in either: surveys usually
    /// arrive as a case closes, and closed threads are listed under Archived.
    static func showsUnreadIndicator(isRead: Bool, statusType: ThreadStatusType, hasPendingSatisfactionSurvey: Bool) -> Bool {
        hasPendingSatisfactionSurvey || (!isRead && statusType == .current)
    }
}

// MARK: - Private methods

private extension ThreadListCell {

    var showsUnreadIndicator: Bool {
        Self.showsUnreadIndicator(isRead: isRead, statusType: statusType, hasPendingSatisfactionSurvey: hasPendingSatisfactionSurvey)
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
            isRead: true
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: nil, avatarURL: nil, isAgent: true),
            title: "Peter Parker",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date().adding(.day, value: -10)),
            statusType: .current,
            isRead: true
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: nil, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date().adding(.day, value: -3)),
            statusType: .current,
            isRead: true
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: nil, isAgent: true),
            title: "Customer Support",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date().adding(.day, value: -1)),
            statusType: .current,
            isRead: true
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        
        ThreadListCell(
            assignedAgent: ChatUser(id: "1", userName: "Peter Parker", avatarURL: MockData.imageUrl(), isAgent: true),
            title: "Customer Support",
            message: Lorem.sentences(nbSentences: Int.random(in: 1...3)).joined(separator: " "),
            timestamp: dateFormatter.string(from: Date()),
            statusType: .archived,
            isRead: false
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .environmentObject(ChatStyle())
}
