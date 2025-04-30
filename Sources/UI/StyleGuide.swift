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

enum StyleGuide {
    static let buttonSmallerDimension: CGFloat = 32
    static let buttonDimension: CGFloat = 44
    
    // nav bar is typically 44 points + 20 points for sheet inset + 32 points for positioning
    static let containerVerticalOffset: CGFloat = 96

    enum Attachment {
        static let regularDimension: CGFloat = 72
        static let largeDimension: CGFloat = 112
        static let xtraLargeHeight: CGFloat = 319
        static let xtraLargeWidth: CGFloat = 242
        static let cornerRadius: CGFloat = 10
    }
    
    enum Message {
        static let cornerRadius: CGFloat = 20
        static let paddingVertical: CGFloat = 14
        static let paddingHorizontal: CGFloat = 12
        static let groupCellSpacing: CGFloat = 2
    }
}
