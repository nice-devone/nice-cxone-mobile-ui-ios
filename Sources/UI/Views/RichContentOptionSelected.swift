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

import SwiftUI

struct RichContentOptionSelected: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let iconToTextHorizontal: CGFloat = 8
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.iconToTextHorizontal) {
            Asset.check
                .foregroundStyle(colors.brand.primary)
                .accessibilityHidden(true)

            Text(L10n.Chat.Message.RichContent.optionSelected)
                .font(.caption)
                .foregroundStyle(colors.brand.primary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.OptionSelected.identifier)
        .accessibilityLabel(L10n.Chat.Message.RichContent.optionSelected)
        .accessibilityHint(A11y.Conversation.MessageCell.OptionSelected.hint)
    }
}

// MARK: - Previews

#Preview {
    RichContentOptionSelected()
        .environmentObject(ChatStyle())
}
