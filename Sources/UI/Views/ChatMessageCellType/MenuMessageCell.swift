//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

struct MenuMessageCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    private var applyPadding = true
    
    let message: ChatMessage
    let elements: [RichMessageSubElementType]
    let elementSelected: (RichMessageSubElementType) -> Void
    
    // MARK: - Init
    
    init(message: ChatMessage, elements: [RichMessageSubElementType], elementSelected: @escaping (RichMessageSubElementType) -> Void) {
        self.message = message
        self.elements = elements
        self.elementSelected = elementSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: message.user.isAgent ? .bottomLeading : .bottomTrailing) {
            HStack {
                VStack(alignment: .leading) {
                    ForEach(elements, id: \.self) { element in
                        switch element {
                        case .text(let text, let isTitle):
                            Text(text)
                                .font(isTitle ? .title : .body)
                                .fontWeight(isTitle ? .bold : .regular)
                                .foregroundColor(isTitle ? style.agentFontColor.opacity(0.5) : style.agentFontColor)
                        case .file(let url):
                            Button {
                                elementSelected(element)
                            } label: {
                                Asset.Attachment.file
                                    .foregroundColor(style.agentFontColor.opacity(0.5))
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(url.lastPathComponent + url.pathExtension)
                                        .foregroundColor(style.agentFontColor)
                                        .font(.body)
                                    
                                    if let host = url.host {
                                        Text(host)
                                            .font(.footnote)
                                            .foregroundColor(style.agentFontColor.opacity(0.5))
                                            .underline()
                                    }
                                }
                            }
                            .frame(minHeight: 32)
                        case .button(let content):
                            Button {
                                withAnimation {
                                    elementSelected(element)
                                }
                            } label: {
                                HStack(alignment: .center) {
                                    if let url = content.iconUrl {
                                        KFImage(url)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                    }
                                    
                                    Text(content.title)
                                        .foregroundColor(style.backgroundColor).colorInvert()
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding(4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(style.backgroundColor)
                                )
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(style.agentCellColor)
                .cornerRadius(14, corners: .allCorners)
                
                if applyPadding {
                    Spacer(minLength: UIScreen.main.bounds.size.width / 10)
                }
            }
        }
        .padding([.leading, .bottom], applyPadding ? 14 : 0)
        .padding(.trailing, applyPadding ? 4 : 0)
    }
    
    // MARK: - Methods
    
    func applyPadding(_ apply: Bool) -> Self {
        var view = self
        
        view.applyPadding = apply
        
        return view
    }
}

// MARK: - Preview

struct MenuMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MenuMessageCell(message: MockData.menuMessage(), elements: MockData.menuRichMessageElements) { _ in }
                .previewDisplayName("Light Mode")
            
            MenuMessageCell(message: MockData.menuMessage(), elements: MockData.menuRichMessageElements) { _ in }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
