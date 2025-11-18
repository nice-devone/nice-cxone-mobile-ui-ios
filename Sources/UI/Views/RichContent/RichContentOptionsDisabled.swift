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

struct RichContentOptionsDisabled: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let iconToTextHorizontal: CGFloat = 8
        }
        enum Padding {
            static let tooltipContentHorizontal: CGFloat = 12
            static let tooltipContentVertical: CGFloat = 8
            static let legacyTooltipContentVertical: CGFloat = 12
            static let legacyTooltipContentHorizontal: CGFloat = 16
        }
        enum Colors {
            static let textOpacity: Double = 0.5
        }
        enum Size {
            static let legacyTooltipContentWidth: CGFloat = UIScreen.main.bounds.width - Constants.Padding.legacyTooltipContentHorizontal * 2
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var showTooltip = false
    @State private var tooltipTextHeight: CGFloat = 0
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.iconToTextHorizontal) {
            Button {
                withAnimation {
                    showTooltip = true
                }
            } label: {
                HStack(spacing: Constants.Spacing.iconToTextHorizontal) {
                    Asset.Message.tooltip
                        .foregroundColor(colors.status.error)
                    
                    Text(localization.chatMessageRichContentOptionsDisabled)
                        .font(.caption)
                        .foregroundColor(colors.status.error)
                }
                .adaptiveTooltip(isPresented: $showTooltip) {
                    if #available(iOS 16.4, *) {
                        tooltipText
                            .readSize { size in
                                tooltipTextHeight = size.height
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(height: tooltipTextHeight)
                            .padding(.vertical, Constants.Padding.tooltipContentVertical)
                            .presentationCompactAdaptation(.none)
                    } else {
                        tooltipText
                            .frame(width: Constants.Size.legacyTooltipContentWidth)
                            .padding(.vertical, Constants.Padding.legacyTooltipContentVertical)
                    }
                }
                .adjustForA11y()
            }
        }
    }
}

// MARK: - Subviews

private extension RichContentOptionsDisabled {

    var tooltipText: some View {
        Text(localization.chatMessageRichContentOptionsDisabledTooltip)
            .foregroundStyle(colors.content.primary)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, Constants.Padding.tooltipContentHorizontal)
    }
}

// MARK: - Previews

#Preview {
    RichContentOptionsDisabled()
        .environmentObject(ChatLocalization())
        .environmentObject(ChatStyle())
}
