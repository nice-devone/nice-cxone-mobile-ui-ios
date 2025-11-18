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

struct MessageCellTooltipView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let elementsHorizontal: CGFloat = 8
        }
        enum Padding {
            static let tooltipContentHorizontal: CGFloat = 16
            static let tooltipContentVertical: CGFloat = 16
            static let legacyTooltipContentVertical: CGFloat = 16
        }
        enum Colors {
            static let textOpacity: Double = 0.5
        }
        enum Size {
            static let legacyTooltipContentWidth: CGFloat = UIScreen.main.bounds.width - 16 * 2
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var showTooltip = false
    @State private var tooltipTextHeight: CGFloat = 0
    
    let text: String
    let tooltip: String
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.elementsHorizontal) {
            Button {
                withAnimation {
                    showTooltip = true
                }
            } label: {
                Asset.Message.tooltip
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
                    .accessibilityIdentifier("message_tooltip_icon")
            }
            .foregroundColor(colors.status.error)
            
            Text(text)
                .font(.caption)
                .foregroundColor(colors.status.error)
        }
    }
}

// MARK: - Subviews

private extension MessageCellTooltipView {

    var tooltipText: some View {
        Text(tooltip)
            .font(.callout)
            .foregroundColor(colors.content.primary)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, Constants.Padding.tooltipContentHorizontal)
    }
}

// MARK: - Previews

#Preview {
    MessageCellTooltipView(text: Lorem.words(nbWords: 3), tooltip: Lorem.sentences().joined(separator: " "))
        .environmentObject(ChatStyle())
}
