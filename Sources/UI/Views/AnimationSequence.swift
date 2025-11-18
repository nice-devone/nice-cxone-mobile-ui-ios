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

/// Create a sequence of animations to be executed in order.
///
/// Can be used as:
///
///     .task {
///         await AnimationSequence(style: .linear)
///             .duration(2.0)
///             .append { offset.width = 80 }
///             .append { offset.height = 80 }
///             .append { offset.width = 0 }
///             .append { offset.height = 0 }
///             .repeat(delay: 1.0)
///         }
///     }
///
struct AnimationSequence {
    
    // MARK: - Constants
    
    enum Constants {
        /// Default animation style
        static let defaultAnimation: Style = .easeInOut

        /// Default animation duration
        static let defaultDuration = 0.1
    }
    
    // MARK: - Objects
    
    /// Style of animation, correspond roughly to ``SwiftUI.Animation``
    enum Style {
        /// ``SwiftUI.Animation.linear``
        case linear
        /// ``SwiftUI.Animation.easeIn``
        case easeIn
        /// ``SwiftUI.Animation.easeOut``
        case easeOut
        /// ``SwiftUI.Animation.easeInOut``
        case easeInOut
        /// ``SwiftUI.Animation.bouncy``
        case bouncy
        /// Custom animation with a function to create the animation with the desired duration
        case custom((TimeInterval) -> Animation)
    }

    private struct Step {
        /// Style of animation for this step
        let style: Style
        /// Duration of this animation
        let duration: TimeInterval
        /// Delay to start of *next* animation step
        let delay: TimeInterval
        /// Changes to animate
        let block: () -> Void

        /// Create an animation with the requested duration
        var animation: Animation {
            switch style {
            case .linear:
                return .linear(duration: duration)
            case .easeIn:
                return .easeIn(duration: duration)
            case .easeOut:
                return .easeOut(duration: duration)
            case .easeInOut:
                return .easeInOut(duration: duration)
            case .bouncy:
                return .bouncy(duration: duration)
            case let .custom(getter):
                return getter(duration)
            }
        }
    }

    // MARK: - Properties

    /// Delay to be applied to new animations.  If a nil delay
    /// is specified, the duration will be used as the delay.
    private let delay: TimeInterval?

    /// Duration to be applied to future animations
    private let duration: TimeInterval

    /// Style to be applied to future animations
    private let style: Style

    /// List of animation steps to apply
    private let animations: [Step]

    /// Private copy constructor
    /// - parameters:
    ///     - style: default Style to be applied to animations
    ///     - delay: default delay to be applied to animations
    ///     - duration: default duration to be applied to animations
    ///     - list of animations to apply
    private init(
        style: Style,
        delay: TimeInterval?,
        duration: TimeInterval,
        animations: [Step]
    ) {
        self.style = style
        self.delay = delay
        self.duration = duration
        self.animations = animations
    }

    /// Default constructor
    /// - parameters:
    ///     - style: default Style to be applied to animations
    ///     - delay: default delay to be applied to animations
    ///     - duration: default duration to be applied to animations
    init(
        style: Style = Constants.defaultAnimation,
        delay: TimeInterval? = nil,
        duration: TimeInterval = Constants.defaultDuration
    ) {
        self.style = style
        self.delay = delay
        self.duration = duration
        self.animations = []
    }

    /// Add a new animation to the sequence
    /// - parameters:
    ///     - style: `Style` of animation to add.  If nil or not specified the default style for the
    ///     sequence will be applied.
    ///     - delay: delay of animation to add.  If nil or not specified, the default delay for the
    ///     sequence will be applied.
    ///     - duration: duration of animation to add.  If nil or not specified, the default duration for the
    ///     sequence will be applied
    ///     - block: the actual changes to animate
    /// - returns: Updated `AnimationSequence`
    func append(
        style: Style? = nil,
        delay: TimeInterval? = nil,
        duration: TimeInterval? = nil,
        block: @escaping () -> Void
    ) -> AnimationSequence {
        AnimationSequence(
            style: self.style,
            delay: self.delay,
            duration: self.duration,
            animations: self.animations + [
                Step(
                    style: style ?? self.style,
                    duration: duration ?? self.duration,
                    delay: delay ?? self.delay ?? duration ?? self.duration,
                    block: block
                )
            ]
        )
    }

    /// Start the animation sequence running
    /// - parameter completion: optional block to call on completion of the animation sequence.
    func start(completion: (() -> Void)? = nil) {
        var offset: TimeInterval = 0.0

        animations.indices.forEach { index in
            let animation = animations[index]
            let currentOffset = offset + animation.delay
            
            if #available(iOS 17.0, *) {
                withAnimation(animation.animation.delay(offset)) {
                    animation.block()
                } completion: {
                    if index + 1 == animations.endIndex {
                        completion?()
                    }
                }

                offset += animation.delay

            } else {
                withAnimation(animation.animation.delay(offset)) {
                    animation.block()
                }

                offset += animation.delay

                if index + 1 == animations.endIndex, let completion = completion {
                    Task {
                        try await Task.sleep(nanoseconds: currentOffset.nanoseconds)

                        completion()
                    }
                }
            }
        }
    }

    /// Start the animation sequence running repeatedly
    /// - parameters:
    ///     - count: number of times to repeat the animation.  Defaults to Int.max
    ///     - delay: seconds to delay after each iteration of the sequence.
    func `repeat`(count: Int = .max, delay: TimeInterval? = nil) async {
        for _ in 0 ..< count {
            if Task.isCancelled {
                break
            }

            await withUnsafeContinuation { context in
                start { context.resume() }
            }

            if let delay {
                try? await Task.sleep(nanoseconds: delay.nanoseconds)
            }
        }
    }
}

// MARK: - Helpers

private extension TimeInterval {
    
    var nanoseconds: UInt64 {
        UInt64(self * 1e9)
    }
}

// MARK: - Preview

#Preview {
    TypingIndicator(agent: MockData.agent)
        .environmentObject(ChatStyle())
}
