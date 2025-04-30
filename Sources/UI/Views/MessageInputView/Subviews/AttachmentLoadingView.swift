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
    
    // MARK: - Properties
    
    let title: String
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    static private let minimumScaleFactor: CGFloat = 0.5
    static private let verticalPadding: CGFloat = 10.0
    
    // MARK: Builder

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: StyleGuide.Attachment.cornerRadius)
                .fill(colors.background.muted)
            
            ProgressView {
                Text(title)
            }
            .progressViewStyle(CircularProgressViewStyle(tint: colors.foreground.base))
            .foregroundColor(colors.foreground.base)
            .minimumScaleFactor(Self.minimumScaleFactor)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(.vertical, Self.verticalPadding)
        }
    }
}

// MARK: - Previews

#Preview("Regular") {
    AttachmentLoadingView(title: "Regular")
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
        .frame(width: StyleGuide.Attachment.regularDimension, height: StyleGuide.Attachment.regularDimension)
}

#Preview("Large") {
    AttachmentLoadingView(title: "Large")
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
        .frame(width: StyleGuide.Attachment.largeDimension, height: StyleGuide.Attachment.largeDimension)
}

#Preview("Xtra Large") {
    AttachmentLoadingView(title: "Xtra Large")
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
        .frame(width: StyleGuide.Attachment.xtraLargeWidth, height: StyleGuide.Attachment.xtraLargeHeight)
}
