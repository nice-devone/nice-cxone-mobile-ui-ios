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
    
    // MARK: - Position
    
    enum AnimationStep {
        case first, second, third
    }
    
    // MARK: - Constants
    
    private enum Constants {
        
        static let animationTime = 0.125
        static let ballCount = 3
        static let repeatDelay = 0.5
        
        enum Sizing {
            static let ballSize: CGFloat = 8
            static let avatarDimension: CGFloat = 24
        }
        
        enum Spacing {
            static let containerHorizontal: CGFloat = 4
            static let ballOffset: CGFloat = 6.0
            static let avatarOffset: CGFloat = 12
        }
        
        enum Padding {
            static let containerHorizontal: CGFloat = 12
            static let containerVertical: CGFloat = 16
        }
        
        enum Colors {
            static let firstStateBallOpacity: Double = 0.6
            static let secondStateBallOpacity: Double = 0.4
            static let thirdStateBallOpacity: Double = 0.2
        }
    }
    
    // MARK: - Properties

    @Environment(\.colorScheme) var scheme

    @EnvironmentObject var style: ChatStyle

    @State private var ballState = [(AnimationStep)](repeating: .first, count: Constants.ballCount)
    
    let agent: ChatUser?
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            content
            
            if let agent {
                AvatarView(imageUrl: agent.avatarURL, initials: agent.initials)
                    .frame(width: Constants.Sizing.avatarDimension, height: Constants.Sizing.avatarDimension)
                    .offset(x: -Constants.Spacing.avatarOffset, y: Constants.Spacing.avatarOffset)
            }
        }
        .task {
            await AnimationSequence(style: .easeInOut, duration: Constants.animationTime)
                .append {
                    ballState[0] = .first
                }
                .append {
                    ballState[0] = .second
                    ballState[1] = .first
                }
                .append {
                    ballState[0] = .third
                    ballState[1] = .second
                    ballState[2] = .first
                }
                .append {
                    ballState[0] = .second
                    ballState[1] = .third
                    ballState[2] = .second
                }
                .append {
                    ballState[0] = .first
                    ballState[1] = .second
                    ballState[2] = .third
                }
                .append {
                    ballState[1] = .first
                    ballState[2] = .second
                }
                .append {
                    ballState[2] = .first
                }
                .repeat(delay: Constants.repeatDelay)
        }
    }
}

// MARK: - Subviews

private extension TypingIndicator {

    var content: some View {
        HStack(spacing: Constants.Spacing.containerHorizontal) {
            ForEach(ballState.indices, id: \.self) { index in
                Circle()
                    .frame(width: Constants.Sizing.ballSize, height: Constants.Sizing.ballSize)
                    .foregroundStyle(colors.background.inverse.opacity(ballOpacity(for: ballState[index])))
                    .offset(y: -ballOffset(for: ballState[index]))
            }
        }
        .padding(.horizontal, Constants.Padding.containerHorizontal)
        .padding(.vertical, Constants.Padding.containerVertical)
        .background(colors.background.surface.default)
        .cornerRadius(StyleGuide.Sizing.Message.cornerRadius, corners: .allCorners)
    }
    
    func ballOpacity(for step: AnimationStep) -> Double {
        switch step {
        case .first:
            return Constants.Colors.thirdStateBallOpacity
        case .second:
            return Constants.Colors.secondStateBallOpacity
        case .third:
            return Constants.Colors.firstStateBallOpacity
        }
    }
    
    func ballOffset(for step: AnimationStep) -> Double {
        switch step {
        case .first:
            return .zero
        case .second:
            return Constants.Spacing.ballOffset / 2
        case .third:
            return Constants.Spacing.ballOffset
        }
    }
}

// MARK: - Preview

#Preview {
    TypingIndicator(agent: MockData.agent)
        .environmentObject(ChatStyle())
}
