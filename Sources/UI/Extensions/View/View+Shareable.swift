//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

private struct ShareableModifier: ViewModifier {

    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @State private var showShareSheet = false
    
    let message: ChatMessage
    let attachments: [AttachmentItem]
    let spacerLength: CGFloat
    
    // MARK: - Builder
    
    func body(content: Content) -> some View {
        HStack {
            if !message.user.isAgent {
                Spacer(minLength: spacerLength)
                
                shareButton
            }
            
            content
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: attachments.map(\.url))
                }

            if message.user.isAgent {
                shareButton
                
                Spacer(minLength: spacerLength)
            }
        }
    }
}

// MARK: - Subviews

private extension ShareableModifier {
    
    var shareButton: some View {
        Button(
            action: {
                showShareSheet = true
            }, label: {
                Asset.share
                    .imageScale(.small)
                    .foregroundColor(style.backgroundColor)
                    .offset(y: -1)
            }
        )
        .padding(6)
        .background(
            Circle()
                .fill(style.backgroundColor.opacity(0.5))
                .colorInvert()
        )
    }
}

// MARK: - Preview

struct ShareableView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            VStack(spacing: 4) {
                ImageMessageCell(message: MockData.imageMessage(user: MockData.agent), item: MockData.imageItem, isMultiAttachment: false)
                ImageMessageCell(message: MockData.imageMessage(user: MockData.customer), item: MockData.imageItem, isMultiAttachment: false)
            }
            .previewDisplayName("Light Mode")
            
            VStack(spacing: 4) {
                ImageMessageCell(message: MockData.imageMessage(user: MockData.agent), item: MockData.imageItem, isMultiAttachment: false)

                ImageMessageCell(message: MockData.imageMessage(user: MockData.customer), item: MockData.imageItem, isMultiAttachment: false)
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
