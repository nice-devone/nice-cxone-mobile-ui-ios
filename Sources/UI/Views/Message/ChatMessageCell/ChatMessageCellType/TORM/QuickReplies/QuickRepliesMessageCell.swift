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

import SwiftUI

struct QuickRepliesMessageCell: View, Themed, LayoutAware {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let elementsVertical: CGFloat = 0
            static let elementsHorizontal: CGFloat = 0
            static let instructionTextHorizontal: CGFloat = 8
        }
        
        enum Padding {
            static let titleVertical: CGFloat = 12
            static let titleHorizontal: CGFloat = 12
            static let optionsTop: CGFloat = 8
        }

        enum Sizing {
            /// Unlike the title card — which is capped at the bubble width in both orientations by
            /// `messageChatStyle` — the options block only takes that cap in landscape.
            ///
            /// `QuickRepliesMessageOptionsView` packs option buttons into rows against its measured
            /// width, so a narrower container pushes long titles onto rows of their own and makes the
            /// block considerably taller. On the short portrait width that trade is not worth making, so
            /// the options keep the full available width. Landscape is wide enough that an unbounded row
            /// would stretch the options far past the agent bubble above them, so there the cap matches
            /// the bubble.
            static func optionsMaxWidth(isLandscape: Bool, bubbleMaxWidth: CGFloat) -> CGFloat {
                isLandscape ? bubbleMaxWidth : .infinity
            }
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Environment(\.chatLayout) var chatLayout
    
    @Binding private var isLast: Bool
    
    @State private var selectedOption: RichMessageButton?
    
    private let message: ChatMessage
    private let item: QuickRepliesItem
    private let optionSelected: (RichMessageButton) -> Void
    
    /// The options are offered only on the latest message, and only until one has been chosen.
    private var isAwaitingSelection: Bool {
        selectedOption == nil && isLast
    }
    
    // MARK: - Init
    
    init(message: ChatMessage, item: QuickRepliesItem, isLast: Binding<Bool>, optionSelected: @escaping (RichMessageButton) -> Void) {
        self.message = message
        self.item = item
        self._isLast = isLast
        self.optionSelected = optionSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.elementsHorizontal) {
            VStack(alignment: .leading, spacing: Constants.Spacing.elementsVertical) {
                titleCard
                
                if isAwaitingSelection {
                    QuickRepliesMessageOptionsView(item: item) { option in
                        withAnimation {
                            selectedOption = option
                            optionSelected(option)
                        }
                    }
                    .frame(maxWidth: Constants.Sizing.optionsMaxWidth(isLandscape: isLandscape, bubbleMaxWidth: messageMaxWidth))
                    .padding(.top, Constants.Padding.optionsTop)
                }
            }
            
            Spacer(minLength: .zero)
        }
    }
}

// MARK: - Subviews

private extension QuickRepliesMessageCell {
    
    var titleCard: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.instructionTextHorizontal) {
            Text(item.title)
                .font(.callout)
                .foregroundStyle(colors.content.primary)
                .accessibilityIdentifier(A11y.Conversation.MessageCell.QuickReplies.Title.identifier)

            if selectedOption != nil {
                RichContentOptionSelected()
            } else if isAwaitingSelection {
                instructionText
            } else {
                MessageCellTooltipView(
                    text: L10n.Chat.Message.RichContent.optionsDisabled,
                    tooltip: L10n.Chat.Message.RichContent.optionsDisabledTooltip
                )
            }
        }
        .padding(.vertical, Constants.Padding.titleVertical)
        .padding(.horizontal, Constants.Padding.titleHorizontal)
        .messageChatStyle(message, position: .single)
        .accessibilityElement(children: .combine)
    }

    var instructionText: some View {
        HStack(spacing: Constants.Spacing.instructionTextHorizontal) {
            Asset.handPointDown
                .foregroundStyle(colors.brand.primary)
                .accessibilityHidden(true)

            Text(L10n.Chat.Message.QuickReplies.selectOneOption)
                .font(.caption)
                .foregroundStyle(colors.brand.primary)
                .accessibilityIdentifier(A11y.Conversation.MessageCell.QuickReplies.InstructionText.identifier)
                .accessibilityHint(A11y.Conversation.MessageCell.QuickReplies.hint)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selectedOption: RichMessageButton?

    let style = ChatStyle()
    let optionsDisabledItem = MockData.quickRepliesItem(title: Lorem.paragraph())
    let optionsEnabledItem = MockData.quickRepliesItem(options: MockData.quickReplyOptions(range: 5...10))

    VStack(spacing: 4) {
        QuickRepliesMessageCell(
            message: MockData.quickRepliesMessage(item: optionsDisabledItem),
            item: optionsDisabledItem,
            isLast: .constant(false)
        ) { option in
            selectedOption = option
        }

        ZStack(alignment: .bottomLeading) {
            QuickRepliesMessageCell(
                message: MockData.quickRepliesMessage(item: optionsEnabledItem),
                item: optionsEnabledItem,
                isLast: .constant(true)
            ) { option in
                selectedOption = option
            }

            AvatarView(imageUrl: MockData.agent.avatarURL, initials: MockData.agent.initials)
                .frame(width: 24, height: 24)
                .offset(x: -12, y: 12)
        }
        
        if let selectedOption {
            TextMessageCell(message: MockData.textMessage(user: MockData.customer, text: selectedOption.title), text: selectedOption.title, position: .single)
        }
    }
    .padding(.leading, 16)
    .padding(.trailing, 4)
    .environmentObject(style)
}
