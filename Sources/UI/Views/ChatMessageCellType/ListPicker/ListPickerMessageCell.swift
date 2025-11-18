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

struct ListPickerMessageCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let elementsHorizontal: CGFloat = 0
            static let cellContent: CGFloat = 8
            static let gapMinLength: CGFloat = UIScreen.main.bounds.size.width / 10
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
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @State private var isSheetVisible = false
    @State private var isOptionSelectedVisible = false
    
    let item: ListPickerItem
    let elementSelected: (RichMessageButton) -> Void
    
    // MARK: - Init
    
    init(item: ListPickerItem, elementSelected: @escaping (RichMessageButton) -> Void) {
        self.item = item
        self.elementSelected = elementSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.elementsHorizontal) {
            VStack(alignment: .leading, spacing: Constants.Spacing.cellContent) {
                cellContent
            }
            
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
    
    @ViewBuilder
    var cellContent: some View {
        Button {
            isSheetVisible = true
        } label: {
            VStack(alignment: .leading, spacing: Constants.Spacing.cellContentTitleAndMessage) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(colors.content.primary)
                
                if let message = item.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(colors.content.secondary)
                }
                
                if isOptionSelectedVisible {
                    HStack(spacing: Constants.Spacing.sfSymbolToText) {
                        Asset.Message.RichContent.optionSelected
                            .foregroundColor(colors.brand.primary)
                        
                        Text(localization.chatMessageRichContentOptionSelected)
                            .font(.caption)
                            .foregroundColor(colors.brand.primary)
                    }
                    .padding(.top, Constants.Padding.cellContentActionPromptTop)
                } else {
                    HStack(spacing: Constants.Spacing.sfSymbolToText) {
                        Asset.handTap
                            .foregroundColor(colors.brand.primary)
                        
                        Text(localization.chatMessageListPickerPressToOpen)
                            .font(.caption)
                            .foregroundColor(colors.brand.primary)
                    }
                    .padding(.top, Constants.Padding.cellContentActionPromptTop)
                }
            }
            .multilineTextAlignment(.leading)
        }
        .padding(.vertical, Constants.Padding.cellContentVertical)
        .padding(.horizontal, Constants.Padding.cellContentHorizontal)
        .background(colors.background.surface.default)
        .cornerRadius(StyleGuide.Sizing.Message.cornerRadius, corners: .allCorners)
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
            ListPickerMessageCell(item: MockData.listPickerItem) { option in
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
    .environmentObject(ChatLocalization())
}
