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

extension Image {
    /// Resizes an image to a fixed size while maintaining its aspect ratio.
    /// - Parameters:
    ///   - width: The desired width of the image
    ///   - height: The desired height of the image
    /// - Returns: A View with the image resized to the specified dimensions while preserving aspect ratio
    func fixedSize(width: CGFloat, height: CGFloat) -> some View {
        self
            .resizable()
            .frame(width: width, height: height)
            .scaledToFit()
    }
}
