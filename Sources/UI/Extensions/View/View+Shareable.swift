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

    // MARK: - Properties

    @State private var showShareSheet = false

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let message: ChatMessage
    let attachments: [AttachmentItem]
    let spacerLength: CGFloat
    
    private static let shareableHorizontalSpacing: CGFloat = 12
    private static let iconPadding: CGFloat = 10
    
    // MARK: - Builder
    
    func body(content: Content) -> some View {
        HStack(spacing: Self.shareableHorizontalSpacing) {
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
                .foregroundStyle(colors.customizable.primary)
                .offset(y: -1)
        }
        .padding(Self.iconPadding)
        .background(
            ZStack {
                Circle()
                    .stroke(colors.customizable.onBackground)
                    .opacity(0.10)
                
                Circle()
                    .fill(colors.customizable.onBackground)
                    .opacity(0.05)
            }
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 4) {
        ImageMessageCell(
            message: MockData.imageMessage(user: MockData.agent),
            item: MockData.imageItem,
            isMultiAttachment: false,
            position: .single,
            alertType: .constant(nil),
            localization: ChatLocalization()
        )
        
        ImageMessageCell(
            message: MockData.imageMessage(user: MockData.customer),
            item: MockData.imageItem,
            isMultiAttachment: false,
            position: .single,
            alertType: .constant(nil),
            localization: ChatLocalization()
        )
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
