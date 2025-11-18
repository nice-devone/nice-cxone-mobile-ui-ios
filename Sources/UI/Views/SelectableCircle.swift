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

struct SelectableCircle: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let strokeWidth: CGFloat = 3
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme: ColorScheme
    
    var isSelected: Bool

    // MARK: - Builder

    var body: some View {
        Asset.checkCircleFill
            .font(.subheadline)
            .foregroundStyle(colors.brand.onPrimary, colors.brand.primary)
            .opacity(isSelected ? 1 : 0)
            .overlay {
                Circle()
                    .stroke(colors.border.default, lineWidth: Constants.Sizing.strokeWidth)
            }
            .accessibilityIdentifier(isSelected ? "attachment_selected_indicator" : "attachment_unselected_indicator")
    }
}

// MARK: - Preview

#Preview {
    HStack {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.green)
                .frame(width: 150, height: 150)
            
            SelectableCircle(isSelected: true)
                .padding(8)
        }
        
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.green)
                .frame(width: 150, height: 150)
            
            SelectableCircle(isSelected: false)
                .padding(8)
        }
    }
    .environmentObject(ChatStyle())
}
