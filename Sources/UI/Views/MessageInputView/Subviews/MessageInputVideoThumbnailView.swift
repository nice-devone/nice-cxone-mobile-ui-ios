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
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Colors {
            static let playButtonOverlay: Double = 0.8
            static let playButtonBackgroundOverlay: Double = 0.7
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let url: URL?
    let displayMode: AttachmentThumbnailDisplayMode
    
    // MARK: - Init
    
    init(url: URL?, displayMode: AttachmentThumbnailDisplayMode) {
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
                    .frame(width: displayMode.size.width, height: displayMode.size.height)
                    .clipped()
                    .overlay(
                        Asset.Attachment.playButtonSymbol
                            .font(displayMode.font)
                            .foregroundStyle(
                                Asset.Colors.Base.black.swiftUIColor.opacity(Constants.Colors.playButtonBackgroundOverlay),
                                Asset.Colors.Base.white.swiftUIColor.opacity(Constants.Colors.playButtonOverlay)
                            )
                    )
                    .cornerRadius(StyleGuide.Sizing.Attachment.cornerRadius)
            } else {
                RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
            }
        }
        .frame(width: displayMode.size.width, height: displayMode.size.height)
    }
}

// MARK: - Preview

private struct PreviewHelper: View {
    
    let title: String
    let displayMode: AttachmentThumbnailDisplayMode
    
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

        PreviewHelper(title: "Tap on more that 4 attachments", displayMode: .regular)
        
        PreviewHelper(title: "Standalone Video Attachment", displayMode: .large)
    }
}
