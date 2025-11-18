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

struct BottomSheetButton: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
    
        enum Sizing {
            static let contentMinHeight: CGFloat = 56
            static let imageMinDimension: CGFloat = 32
        }
        enum Spacing {
            static let contentVertical: CGFloat = 0
            static let imageTitleHorizontal: CGFloat = 12
        }
        enum Padding {
            static let imageVertical: CGFloat = 12
            static let imageTitleHorizontal: CGFloat = 12
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let image: Image
    let label: String
    let role: ButtonRole?
    let isDividerVisible: Bool
    let action: () -> Void
    
    // MARK: - Init
    
    init(image: Image, label: String, role: ButtonRole? = nil, isDividerVisible: Bool = true, action: @escaping () -> Void) {
        self.image = image
        self.label = label
        self.role = role
        self.isDividerVisible = isDividerVisible
        self.action = action
    }
    
    // MARK: - Builder
    
    var body: some View {
        Button(role: role, action: action) {
            VStack(spacing: Constants.Spacing.contentVertical) {
                HStack(spacing: Constants.Spacing.imageTitleHorizontal) {
                    image
                        .frame(minWidth: Constants.Sizing.imageMinDimension, minHeight: Constants.Sizing.imageMinDimension)
                        .padding(.vertical, Constants.Padding.imageVertical)
                    
                    Text(label)
                       
                    Spacer()
                }
                .font(.body.weight(.medium))
                .padding(.horizontal, Constants.Padding.imageTitleHorizontal)
                
                if isDividerVisible {
                    ColoredDivider(colors.border.default)
                }
            }
            .frame(minHeight: Constants.Sizing.contentMinHeight)
        }
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 0) {
        BottomSheetButton(image: Image(systemName: "bubble.left.and.text.bubble.right"), label: "Start a new chat") { }
            .foregroundStyle(.blue)
        
        BottomSheetButton(image: Image(systemName: "arrow.left"), label: "Back to conversation") { }
            .foregroundStyle(.blue)
        
        BottomSheetButton(image: Image(systemName: "xmark"), label: "Close chat", isDividerVisible: false) { }
            .foregroundStyle(.gray)
    }
    .environmentObject(ChatStyle())
}
