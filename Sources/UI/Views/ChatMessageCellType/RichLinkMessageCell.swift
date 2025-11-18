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

import Kingfisher
import SwiftUI

struct RichLinkMessageCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let gapMinLength: CGFloat = UIScreen.main.bounds.width / 3
            static let linkHorizontal: CGFloat = 2
            static let buttonContentVertical: CGFloat = 8
            static let titleAndHostVertical: CGFloat = 6
        }
        
        enum Padding {
            static let buttonContentHorizontal: CGFloat = 12
            static let buttonContentBottom: CGFloat = 12
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @State private var isShareSheetVisible = false
    
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
        HStack {
            Button {
                openLink(item.url)
            } label: {
                buttonContent
            }
            .background(colors.background.surface.default)
            .cornerRadius(StyleGuide.Sizing.Message.cornerRadius, corners: .allCorners)
            .contextMenu {
                contextMenuContent
            }
            
            Spacer(minLength: Constants.Spacing.gapMinLength)
        }
        .sheet(isPresented: $isShareSheetVisible) {
            ShareSheet(activityItems: [item.url])
        }
    }
}

// MARK: - Subviews

private extension RichLinkMessageCell {

    var buttonContent: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.buttonContentVertical) {
            KFImage(item.imageUrl)
                .placeholder {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .resizable()
                .scaledToFill()
                .frame(maxHeight: StyleGuide.Sizing.Attachment.regularDimension)
                .clipped()
            
            VStack(alignment: .leading, spacing: Constants.Spacing.titleAndHostVertical) {
                Text(item.title)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(colors.content.primary)
                
                if let host = item.url.host {
                    HStack(spacing: Constants.Spacing.linkHorizontal) {
                        Text(host)
                        
                        Asset.Message.RichContent.link
                    }
                    .font(.caption2)
                    .foregroundStyle(colors.brand.primary)
                }
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, Constants.Padding.buttonContentHorizontal)
        }
        .padding(.bottom, Constants.Padding.buttonContentBottom)
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

#Preview {
    RichLinkMessageCell(message: MockData.richLinkMessage(), item: MockData.richLinkItem) { _ in }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
