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
import Kingfisher

struct RichLinkMessageCell: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @State private var isShareSheetVisible = false
    
    let message: ChatMessage
    let item: RichLinkItem
    let openLink: (URL) -> Void
    
    private static let imageMaxHeight: CGFloat = UIScreen.main.bounds.width / 3
    private static let linkSpacing: CGFloat = 2
    private static let paddingTop: CGFloat = 8
    private static let paddingHorizontal: CGFloat = 12
    private static let paddingBottom: CGFloat = 10
    
    // MARK: - Init
    
    init(message: ChatMessage, item: RichLinkItem, openLink: @escaping (URL) -> Void) {
        self.message = message
        self.item = item
        self.openLink = openLink
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack {
            Button {
                openLink(item.url)
            } label: {
                buttonContent
            }
            .background(colors.customizable.agentBackground)
            .cornerRadius(StyleGuide.Message.cornerRadius, corners: .allCorners)
            .contextMenu {
                contextMenuContent
            }
            
            Spacer(minLength: UIScreen.main.bounds.size.width / 3)
        }
        .sheet(isPresented: $isShareSheetVisible) {
            ShareSheet(activityItems: [item.url])
        }
    }
}

// MARK: - Subviews

private extension RichLinkMessageCell {

    var buttonContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            KFImage(item.imageUrl)
                .placeholder {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .resizable()
                .scaledToFill()
                .frame(maxHeight: Self.imageMaxHeight)
                .clipped()
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(colors.customizable.agentText)
                
                if let host = item.url.host {
                    HStack(spacing: Self.linkSpacing) {
                        Text(host)
                        
                        Asset.Message.RichContent.link
                    }
                    .font(.caption2)
                    .foregroundStyle(colors.customizable.primary)
                }
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, Self.paddingHorizontal)
            .padding(.top, Self.paddingTop)
            .padding(.bottom, Self.paddingBottom)
        }
    }
    
    @ViewBuilder
    var contextMenuContent: some View {
        Button {
            isShareSheetVisible = true
        } label: {
            Text(localization.commonShare)

            Asset.share
        }
        
        Button {
            UIPasteboard.general.url = item.url
            UIPasteboard.general.string = item.url.absoluteString
        } label: {
            Text(localization.commonCopy)
            
            Asset.copy
        }
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
        .environmentObject(ChatLocalization())
    }
}
