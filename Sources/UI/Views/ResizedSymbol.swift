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

struct ResizedSymbol: View {
    
    // MARK: - Properties
    
    let scalingFactor: CGFloat = 0.95
    let image: Image
    let targetSize: CGFloat
    
    // MARK: - Init
    
    init(image: Image, targetSize: CGFloat) {
        self.image = image
        self.targetSize = targetSize
    }
    
    // MARK: - Content

    var body: some View {
        if #available(iOS 16.0, *) {
            return createiOS16Image()
        } else {
            return image
        }
    }
    
    // MARK: - Private Methods
    
    @available(iOS 16.0, *)
    private func createiOS16Image() -> some View {
        let size = CGSize(width: targetSize, height: targetSize)
        
        return Image(size: size) { ctx in
            let resolvedImage = ctx.resolve(image)
            let imageSize = resolvedImage.size
            
            // Calculate scale to fit within the target size while preserving aspect ratio
            let scale = min(
                targetSize / imageSize.width,
                targetSize / imageSize.height
            ) * scalingFactor // Apply a scaling factor to make it slightly smaller
            
            let scaledWidth = imageSize.width * scale
            let scaledHeight = imageSize.height * scale
            
            // Center the image
            let xcoord = (targetSize - scaledWidth) / 2
            let ycoord = (targetSize - scaledHeight) / 2
            
            ctx.draw(resolvedImage, in: CGRect(
                x: xcoord,
                y: ycoord,
                width: scaledWidth,
                height: scaledHeight
            ))
        }
    }
}
