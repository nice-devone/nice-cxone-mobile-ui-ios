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

struct BottomSheetView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        static let backgroundAnimationDelay: Double = 0.18
        
        enum Sizing {
            static let contentTopCornerRadius: CGFloat = 28
        }
        enum Padding {
            static let contentTop: CGFloat = 32
            static let contentBottom: CGFloat = 40
        }
        enum Colors {
            static let backgroundOpacity: Double = 0.5
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var isVisible = false
    
    @ViewBuilder var content: () -> any View
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(isVisible ? Constants.Colors.backgroundOpacity : .zero)
                .animation(.spring().delay(Constants.backgroundAnimationDelay), value: isVisible)
            
            AnyView(content())
                .padding(.top, Constants.Padding.contentTop)
                .padding(.bottom, Constants.Padding.contentBottom)
                .background(
                    Rectangle()
                        .fill(colors.background.surface.subtle)
                )
                .cornerRadius(Constants.Sizing.contentTopCornerRadius, corners: [.topLeft, .topRight])
        }
        .ignoresSafeArea()
        .presentationWithBackgroundColor(.clear)
        .onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
    }
}

// MARK: - Previews

private struct TestContentView: View {
    
    var body: some View {
        VStack(spacing: 2) {
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.agent),
                messageGroupPosition: .first,
                isLast: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.agent),
                messageGroupPosition: .last,
                isLast: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .first,
                isLast: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .inside,
                isLast: .constant(false),
                alertType: .constant(nil)
            ) { _, _ in }
            
            ChatMessageCell(
                message: MockData.textMessage(user: MockData.customer),
                messageGroupPosition: .last,
                isLast: .constant(true),
                alertType: .constant(nil)
            ) { _, _ in }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Navigation")
    }
}

#Preview {
    NavigationView {
        TestContentView()
    }
    .fullScreenCover(isPresented: .constant(true)) {
        BottomSheetView {
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text("Time is up")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.black)
                        
                        Text("This conversation will now end due to inactivity")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer(minLength: 8)
                    
                    Image(systemName: "hourglass")
                        .font(.title2)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.yellow)
                        )
                }
                .padding(.horizontal, 24)
                
                HStack(spacing: 12) {
                    Image(systemName: "xmark")
                    
                    Text("Close chat")
                    
                    Spacer()
                }
                .adjustForA11y()
                .foregroundStyle(.gray)
                .padding(.horizontal, 16)
            }
        }
    }
    .environmentObject(ChatStyle())
}
