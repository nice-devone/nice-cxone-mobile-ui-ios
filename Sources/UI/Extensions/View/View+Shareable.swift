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

extension View {
    
    func shareable(_ message: ChatMessage, attachments: [AttachmentItem], spacerLength: CGFloat) -> some View {
        modifier(ShareableModifier(message: message, attachments: attachments, spacerLength: spacerLength))
    }
}

// MARK: - ShareableModifier

private struct ShareableModifier: ViewModifier, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let shareButtonStrokeWidth: CGFloat = 1
        }
        
        enum Spacing {
            static let contentHorizontal: CGFloat = 16
            static let shareButtonOffset: CGFloat = -1
        }
        
        enum Padding {
            static let icon: CGFloat = 8
        }
    }
    
    // MARK: - Properties

    @State private var showShareSheet = false

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let message: ChatMessage
    let attachments: [AttachmentItem]
    let spacerLength: CGFloat
    
    // MARK: - Builder
    
    func body(content: Content) -> some View {
        HStack(spacing: Constants.Spacing.contentHorizontal) {
            if !message.isUserAgent {
                Spacer(minLength: spacerLength)
                
                shareButton
            }
            
            content

            if message.isUserAgent {
                shareButton
                
                Spacer(minLength: spacerLength)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: attachments.map(\.url))
        }
    }
}

// MARK: - Subviews

private extension ShareableModifier {
    
    var shareButton: some View {
        Button {
            showShareSheet = true
        } label: {
            Asset.share
                .font(.subheadline.bold())
                .foregroundStyle(colors.brand.primary)
                .offset(y: Constants.Spacing.shareButtonOffset)
        }
        .padding(Constants.Padding.icon)
        .background(
            Circle()
                .strokeBorder(colors.border.default, lineWidth: Constants.Sizing.shareButtonStrokeWidth)
                .background(
                    Circle()
                        .fill(colors.background.surface.default)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 4) {
        ImageMessageCell(
            message: MockData.imageMessage(user: MockData.agent),
            item: MockData.imageItem,
            position: .single,
            alertType: .constant(nil),
            localization: ChatLocalization()
        )
        
        ImageMessageCell(
            message: MockData.imageMessage(user: MockData.customer),
            item: MockData.imageItem,
            position: .single,
            alertType: .constant(nil),
            localization: ChatLocalization()
        )
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
