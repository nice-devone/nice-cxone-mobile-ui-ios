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

struct RichContentOptionSelected: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let iconToTextHorizontal: CGFloat = 8
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.iconToTextHorizontal) {
            Asset.check
                .foregroundColor(colors.brand.primary)
            
            Text(localization.chatMessageRichContentOptionSelected)
                .font(.caption)
                .foregroundColor(colors.brand.primary)
        }
    }
}

// MARK: - Previews

#Preview {
    RichContentOptionSelected()
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
}
