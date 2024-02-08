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

struct SatisfactionSurveyMessageCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    private var applyPadding = true
    
    let message: ChatMessage
    let item: SatisfactionSurveyItem
    let openLink: (URL) -> Void
    
    // MARK: - Init
    
    init(message: ChatMessage, item: SatisfactionSurveyItem, openLink: @escaping (URL) -> Void) {
        self.message = message
        self.item = item
        self.openLink = openLink
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: message.user.isAgent ? .bottomLeading : .bottomTrailing) {
            HStack {
                VStack(alignment: .leading) {
                    if let title = item.title {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(style.agentFontColor.opacity(0.5))
                    }
                    
                    if let message = item.message {
                        Text(message)
                            .font(.body)
                            .foregroundColor(style.agentFontColor)
                    }
                    
                    Button(item.buttonTitle) {
                        if let url = item.url {
                            openLink(url)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(style.backgroundColor)
                    )
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(style.agentCellColor)
                .cornerRadius(14, corners: .allCorners)
                
                if applyPadding {
                    Spacer(minLength: UIScreen.main.bounds.size.width / 3)
                }
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 4)
    }
    
    // MARK: - Methods
    
    func applyPadding(_ apply: Bool) -> Self {
        var view = self
        
        view.applyPadding = apply
        
        return view
    }
}

// MARK: - Preview

struct SatisfactionSurveyMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SatisfactionSurveyMessageCell(message: MockData.satisfactionSurveyMessage(), item: MockData.satisfactionSurveyItem) { _ in }
                .previewDisplayName("Light Mode")
            
            SatisfactionSurveyMessageCell(message: MockData.satisfactionSurveyMessage(), item: MockData.satisfactionSurveyItem) { _ in }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
