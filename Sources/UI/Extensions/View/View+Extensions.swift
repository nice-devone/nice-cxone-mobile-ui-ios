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

    /// Dismisses the keyboard when the user taps anywhere within the view.
    ///
    /// The tap is attached as a *simultaneous* gesture so it never swallows taps handled by nested content — a tap on a message bubble
    /// or a rich message button still reaches that child while the keyboard is dismissed alongside it. `contentShape` makes the whole
    /// frame tappable, so taps landing on empty space (a conversation with only a few messages) are recognised as well.
    ///
    /// - Important: Apply it only to a subtree that holds no focusable input. Because the gesture is simultaneous, a tap on a text field
    ///   inside the subtree would both focus that field and resign it again. Subtrees that do contain text fields — a form, for instance —
    ///   need `dismissKeyboardOnUnhandledTap()` instead.
    func dismissKeyboardOnTap() -> some View {
        contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        hideKeyboard()
                    }
            )
    }

    /// Dismisses the keyboard when the user taps the view, but only where the tap is not already handled by nested content.
    ///
    /// The counterpart to `dismissKeyboardOnTap()` for subtrees that contain focusable input. A plain tap gesture loses to any gesture
    /// deeper in the hierarchy, so tapping one text field while another is focused moves focus as the user expects instead of also
    /// resigning the field that just became first responder.
    func dismissKeyboardOnUnhandledTap() -> some View {
        onTapGesture {
            hideKeyboard()
        }
    }

    /// Clips the view to the given shape for both drawing and hit-testing.
    ///
    /// `clipShape(_:)` alone only clips what is drawn — the part of a `scaledToFill()` image cropped off outside its frame
    /// still receives taps, so a tap just beside a thumbnail would open it.
    /// - Parameter shape: The shape the view is drawn in and receives taps within.
    func clippedHitArea<ClipShape: Shape>(_ shape: ClipShape) -> some View {
        clipShape(shape)
            .contentShape(shape)
    }

    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifNotNil<Content: View, T>(
        _ conditional: T?,
        @ViewBuilder _ content: (Self, _ value: T) -> Content
    ) -> some View {
        if let conditional {
            content(self, conditional)
        } else {
            self
        }
    }

    /// Applies a transform to the view when an optional value is non-`nil`, passing the unwrapped value to the closure.
    @ViewBuilder
    func ifLet<Content: View, T>(_ conditional: T?, @ViewBuilder _ content: (Self, _ value: T) -> Content) -> some View {
        if let conditional {
            content(self, conditional)
        } else {
            self
        }
    }

    /// Applies one of two transforms depending on whether an optional value is non-`nil`.
    @ViewBuilder
    func ifLet<TrueContent: View, T, ElseContent: View>(
        _ conditional: T?,
        @ViewBuilder _ content: (Self, _ value: T) -> TrueContent,
        @ViewBuilder else: (Self) -> ElseContent
    ) -> some View {
        if let conditional {
            content(self, conditional)
        } else {
            `else`(self)
        }
    }
}

// MARK: - Private methods

private extension View {
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
