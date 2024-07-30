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

struct VideoThumbnailView: View {
    
    // MARK: - Properties
    
    let videoURL: URL
    private let width: CGFloat = 50
    private let height: CGFloat = 50
    private let cornerRadius: CGFloat = 8.0
    
    var body: some View {
        ZStack {
            thumbnail
                .frame(width: width, height: height)
                .cornerRadius(cornerRadius)
            
            Image(systemName: "video.fill")
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private var thumbnail: some View {
        if let thumbnailImage = videoURL.getVideoThumbnail(maximumSize: CGSize(width: width, height: height)) {
            thumbnailImage
                .resizable()
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray)
        }
    }
}
