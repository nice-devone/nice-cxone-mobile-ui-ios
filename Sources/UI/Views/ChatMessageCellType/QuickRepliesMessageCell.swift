//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

import Kingfisher
import SwiftUI

struct QuickRepliesMessageCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    let message: ChatMessage
    let item: QuickRepliesItem
    let optionSelected: (RichMessageButton) -> Void
    
    @State private var selectedOption: RichMessageButton?
    @State private var options = [RichMessageButton]()
    
    // MARK: - Init
    
    init(message: ChatMessage, item: QuickRepliesItem, optionSelected: @escaping (RichMessageButton) -> Void) {
        self.message = message
        self.item = item
        self.optionSelected = optionSelected
        self._options = State(wrappedValue: item.options)
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: message.user.isAgent ? .bottomLeading : .bottomTrailing) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(style.agentFontColor.opacity(0.5))
                        
                        if let message = item.message {
                            Text(message)
                                .font(.body)
                                .foregroundColor(style.agentFontColor)
                        }
                    }
                    .padding(.vertical, StyleGuide.Message.paddingVertical)
                    .padding(.horizontal, StyleGuide.Message.paddingHorizontal)
                    .background(style.agentCellColor)
                    .cornerRadius(StyleGuide.Message.cornerRadius, corners: .allCorners)
                    
                    Spacer(minLength: UIScreen.main.bounds.size.width / 10)
                }
            }
            
            quickReplyOptions
        }
    }
}

// MARK: - Subviews

private extension QuickRepliesMessageCell {

    @ViewBuilder private var quickReplyOptions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Spacer(minLength: 4)
                
                ForEach($options, id: \.title) { option in
                    Button {
                        optionSelected(option.wrappedValue)
                        
                        withAnimation {
                            selectedOption = option.wrappedValue
                            options = [option.wrappedValue]
                        }
                    } label: {
                        HStack {
                            if let url = option.wrappedValue.iconUrl {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                            }
                            
                            Text(option.wrappedValue.title)
                                .foregroundColor(style.customerFontColor)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                    }
                    .frame(maxWidth: .infinity, minHeight: StyleGuide.buttonDimension)
                    .background(
                        Capsule()
                            .fill(style.customerCellColor)
                    )
                    .disabled(selectedOption != nil)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct QuickRepliesMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            QuickRepliesMessageCell(message: MockData.quickRepliesMessage(), item: MockData.quickRepliesItem) { _ in }
                .previewDisplayName("Light Mode")
            
            QuickRepliesMessageCell(message: MockData.quickRepliesMessage(), item: MockData.quickRepliesItem) { _ in }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
