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

struct TimePickerMessageCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let elementsHorizontal: CGFloat = 0
            static let cellContent: CGFloat = 8
            static let gapMinLength: CGFloat = 40
            static let cellContentTitleAndMessage: CGFloat = 2
            static let sfSymbolToText: CGFloat = 4
        }
        
        enum Padding {
            static let cellContentVertical: CGFloat = 12
            static let cellContentHorizontal: CGFloat = 12
            static let cellContentActionPromptTop: CGFloat = 8
        }
        
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @Binding private var isLast: Bool
    
    @State private var isSheetVisible = false
    @State private var isOptionSelectedVisible = false
    
    private let item: TimePickerItem
    private let slotSelected: (RichMessageTimeSlot) -> Void
    
    // MARK: - Init
    
    init(item: TimePickerItem, isLast: Binding<Bool>, slotSelected: @escaping (RichMessageTimeSlot) -> Void) {
        self.item = item
        self._isLast = isLast
        self.slotSelected = slotSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.elementsHorizontal) {
            content
                .padding(.vertical, Constants.Padding.cellContentVertical)
                .padding(.horizontal, Constants.Padding.cellContentHorizontal)
                .background(colors.background.surface.default)
                .cornerRadius(StyleGuide.Sizing.Message.cornerRadius, corners: .allCorners)
                .accessibilityIdentifier(A11y.Conversation.MessageCell.TimePicker.identifier)

            Spacer(minLength: Constants.Spacing.gapMinLength)
        }
    }
}

// MARK: - Subviews

private extension TimePickerMessageCell {
    
    @ViewBuilder
    var content: some View {
        if isLast {
            Button {
                isSheetVisible = true
            } label: {
                cellContent
            }
            .sheet(isPresented: $isSheetVisible) {
                TimePickerSheetView(item: item) { element in
                    withAnimation {
                        slotSelected(element)

                        isOptionSelectedVisible = true
                        isSheetVisible = false
                    }
                }
            }
            .accessibilityHint(A11y.Conversation.MessageCell.TimePicker.hint)
        } else {
            cellContent
        }
    }

    var cellContent: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.cellContentTitleAndMessage) {
            Text(item.title)
                .font(.callout)
                .foregroundStyle(colors.content.primary)
                .accessibilityIdentifier(A11y.Conversation.MessageCell.TimePicker.Title.identifier)

            if isOptionSelectedVisible {
                RichContentOptionSelected()
            } else if isLast {
                HStack(spacing: Constants.Spacing.sfSymbolToText) {
                    Asset.handTap
                        .foregroundColor(colors.brand.primary)
                        .accessibilityHidden(true)

                    Text(L10n.Chat.Message.RichContent.pressToOpen)
                        .font(.caption)
                        .foregroundColor(colors.brand.primary)
                        .accessibilityIdentifier(A11y.Conversation.MessageCell.PressToOpen.identifier)
                }
                .padding(.top, Constants.Padding.cellContentActionPromptTop)
            } else {
                MessageCellTooltipView(
                    text: L10n.Chat.Message.RichContent.optionsDisabled,
                    tooltip: L10n.Chat.Message.RichContent.optionsDisabledTooltip
                )
            }
        }
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview {
    @Previewable @SwiftUI.Environment(\.colorScheme) var scheme
    @Previewable @State var selectedOption: RichMessageTimeSlot?
    
    let style = ChatStyle()
    
    VStack {
        ZStack(alignment: .bottomLeading) {
            TimePickerMessageCell(item: MockData.timePickerItem, isLast: .constant(false)) { option in
                selectedOption = option
            }
            
            TimePickerMessageCell(item: MockData.timePickerItem, isLast: .constant(true)) { option in
                selectedOption = option
            }
            
            AvatarView(imageUrl: MockData.agent.avatarURL, initials: MockData.agent.initials)
                .frame(width: 24, height: 24)
                .offset(x: -12, y: 12)
        }
        
        if let selectedOption {
            HStack {
                Spacer(minLength: UIScreen.main.bounds.size.width / 10)
                
                Text(String(format: "%@ %d minutes", selectedOption.startTime.formatted(), selectedOption.durationInMinutes))
                    .foregroundStyle(style.colors(for: scheme).brand.onPrimary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(style.colors(for: scheme).brand.primary)
                )
            }
        }
        
        Spacer()
    }
    .padding(.leading, 16)
    .padding(.trailing, 4)
    .environmentObject(style)
}
