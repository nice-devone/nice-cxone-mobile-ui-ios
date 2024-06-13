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

struct OfflineView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject private var style: ChatStyle
    
    let onCloseTapped: () -> Void
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            Asset.LiveChat.offline
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 4)
                .foregroundColor(style.formTextColor.opacity(0.2))
                .padding(.bottom, 24)
            
            Text(localization.liveChatOfflineTitle)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(style.formTextColor)
            
            Text(localization.liveChatOfflineMessage)
                .font(.headline)
                .foregroundColor(style.formTextColor.opacity(0.8))
        }
        .animation(.spring)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onCloseTapped) {
                    Text(localization.commonClose)
                }
                .foregroundColor(style.navigationBarElementsColor)
            }
        }
    }
}

// MARK: - Previews

struct OfflineView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OfflineView { }
                .previewDisplayName("Light Mode")
            
            OfflineView { }
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
    }
}
