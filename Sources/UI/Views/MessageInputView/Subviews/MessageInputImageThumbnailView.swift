//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Kingfisher
import SwiftUI

struct MessageInputImageThumbnailView: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var loadedImage: UIImage?
    
    let url: URL

    private let displayMode: AttachmentThumbnailDisplayMode = .small
    
    // MARK: - Builder
    
    var body: some View {
        Group {
            if let image = loadedImage {
                Image(uiImage: image) // swiftlint:disable:this accessibility_label_for_image
                    .resizable()
                    .scaledToFill()
            } else {
                KFImage(url)
                    .onSuccess { result in
                        loadedImage = result.image
                    }
                    .placeholder {
                        AttachmentLoadingView(
                            width: displayMode.size.width,
                            height: displayMode.size.width
                        )
                    }
                    .resizable()
            }
        }
        .frame(width: displayMode.size.width, height: displayMode.size.height)
        .clipShape(.rect(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius))
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius)
                .fill(colors.background.default)
        )
    }
}

// MARK: - Preview

#Preview {
    MessageInputImageThumbnailView(url: MockData.imageUrl())
        .environmentObject(ChatStyle())
}
