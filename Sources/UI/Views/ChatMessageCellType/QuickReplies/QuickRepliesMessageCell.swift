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

import SwiftUI

struct QuickRepliesMessageCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let elementsVertical: CGFloat = 0
            static let titleMinLength: CGFloat = UIScreen.main.bounds.size.width / 10
            static let instructionTextHorizontal: CGFloat = 8
        }
        
        enum Padding {
            static let titleVertical: CGFloat = 12
            static let titleHorizontal: CGFloat = 12
            static let optionsTop: CGFloat = 8
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @Binding private var isLast: Bool
    
    @State private var selectedOption: RichMessageButton?
    
    private let item: QuickRepliesItem
    private let optionSelected: (RichMessageButton) -> Void
    private let options: [RichMessageButton]
    
    // MARK: - Init
    
    init(item: QuickRepliesItem, isLast: Binding<Bool>, optionSelected: @escaping (RichMessageButton) -> Void) {
        self.item = item
        self._isLast = isLast
        self.optionSelected = optionSelected
        self.options = item.options
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.elementsVertical) {
            HStack {
                titleCard
                
                Spacer(minLength: Constants.Spacing.titleMinLength)
            }
            
            if selectedOption == nil && isLast {
                QuickRepliesMessageOptionsView(item: item) { option in
                    withAnimation {
                        selectedOption = option
                        optionSelected(option)
                    }
                }
                .padding(.top, Constants.Padding.optionsTop)
            }
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
            
            if selectedOption != nil {
                RichContentOptionSelected()
            } else if isLast {
                instructionText
            } else {
                optionsUnavailableText
            }
        }
        .padding(.vertical, Constants.Padding.titleVertical)
        .padding(.horizontal, Constants.Padding.titleHorizontal)
        .background(colors.background.surface.default)
        .cornerRadius(StyleGuide.Sizing.Message.cornerRadius, corners: .allCorners)
    }
    
    var instructionText: some View {
        HStack(spacing: Constants.Spacing.instructionTextHorizontal) {
            Asset.handPointDown
                .foregroundColor(colors.brand.primary)
            
            Text(localization.chatMessageQuickRepliesSelectOneOption)
                .font(.caption)
                .foregroundColor(colors.brand.primary)
        }
    }
    
    var optionsUnavailableText: some View {
        MessageCellTooltipView(
            text: localization.chatMessageRichContentOptionsDisabled,
            tooltip: localization.chatMessageRichContentOptionsDisabledTooltip
        )
    }
    
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme
    
    @Previewable @State var selectedOption: RichMessageButton?
    
    let style = ChatStyle()
    
    VStack(spacing: 32) {
        ZStack(alignment: .bottomLeading) {
            QuickRepliesMessageCell(item: MockData.quickRepliesItem, isLast: .constant(false)) { option in
                selectedOption = option
            }
            
            QuickRepliesMessageCell(item: MockData.quickRepliesItem, isLast: .constant(true)) { option in
                selectedOption = option
            }
            
            AvatarView(imageUrl: MockData.agent.avatarURL, initials: MockData.agent.initials)
                .frame(width: 24, height: 24)
                .offset(x: -12, y: 12)
        }
        
        if let selectedOption {
            HStack {
                Spacer(minLength: UIScreen.main.bounds.size.width / 10)
                
                Text(selectedOption.title)
                    .foregroundStyle(style.colors(for: colorScheme).brand
                        .onPrimary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(style.colors(for: colorScheme).brand
                            .primary)
                )
            }
        }
        
        Spacer()
    }
    .listStyle(.inset)
    .padding(.leading, 16)
    .padding(.trailing, 4)
    .environmentObject(style)
    .environmentObject(ChatLocalization())
}
