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

struct ListPickerMessageCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        @MainActor
        enum Spacing {
            static let elementsHorizontal: CGFloat = 0
            static let cellContent: CGFloat = 8
            static let gapMinLength: CGFloat = UIScreen.currentBounds.width / 10
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
    
    @State private var isSheetVisible = false
    @State private var isOptionSelectedVisible = false
    
    private let message: ChatMessage
    private let item: ListPickerItem
    private let elementSelected: (RichMessageButton) -> Void
    
    // MARK: - Init
    
    init(message: ChatMessage, item: ListPickerItem, elementSelected: @escaping (RichMessageButton) -> Void) {
        self.message = message
        self.item = item
        self.elementSelected = elementSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.elementsHorizontal) {
            cellContent
            
            Spacer(minLength: Constants.Spacing.gapMinLength)
        }
        .sheet(isPresented: $isSheetVisible) {
            ListPickerSheetView(item: item) { element in
                withAnimation {
                    elementSelected(element)
                    isOptionSelectedVisible = true
                    isSheetVisible = false
                }
            }
        }
    }
}

// MARK: - Subviews

private extension ListPickerMessageCell {
    
    var cellContent: some View {
        Button {
            isSheetVisible = true
        } label: {
            VStack(alignment: .leading, spacing: Constants.Spacing.cellContentTitleAndMessage) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(colors.content.primary)
                    .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Title.identifier)

                if let message = item.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(colors.content.secondary)
                        .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Message.identifier)
                }

                if isOptionSelectedVisible {
                    RichContentOptionSelected()
                        .padding(.top, Constants.Padding.cellContentActionPromptTop)
                } else {
                    HStack(spacing: Constants.Spacing.sfSymbolToText) {
                        Asset.handTap
                            .foregroundStyle(colors.brand.primary)
                            .accessibilityHidden(true)

                        Text(L10n.Chat.Message.RichContent.pressToOpen)
                            .font(.caption)
                            .foregroundStyle(colors.brand.primary)
                            .accessibilityIdentifier(A11y.Conversation.MessageCell.PressToOpen.identifier)
                    }
                    .padding(.top, Constants.Padding.cellContentActionPromptTop)
                }
            }
            .multilineTextAlignment(.leading)
        }
        .padding(.vertical, Constants.Padding.cellContentVertical)
        .padding(.horizontal, Constants.Padding.cellContentHorizontal)
        .messageChatStyle(message, position: .single)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.identifier)
        .accessibilityHint(A11y.Conversation.MessageCell.ListPicker.hint)
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview {
    @Previewable @SwiftUI.Environment(\.colorScheme) var scheme
    @Previewable @State var selectedOption: RichMessageButton?
    
    let style = ChatStyle()
    
    VStack {
        ZStack(alignment: .bottomLeading) {
            ListPickerMessageCell(message: MockData.listPickerMessage(), item: MockData.listPickerItem()) { option in
                selectedOption = option
            }
            
            AvatarView(imageUrl: MockData.agent.avatarURL, initials: MockData.agent.initials)
                .frame(width: 24, height: 24)
                .offset(x: -12, y: 12)
        }
        
        if let selectedOption {
            HStack {
                Spacer(minLength: UIScreen.currentBounds.width / 10)
                
                Text(selectedOption.title)
                    .foregroundStyle(style.colors(for: scheme).brand
                        .onPrimary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(style.colors(for: scheme).brand
                            .primary)
                )
            }
        }
        
        Spacer()
    }
    .padding(.leading, 16)
    .padding(.trailing, 4)
    .environmentObject(style)
}
