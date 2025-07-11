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

struct ChatDefaultOverlayPreview<Content: View>: View {
    
    // MARK: - Properties
    
    let content: () -> Content
    
    // MARK: - Builder
    
    var body: some View {
        NavigationView {
            viewContent
                .fullScreenCover(isPresented: .constant(true)) {
                    ChatDefaultOverlay(verticalOffset: StyleGuide.containerVerticalOffset, content)
                        .presentationWithBackgroundColor(.clear)
                }
                .navigationTitle("John Doe")
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
    
    private var viewContent: some View {
        LazyVStack(spacing: 2) {
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.agent),
                messageGroupPosition: .first,
                isProcessDialogVisible: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.agent),
                messageGroupPosition: .last,
                isProcessDialogVisible: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .first,
                isProcessDialogVisible: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .inside,
                isProcessDialogVisible: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .last,
                isProcessDialogVisible: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    ChatDefaultOverlayPreview {
        VStack(alignment: .center) {
            ProgressView()
            
            Text(ChatLocalization().alertGenericErrorMessage)
        }
        .padding()
    }
}
