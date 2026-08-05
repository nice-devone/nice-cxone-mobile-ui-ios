//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import SwiftUI

struct ChatLoadingOverlay: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        // Websocket event response timeout is set to 10 seconds so 20 seconds should be fine
        static let cancelDelay: TimeInterval = 20
        
        enum Sizing {
            static let progressScaleEffect: CGFloat = 1.2
        }
        
        enum Spacing {
            static let contentVertical: CGFloat = 16
            static let progressTextVertical: CGFloat = 8
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @State private var isCancelVisible = false

    let text: String
    let onCancel: () -> Void

    // MARK: - Builder
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                .ignoresSafeArea(.all)
                .accessibilityHidden(true)

            VStack(spacing: Constants.Spacing.contentVertical) {
                VStack(spacing: Constants.Spacing.progressTextVertical) {
                    ProgressView()
                        .scaleEffect(Constants.Sizing.progressScaleEffect)
                        .tint(colors.content.secondary)

                    Text(text)
                        .font(.title3)
                        .foregroundStyle(colors.content.secondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(A11y.ChatOverlay.Loading.ProgressView.label)

                if isCancelVisible {
                    Text(L10n.Overlay.LoadingDelay.title)
                        .foregroundStyle(colors.content.secondary)

                    Button(L10n.Common.closeChat, action: onCancel)
                        .buttonStyle(.destructive)
                        .accessibilityIdentifier(A11y.ChatOverlay.Loading.ButtonDelay.identifier)
                        .accessibilityHint(A11y.ChatOverlay.Loading.ButtonDelay.hint)
                }
            }
        }
        .task { @MainActor in
            await Task.sleep(seconds: Constants.cancelDelay)

            // The project's `Task.sleep(seconds:)` swallows `CancellationError`, so we have to
            // re-check cancellation explicitly before mutating state on a disappearing view.
            guard !Task.isCancelled else {
                return
            }

            isCancelVisible = true
        }
        .animation(.easeIn, value: isCancelVisible)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Preview

private struct TestContentView: View {
    
    var body: some View {
        VStack(spacing: 2) {
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.agent),
                messageGroupPosition: .first,
                isLast: .constant(false),
                alertType: .constant(nil)
            ) { _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.agent),
                messageGroupPosition: .last,
                isLast: .constant(false),
                alertType: .constant(nil)
            ) { _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .first,
                isLast: .constant(false),
                alertType: .constant(nil)
            ) { _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .inside,
                isLast: .constant(false),
                alertType: .constant(nil)
            ) { _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .last,
                isLast: .constant(true),
                alertType: .constant(nil)
            ) { _ in }
            
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
        NavigationStack {
            TestContentView()
        }
        
        if isPresented {
            ChatLoadingOverlay(text: "Connecting...") {
                isPresented = false
            }
        }
    }
    .environmentObject(ChatStyle())
}
