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
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    private static let spacingOptionSelected: CGFloat = 4
    private static let paddingVerticalOptionSelected: CGFloat = 4
    private static let paddingHorizontalOptionSelected: CGFloat = 6
    private static let cornerRadiusOptionSelected: CGFloat = 16
    private static let strokeWidthOptionSelected: CGFloat = 1
    private static let optionSelectedBottomPadding: CGFloat = 20
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Self.spacingOptionSelected) {
            Asset.check
                .padding(.vertical, Self.paddingVerticalOptionSelected)
                .padding(.horizontal, Self.paddingHorizontalOptionSelected)
                .background(
                    RoundedRectangle(cornerRadius: Self.cornerRadiusOptionSelected)
                        .stroke(lineWidth: Self.strokeWidthOptionSelected)
                )
            
            Text(localization.chatMessageRichContentOptionSelected)
        }
        .font(.caption)
        .padding(.bottom, Self.optionSelectedBottomPadding)
        .foregroundStyle(colors.customizable.onBackground.opacity(0.5))
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    RichContentOptionSelected()
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
}

#Preview("Dark Mode") {
    RichContentOptionSelected()
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
        .preferredColorScheme(.dark)
}
