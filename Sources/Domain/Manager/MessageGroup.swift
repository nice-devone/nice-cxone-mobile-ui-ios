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
import Foundation

struct MessageGroup: Identifiable, Equatable {

    // MARK: Properties
    
    let messages: [ChatMessage]
    let shouldShowHeader: Bool
    let shouldShowFooter: Bool
    let status: MessageStatus
    
    // swiftlint:disable force_unwrapping
    var id: UUID { messages.map(\.id).hash() ?? UUID() }
    var date: Date { messages.first!.date }
    var sender: ChatUser? { messages.first!.user }
    var shouldShowAvatar: Bool { sender?.isAgent == true }
    
    // swiftlint:enable force_unwrapping

    // MARK: - Initialization

    init?(messages: [ChatMessage], showHeader: Bool, showFooter: Bool) {
        guard !messages.isEmpty else {
            return nil
        }

        self.messages = messages
        self.shouldShowHeader = showHeader
        // swiftlint:disable:next force_unwrapping
        self.status = messages.last!.status
        self.shouldShowFooter = messages.first?.isUserAgent == false && (status == .seen || showFooter)
    }

    // MARK: - Methods
    
    func position(of message: ChatMessage) -> MessageGroupPosition {
        guard messages.count > 1 else {
            return .single
        }
        
        switch message {
        case messages.first:
            return .first
        case messages.last:
            return .last
        default:
            return .inside
        }
    }
}

// MARK: - Array<ChatMessage> extensions

extension Array where Element == ChatMessage {

    // Main grouping function that orchestrates the process
    func groupMessages(interval: TimeInterval) -> [MessageGroup] {
        LogManager.time {
            let groups = createInitialGroups(withInterval: interval)
            let sortedGroups = sortMessageTypes(in: groups)
            
            return createMessageGroups(from: sortedGroups, originalGroups: groups, interval: interval)
        }
    }
    
    // Function to create initial groups based on message criteria
    private func createInitialGroups(withInterval interval: TimeInterval) -> [[ChatMessage]] {
        group { last, current in
            shouldGroupMessages(last: last, current: current, interval: interval)
        }
    }
    
    // Determine if messages should be grouped
    private func shouldGroupMessages(last: ChatMessage, current: ChatMessage, interval: TimeInterval) -> Bool {
        !current.richContentMessages
            && !last.richContentMessages
            && current.user?.id == last.user?.id
            && abs(last.date.timeIntervalSince(current.date)) <= interval
    }
    
    // Create final MessageGroup objects
    private func createMessageGroups(
        from sortedGroups: [[ChatMessage]],
        originalGroups: [[ChatMessage]],
        interval: TimeInterval
    ) -> [MessageGroup] {
        sortedGroups.enumerated().compactMap { index, messages in
            let showHeader = shouldShowHeader(for: index, in: originalGroups, interval: interval)
            
            return MessageGroup(
                messages: messages,
                showHeader: showHeader,
                showFooter: originalGroups.count == index + 1
            )
        }
    }
    
    // Determine if header should be shown
    private func shouldShowHeader(for index: Int, in groups: [[ChatMessage]], interval: TimeInterval) -> Bool {
        guard let previousGroupLastMessageDate = groups[safe: index - 1]?.last?.date,
              let currentGroupFirstMessageDate = groups[safe: index]?.first?.date else {
            return true
        }
        
        return abs(previousGroupLastMessageDate.timeIntervalSince(currentGroupFirstMessageDate)) > interval
    }
    
    // Sorts message types to ensure attachments appear before non-attachments in each message
    private func sortMessageTypes(in groups: [[ChatMessage]]) -> [[ChatMessage]] {
        groups.map { group in
            group.map { message in
                var sortedMessage = message
                sortedMessage.types.sort { type1, type2 in
                    type1.isAttachment && !type2.isAttachment
                }
                return sortedMessage
            }
        }
    }
}
