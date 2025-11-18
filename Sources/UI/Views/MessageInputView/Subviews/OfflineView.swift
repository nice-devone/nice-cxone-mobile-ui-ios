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

struct OfflineView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let headerCornerRadius: CGFloat = 16
            static let headerIconDimension: CGFloat = 34
            static let imageWidthScale: Double = 1.5
        }
        enum Spacing {
            static let headerContent: CGFloat = 16
        }
        enum Padding {
            static let content: CGFloat = 16
            static let headerContent: CGFloat = 16
            static let headerIcon: CGFloat = 12
            static let buttonHorizontal: CGFloat = 32
        }
    }
    // MARK: - Properties
    
    @Environment(\.colorScheme) var scheme
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    let onButtonTap: () -> Void

    // MARK: - Builder
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                header
                
                Spacer()
                
                Asset.Images.offline.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width / Constants.Sizing.imageWidthScale)
                
                Spacer()
                
                Button(role: .destructive, action: onButtonTap) {
                    Text(localization.commonCloseChat)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.destructive)
                .padding(.horizontal, Constants.Padding.buttonHorizontal)
            }
            .background(colors.background.default)
            .padding(Constants.Padding.content)
        }
    }
}

// MARK: - Subviews

private extension OfflineView {
    
    var header: some View {
        HStack(spacing: Constants.Spacing.headerContent) {
            Asset.Images.clockBadgeZzz.swiftUIImage
                .renderingMode(.template)
                .frame(width: Constants.Sizing.headerIconDimension, height: Constants.Sizing.headerIconDimension)
                .padding(Constants.Padding.headerIcon)
                .foregroundStyle(colors.status.onError)
                .background {
                    Circle()
                        .fill(colors.status.error)
                }
            
            VStack(alignment: .leading) {
                Text(localization.liveChatOfflineTitle)
                    .fontWeight(.medium)
                    .foregroundStyle(colors.content.primary)
                
                Text(localization.liveChatOfflineMessage)
                    .font(.subheadline)
                    .foregroundStyle(colors.content.secondary)
            }
            .multilineTextAlignment(.leading)
        }
        .padding(Constants.Padding.headerContent)
         .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Constants.Sizing.headerCornerRadius)
                .fill(colors.status.errorContainer)
        )
    }
}

// MARK: - Previews

#Preview("Modal") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            OfflineView { }
        }
        .interactiveDismissDisabled()
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}

#Preview("Full-screen") {
    OfflineView { }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
