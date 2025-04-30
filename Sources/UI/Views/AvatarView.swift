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

struct AvatarView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let imageUrl: URL?
    let initials: String?
    
    // MARK: - Builder
    
    var body: some View {
        AsyncImage(url: imageUrl) { image in
            image
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
        } placeholder: {
            // Don't show initials if avatar image is loading
            CircleText(text: imageUrl != nil ? nil : initials)
        }
    }
}

// MARK: - Helper Views

private struct CircleText: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var size = CGSize()
    
    let text: String?
    
    // MARK: - Builder
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colors.customizable.accent)
            
            Group {
                if let text {
                    Text(text)
                } else {
                    Asset.Message.fallbackAvatar
                }
            }
            .foregroundStyle(colors.customizable.onAccent)
            .font(
                .system(size: $size.height.wrappedValue > $size.width.wrappedValue ? $size.width.wrappedValue * 0.4: $size.height.wrappedValue * 0.4)
                .bold()
            )
            .lineLimit(1)
        }
        .readSize { size in
            self.size = size
        }
    }
}

// MARK: - Previews

private struct TestPreviewView<Content: View>: View {
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 60)
                .fill(Color.accentColor)
                .frame(width: UIScreen.main.bounds.width, height: 150)
            
            content()
                .frame(width: 72, height: 72)
                .offset(x: -36, y: 36)
        }
        .offset(x: UIScreen.main.bounds.width / 3)
    }
}

#Preview {
    VStack(spacing: 24) {
        TestPreviewView {
            AvatarView(imageUrl: MockData.imageUrl, initials: nil)
        }
        
        TestPreviewView {
            AvatarView(imageUrl: MockData.imageUrl, initials: "PP")
        }
        
        TestPreviewView {
            AvatarView(imageUrl: nil, initials: "PP")
        }
        
        TestPreviewView {
            AvatarView(imageUrl: nil, initials: nil)
        }
    }
    .environmentObject(ChatStyle())
}
