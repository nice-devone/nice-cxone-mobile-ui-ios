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

struct TypingIndicator: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @State private var indexOfAnimatedBall = 3
    
    private let smallBallSize: CGFloat = 6
    private let middleBallSize: CGFloat = 14
    private let animatedBallSize: CGFloat = 10
    private let speed: Double = 0.2
    private let ballCount = 3
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .leading) {
            Circle()
                .fill(style.agentCellColor)
                .frame(width: smallBallSize, height: smallBallSize)
                .offset(x: -10, y: 20)
            
            Circle()
                .fill(style.agentCellColor)
                .frame(width: middleBallSize, height: middleBallSize)
                .offset(x: -6, y: 12)
            
            HStack(spacing: 4) {
                ForEach(0..<ballCount, id: \.self) { index in
                    Capsule()
                        .foregroundColor(indexOfAnimatedBall == index ? style.backgroundColor : style.backgroundColor.opacity(0.5))
                        .frame(width: animatedBallSize, height: animatedBallSize)
                        .offset(y: indexOfAnimatedBall == index ? -4 : 0)
                }
            }
            .padding(12)
            .background(style.agentCellColor)
            .cornerRadius(14, corners: .allCorners)
        }
        .padding(.leading, 14)
        .padding(.bottom, 10)
        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1).speed(2))
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { _ in
                indexOfAnimatedBall = (indexOfAnimatedBall + 1) % ballCount
            }
        }
    }
}

// MARK: - Preview

struct TypingIndicator_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            TypingIndicator()
                .previewDisplayName("Light Mode")
            
            TypingIndicator()
                .preferredColorScheme(.dark)
                .previewDisplayName("Light Mode")
        }
        .environmentObject(ChatStyle())
    }
}
