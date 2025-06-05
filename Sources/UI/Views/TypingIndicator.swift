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

struct TypingIndicator: View, Themed {
    
    // MARK: - Properties

    @Environment(\.colorScheme) var scheme

    @EnvironmentObject var style: ChatStyle

    @State private var ballState = [CGFloat](repeating: 0.0, count: Self.ballCount)

    private static let animationTime = 0.125
    private static let ballCount = 3
    private static let ballSize: CGFloat = 8
    private static let containerSpacing: CGFloat = 4
    private static let horizontalPadding: CGFloat = 12
    private static let verticalPadding: CGFloat = 16
    private static let offset: CGFloat = 6.0
    private static let repeatDelay = 0.5
    private static let ballOpacity = 0.5
    
    let agent: ChatUser?
    
    private static let avatarDimension: CGFloat = 24
    private static let avatarXOffset: CGFloat = 12
    private static let avatarYOffset: CGFloat = 16
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .leading) {
            content
            
            if let agent {
                agentAvatar(agent)
            }
        }
        .task {
            await AnimationSequence(style: .easeInOut, duration: Self.animationTime)
                .append { ballState[0] = Self.offset }
                .append { ballState[1] = Self.offset }
                .append { ballState[2] = Self.offset }
                .append { ballState[0] = 0 }
                .append { ballState[1] = 0 }
                .append { ballState[2] = 0 }
                .repeat(delay: Self.repeatDelay)
        }
    }
}

// MARK: - Subviews

private extension TypingIndicator {

    var content: some View {
        HStack(spacing: Self.containerSpacing) {
            ForEach(ballState.indices, id: \.self) { index in
                ball(offset: ballState[index])
            }
        }
        .padding(.horizontal, Self.horizontalPadding)
        .padding(.vertical, Self.verticalPadding)
        .background(colors.customizable.agentBackground)
        .cornerRadius(StyleGuide.Message.cornerRadius, corners: .allCorners)
    }
    
    func agentAvatar(_ agent: ChatUser) -> some View {
        AvatarView(imageUrl: agent.avatarURL, initials: agent.initials)
            .frame(width: Self.avatarDimension, height: Self.avatarDimension)
            .offset(x: -Self.avatarXOffset, y: Self.avatarYOffset)
    }
}

// MARK: - Private Methods

private extension TypingIndicator {
    
    func ball(offset: CGFloat) -> some View {
        Circle()
            .frame(width: Self.ballSize, height: Self.ballSize)
            .foregroundColor(colors.customizable.agentText.opacity(Self.ballOpacity))
            .offset(y: -offset)
    }
}

// MARK: - Preview

struct TypingIndicator_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            TypingIndicator(agent: MockData.agent)
                .previewDisplayName("Light Mode")
            
            TypingIndicator(agent: MockData.agent)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatStyle())
    }
}
