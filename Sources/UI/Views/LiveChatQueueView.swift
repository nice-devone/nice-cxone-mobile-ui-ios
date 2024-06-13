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

import SwiftUI

struct LiveChatQueueView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @Binding var positionInQueue: Int?
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            Asset.LiveChat.personWithClock
                .font(.largeTitle)
                .foregroundColor(style.formTextColor)
            
            Text(localization.liveChatQueueTitle)
                .font(.headline)
                .foregroundColor(style.formTextColor)
            
            if let positionInQueue {
                Text(String(format: localization.liveChatQueueMessage, positionInQueue))
                    .font(.subheadline)
                    .foregroundColor(style.formTextColor)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(style.formTextColor)
                .opacity(0.2)
                .shadow(color: style.formTextColor, radius: 2, x: 2, y: 2)
        )
        .animation(.easeInOut, value: positionInQueue)
    }
}

// MARK: - Preview

struct LiveChatQueueView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            VStack {
                LiveChatQueueView(positionInQueue: .constant(3))
                
                ChatExampleView()
            }
            .previewDisplayName("Light Mode")
            
            VStack {
                LiveChatQueueView(positionInQueue: .constant(3))
                
                ChatExampleView()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
