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

struct AttachmentLoadingView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let titleMinimumScaleFactor: CGFloat = 0.5
            static let progressTextLineLimit = 2
        }
        
        enum Padding {
            static let progressVertical: CGFloat = 10
        }
    }
    
    // MARK: - Properties
    
    let title: String
    let width: CGFloat
    let height: CGFloat
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    // MARK: Builder

    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: colors.content.primary))
            
            Text(title)
                .font(.subheadline)
        }
        .foregroundStyle(colors.content.primary)
        .lineLimit(Constants.Sizing.progressTextLineLimit)
        .minimumScaleFactor(Constants.Sizing.titleMinimumScaleFactor)
        .multilineTextAlignment(.center)
        .padding(.vertical, Constants.Padding.progressVertical)
        .padding(.horizontal, Constants.Padding.progressVertical)
        .frame(width: width, height: height)
        .background {
            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                .stroke(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                .background(
                    RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                        .fill(colors.background.default)
                )
        }
    }
}

// MARK: - Previews

#Preview("Small") {
    AttachmentLoadingView(
        title: "Loading document",
        width: StyleGuide.Sizing.Attachment.smallDimension,
        height: StyleGuide.Sizing.Attachment.smallDimension
    )
    .environmentObject(ChatStyle())
}

#Preview("Regular") {
    AttachmentLoadingView(
        title: "Regular",
        width: StyleGuide.Sizing.Attachment.regularDimension,
        height: StyleGuide.Sizing.Attachment.regularDimension
    )
    .environmentObject(ChatStyle())
}

#Preview("Large") {
    AttachmentLoadingView(
        title: "Large",
        width: StyleGuide.Sizing.Attachment.largeWidth,
        height: StyleGuide.Sizing.Attachment.largeHeight
    )
    .environmentObject(ChatStyle())
}
