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

extension View {
    
    /// - Parameter maxWidth: Width cap for the bubble. Defaults to `nil`, which lets the modifier take
    ///   the standard cap from its own ``ChatLayoutContext`` — resolving it there rather than in the
    ///   caller's `body` is what keeps it correct across a rotation, since the modifier is re-evaluated
    ///   on a layout change even when the calling cell's `body` is not.
    func messageChatStyle(
        _ message: ChatMessage,
        position: MessageGroupPosition,
        text: String? = nil,
        maxWidth: CGFloat? = nil
    ) -> some View {
        modifier(ChatTextStyleModifier(message: message, text: text, position: position, maxWidth: maxWidth))
    }
}

// The preview's ruler visualizes the bubble cap at a fixed size and never rotates, so it reads the
// orientation-derived constant directly rather than through `LayoutAware`.
// swiftlint:disable hardcoded_strings sf_symbol_key_in_image orientation_outside_layout_context
#Preview {
    VStack(spacing: 4) {
        Spacer()

        // Ruler visualizing `StyleGuide.Sizing.Message.maxWidth` (red segment) against the
        // full `StyleGuide.screenBoundsProvider.screenBounds.width` (red + gray) — the
        // message bubble below must never cross the boundary the arrow points to.
        ZStack(alignment: .topLeading) {
            HStack(spacing: .zero) {
                Capsule()
                    .fill(Color.red)
                    .frame(width: StyleGuide.Sizing.Message.maxWidth, height: 4)

                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
            }

            VStack(spacing: 2) {
                Text("60 %")
                    .font(.caption2)
                    .fontWeight(.bold)

                Image(systemName: "arrow.down")
            }
            .foregroundStyle(Color.red)
            .offset(x: StyleGuide.Sizing.Message.maxWidth - 16, y: 8)
        }

        HStack(spacing: .zero) {
            Text(Lorem.paragraph(nbSentences: 2))
                .padding(.vertical, StyleGuide.Padding.Message.contentVertical)
                .padding(.horizontal, StyleGuide.Padding.Message.contentHorizontal)
                .messageChatStyle(MockData.textMessage(user: MockData.agent), position: .single)

            Spacer()
        }

        Spacer()
    }
    .environmentObject(ChatStyle())
}
// swiftlint:enable hardcoded_strings sf_symbol_key_in_image orientation_outside_layout_context
