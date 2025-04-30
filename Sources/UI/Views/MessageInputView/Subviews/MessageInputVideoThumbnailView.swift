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

struct VideoThumbnailView: View, Themed {
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let url: URL?
    let displayMode: VideoThumbnailDisplayMode
    
    // MARK: - Init
    
    init(
        url: URL?,
        displayMode: VideoThumbnailDisplayMode
    ) {
        self.url = url
        self.displayMode = displayMode
    }
    
    // MARK: - Builder

    var body: some View {
        Group {
            if let thumbnail = url?.getVideoThumbnail() {
                thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: displayMode.width, height: displayMode.height)
                    .clipped()
                    .overlay(
                        Asset.Attachment.playButtonSymbol
                            .font(.system(size: displayMode.fontSize))
                            .foregroundStyle(
                                colors.foreground.staticDark,
                                colors.foreground.staticLight.opacity(0.8)
                            )
                    )
                    .cornerRadius(StyleGuide.Attachment.cornerRadius)
            } else {
                RoundedRectangle(cornerRadius: StyleGuide.Attachment.cornerRadius)
            }
        }
        .frame(width: displayMode.width, height: displayMode.height)
    }
}

// MARK: - Preview

struct PreviewHelper: View {
    
    let title: String
    let displayMode: VideoThumbnailDisplayMode
    
    var body: some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            VideoThumbnailView(url: MockData.videoUrl, displayMode: displayMode)
                .environmentObject(ChatStyle())
        }
    }
}

#Preview {
    List {
        PreviewHelper(title: "Above Input Field", displayMode: .small)
        
        PreviewHelper(title: "Multiple Attachment Container", displayMode: .multipleContainer)

        PreviewHelper(title: "Tap on more that 4 attachments", displayMode: .attachmentsOverflow)
        
        PreviewHelper(title: "Standalone Video Attachment", displayMode: .large)
    }
}
