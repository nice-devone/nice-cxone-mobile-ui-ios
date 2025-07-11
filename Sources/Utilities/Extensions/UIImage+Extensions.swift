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

import UIKit

extension UIImage {
    /// Fixes the orientation of an image to be up, addressing issues with camera images
    /// 
    /// When capturing images from the camera, especially on iOS 15, the image's orientation 
    /// metadata may not be correctly interpreted by image display APIs like Kingfisher and AsyncImage.
    /// Instead of displaying correctly, these images can appear rotated, flipped, or both.
    ///
    /// This method creates a new image with the correct orientation by:
    /// 1. Checking if the orientation already matches the display orientation (up)
    /// 2. If not, applying geometric transformations (rotations, flips) to normalize the orientation
    /// 3. Creating a new CGImage with the correct orientation and geometry
    ///
    /// This is particularly critical for iOS 15 compatibility where image orientation from cameras
    /// isn't automatically handled by image display components like it is in iOS 16+.
    ///
    /// - Returns: A new UIImage with the orientation set to up
    func fixOrientation() -> UIImage {
        // Return the image as-is if orientation is already up
        if self.imageOrientation == .up {
            return self
        }
        
        // Ensure we have a valid CGImage
        guard let cgImage = self.cgImage else {
            return self
        }
        
        // Create and configure the transform for orientation correction
        let transform = createOrientationTransform()
        
        // Create a drawing context with correct parameters
        guard let ctx = createDrawingContext(for: cgImage) else {
            return self
        }
        
        // Apply transform and draw the image with proper dimensions
        drawOrientedImage(in: ctx, with: cgImage, using: transform)
        
        // Create and return the new image, or return original if creation fails
        if let finalCGImage = ctx.makeImage() {
            return UIImage(cgImage: finalCGImage)
        }
        
        return self
    }
    
    // MARK: - Helper Methods
    
    /// Creates a transformation matrix to correct image orientation
    private func createOrientationTransform() -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        
        // Apply required rotation based on orientation
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }
        
        // Apply mirroring if needed
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        return transform
    }
    
    /// Creates a CGContext for drawing the properly oriented image
    private func createDrawingContext(for cgImage: CGImage) -> CGContext? {
        // Get color space (use device RGB if nil)
        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        
        return CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )
    }
    
    /// Draws the image in the context with the appropriate orientation
    private func drawOrientedImage(in context: CGContext, with cgImage: CGImage, using transform: CGAffineTransform) {
        // Apply the transformation
        context.concatenate(transform)
        
        // Determine appropriate drawing rectangle based on orientation
        let drawRect: CGRect
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawRect = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
        default:
            drawRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        }
        
        // Draw the image
        context.draw(cgImage, in: drawRect)
    }
}
