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

struct ChatLoadingOverlay: View, Themed {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    let text: String
    
    // MARK: - Init

    init(text: String) {
        self.text = text
    }

    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .ignoresSafeArea(.all)
            
            ProgressView {
                Text(text)
                    .foregroundStyle(colors.customizable.onBackground.opacity(0.5))
            }
            .scaleEffect(1.2)
            .tint(colors.customizable.onBackground.opacity(0.5))
        }
    }
}

// MARK: - Previews

private struct TestContentView: View {
    
    var body: some View {
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
        .navigationTitle("Navigation")
    }
}

#Preview {
    ZStack {
        NavigationView {
            TestContentView()
        }

        ChatLoadingOverlay(text: "Connecting...")
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
