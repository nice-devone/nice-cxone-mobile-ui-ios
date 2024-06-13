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

import CXoneChatSDK
import Kingfisher
import SwiftUI

struct ListPickerMessageCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    let message: ChatMessage
    let item: ListPickerItem
    let elementSelected: (RichMessageSubElementType) -> Void
    
    // MARK: - Init
    
    init(message: ChatMessage, item: ListPickerItem, elementSelected: @escaping (RichMessageSubElementType) -> Void) {
        self.message = message
        self.item = item
        self.elementSelected = elementSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
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
                    
                    ForEach(item.buttons, id: \.self) { element in
                        switch element {
                        case .button(let button):
                            Button {
                                withAnimation {
                                    elementSelected(element)
                                }
                            } label: {
                                HStack(alignment: .center) {
                                    if let url = button.iconUrl {
                                        KFImage(url)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                    }
                                    
                                    Text(button.title)
                                        .foregroundColor(style.formTextColor)
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding(4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(style.backgroundColor)
                                )
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding(.vertical, StyleGuide.Message.paddingVertical)
                .padding(.horizontal, StyleGuide.Message.paddingHorizontal)
                .background(style.agentCellColor)
                .cornerRadius(StyleGuide.Message.cornerRadius, corners: .allCorners)
                
                Spacer(minLength: UIScreen.main.bounds.size.width / 10)
            }
        }
    }
}

// MARK: - Preview

struct ListPickerMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ListPickerMessageCell(message: MockData.listPickerMessage(), item: MockData.listPickerItem) { _ in }
                .previewDisplayName("Light Mode")
            
            ListPickerMessageCell(message: MockData.listPickerMessage(), item: MockData.listPickerItem) { _ in }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
