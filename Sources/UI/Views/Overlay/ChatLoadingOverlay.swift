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
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme

    @State private var isCancelVisible = false
    @State private var workItem: DispatchWorkItem?
    
    let text: String
    let onCancel: () -> Void
    
    /// Websocket event response timeout is set to 10 seconds so 20 seconds should be fine
    private static let cancelDelay: TimeInterval = 20
    private static let contentVerticalSpacing: CGFloat = 10
    private static let progressScaleEffect: CGFloat = 1.2

    // MARK: - Builder
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .ignoresSafeArea(.all)
            
            VStack(spacing: Self.contentVerticalSpacing) {
                ProgressView()
                    .scaleEffect(Self.progressScaleEffect)
                    .tint(colors.customizable.onBackground.opacity(0.5))
                
                Text(text)
                    .font(.title3)
                    .foregroundStyle(colors.customizable.onBackground.opacity(0.5))
                
                if isCancelVisible {
                    Text(localization.overlayLoadingDelayTitle)
                        .foregroundStyle(colors.customizable.onBackground.opacity(0.5))
                    
                    Button(localization.overlayLoadingDelayButtonTitle, action: onCancel)
                        .buttonStyle(.destructive)
                }
            }
        }
        .onAppear {
            let workItem = DispatchWorkItem {
                self.isCancelVisible = true
            }
            self.workItem = workItem
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.cancelDelay, execute: workItem)
        }
        .onDisappear {
            workItem?.cancel()
            workItem = nil
        }
        .animation(.easeIn, value: isCancelVisible)
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

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isPresented: Bool = true
    
    ZStack {
        NavigationView {
            TestContentView()
        }

        if isPresented {
            ChatLoadingOverlay(text: "Connecting...") {
                isPresented = false
            }
        }
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
