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

struct RichLinkMessageCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @State private var isShareSheetVisible = false
    
    private var applyPadding = true
    
    let message: ChatMessage
    let item: RichLinkItem
    let openLink: (URL) -> Void
    
    // MARK: - Init
    
    init(message: ChatMessage, item: RichLinkItem, openLink: @escaping (URL) -> Void) {
        self.message = message
        self.item = item
        self.openLink = openLink
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: message.user.isAgent ? .bottomLeading : .bottomTrailing) {
            HStack {
                VStack(alignment: .leading) {
                    KFImage(item.imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 150)
                        .clipped()
                    
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(style.agentFontColor)
                        
                        if let host = item.url.host {
                            Text(host)
                                .font(.footnote)
                                .foregroundColor(style.agentFontColor.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                }
                .background(style.agentCellColor)
                .cornerRadius(14, corners: .allCorners)
                .contextMenu {
                    Button {
                        isShareSheetVisible = true
                    } label: {
                        Text("Share")
                        
                        Asset.share
                    }
                    
                    Button {
                        UIPasteboard.general.url = item.url
                        UIPasteboard.general.string = item.url.absoluteString
                    } label: {
                        Text("Copy")
                        
                        Asset.copy
                    }
                }
                
                if applyPadding {
                    Spacer(minLength: UIScreen.main.bounds.size.width / 3)
                }
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 4)
        .onTapGesture {
            openLink(item.url)
        }
        .sheet(isPresented: $isShareSheetVisible) {
            ShareSheet(activityItems: [item.url])
        }
    }
    
    // MARK: - Methods
    
    func applyPadding(_ apply: Bool) -> Self {
        var view = self
        
        view.applyPadding = apply
        
        return view
    }
}

// MARK: - Preview

struct RichLinkMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            RichLinkMessageCell(message: MockData.richLinkMessage(), item: MockData.richLinkItem) { _ in }
                .previewDisplayName("Light Mode")
            
            RichLinkMessageCell(message: MockData.richLinkMessage(), item: MockData.richLinkItem) { _ in }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
