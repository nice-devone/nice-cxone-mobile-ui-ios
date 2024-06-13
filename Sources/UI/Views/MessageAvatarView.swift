//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

import Kingfisher
import SwiftUI

struct MessageAvatarView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    let avatarUrl: URL?
    let initials: String
    
    // MARK: - Builder
    
    var body: some View {
        KFImage(avatarUrl)
            .placeholder {
                CircleText(initials, textColor: style.backgroundColor, backgroundColor: style.formTextColor)
            }
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
    }
}

// MARK: - Helper Views

private struct CircleText: View {
    
    let text: String
    let textColor: Color
    let backgroundColor: Color
    
    init(_ text: String, textColor: Color, backgroundColor: Color) {
        self.text = text
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(backgroundColor)
                
                Text(text)
                    .foregroundColor(textColor)
                    .font(.system(size: proxy.size.height > proxy.size.width ? proxy.size.width * 0.4: proxy.size.height * 0.4))
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Preview

struct MessageAvatarView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            VStack {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.accentColor)
                        .frame(width: 100, height: 50)
                    
                    MessageAvatarView(avatarUrl: MockData.imageUrl, initials: "PP")
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: -20, y: 8)
                        .padding(.leading, 8)
                }
                
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.accentColor)
                        .frame(width: 100, height: 50)
                    
                    MessageAvatarView(avatarUrl: nil, initials: "PP")
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: -20, y: 8)
                        .padding(.leading, 8)
                }
            }
            .previewDisplayName("Light Mode")
            
            VStack {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.accentColor)
                        .frame(width: 100, height: 50)
                    
                    MessageAvatarView(avatarUrl: MockData.imageUrl, initials: "PP")
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: -20, y: 8)
                        .padding(.leading, 8)
                }
                
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.accentColor)
                        .frame(width: 100, height: 50)
                    
                    MessageAvatarView(avatarUrl: nil, initials: "PP")
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: -20, y: 8)
                        .padding(.leading, 8)
                }
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatStyle())
    }
}
