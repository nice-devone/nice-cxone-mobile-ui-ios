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
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var selectedOption: RichMessageButton?
    
    let item: QuickRepliesItem
    let optionSelected: (RichMessageButton) -> Void
    
    private let options: [RichMessageButton]
    
    private static let spacingCellAndOption: CGFloat = 14
    private static let paddingVertical: CGFloat = 12
    private static let paddingHorizontal: CGFloat = 12
    
    // MARK: - Init
    
    init(item: QuickRepliesItem, optionSelected: @escaping (RichMessageButton) -> Void) {
        self.item = item
        self.optionSelected = optionSelected
        self.options = item.options
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: Self.spacingCellAndOption) {
            HStack {
                Text(item.title)
                    .font(.callout)
                    .foregroundStyle(colors.customizable.agentText)
                    .padding(.vertical, Self.paddingVertical)
                    .padding(.horizontal, Self.paddingHorizontal)
                    .background(colors.customizable.agentBackground)
                    .cornerRadius(StyleGuide.Message.cornerRadius, corners: .allCorners)
                
                Spacer(minLength: UIScreen.main.bounds.size.width / 10)
            }
            
            if selectedOption != nil {
                RichContentOptionSelected()
            } else {
                QuickRepliesMessageOptionsView(item: item) { option in
                    withAnimation {
                        selectedOption = option
                        optionSelected(option)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct QuickRepliesMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            TestViewPreview()
                .previewDisplayName("Light Mode")
                
            TestViewPreview()
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}

private struct TestViewPreview: View, Themed {
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var selectedOption: RichMessageButton?
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack(alignment: .bottomLeading) {
                QuickRepliesMessageCell(item: MockData.quickRepliesItem) { option in
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
                        .foregroundStyle(colors.foreground.onContrast)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colors.accent.accent)
                    )
                }
            }
            
            Spacer()
        }
        .listStyle(.inset)
        .padding(.leading, 16)
        .padding(.trailing, 4)
    }
}
