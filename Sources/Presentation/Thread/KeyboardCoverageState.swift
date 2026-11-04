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

import CoreGraphics

/// Whether a keyboard raised by the message input is covering the conversation, reduced from the two
/// signals that describe it: app-wide keyboard notifications and the input's first-responder state.
///
/// `ChatView` uses this to decide when the attachment strip inset at the bottom of the conversation has
/// to shrink. Kept as a value type rather than a computed property over loose flags so the transitions —
/// which are not symmetric — can be unit-tested.
struct KeyboardCoverageState: Equatable {

    // MARK: - Properties

    /// Height a keyboard has to reach before it is worth reflowing the conversation for.
    ///
    /// The shortcuts bar that accompanies a hardware keyboard posts the same notifications at roughly
    /// 55 pt, while the shortest software keyboard — a landscape phone — is around 190 pt; this sits
    /// between the two. Deliberately an absolute value rather than a share of the screen: a rotation
    /// posts the notification before the screen bounds necessarily reflect it, and a landscape keyboard
    /// measured against a portrait screen falls on the wrong side of a proportional threshold.
    static let coverageThreshold: CGFloat = 100

    /// Whether the strip should adopt its compact geometry.
    private(set) var isCoveringConversation = false

    private var isKeyboardTallEnoughToCover = false
    private var isInputFocused = false

    // MARK: - Methods

    /// Records a `keyboardWillShow` notification.
    ///
    /// - Parameter height: Height of the keyboard's reported end frame, or `nil` when the notification
    ///   carries no frame — treated as covering, which is the conservative reading.
    mutating func keyboardWillShow(height: CGFloat?) {
        isKeyboardTallEnoughToCover = height.map { reportedHeight in
            reportedHeight > Self.coverageThreshold
        } ?? true

        guard isKeyboardTallEnoughToCover else {
            // Pairing a hardware keyboard swaps the software keyboard for its ~55 pt shortcuts bar and
            // reports that as a show, not a hide — so this has to clear coverage, not merely skip
            // setting it.
            isCoveringConversation = false
            return
        }

        updateCoverage()
    }

    mutating func keyboardWillHide() {
        isKeyboardTallEnoughToCover = false
        isCoveringConversation = false
    }

    mutating func inputFocusChanged(to isFocused: Bool) {
        isInputFocused = isFocused

        updateCoverage()
    }
}

// MARK: - Private Methods

private extension KeyboardCoverageState {

    /// Only ever sets coverage. It is cleared by `keyboardWillHide`, and by a `keyboardWillShow` whose
    /// frame is too small to cover anything — never by losing focus alone.
    ///
    /// A keyboard has to be attributed to the message input before it counts, otherwise one raised by
    /// presented content (a picker sheet's search field, the thread-name alert) reflows the strip
    /// underneath, which that keyboard never covers. The field can become first responder either side of
    /// the notification, so both signals route through here. Losing focus, on the other hand, says
    /// nothing about the keyboard still being on screen: `scrollDismissesKeyboard(.interactively)`
    /// resigns the field partway through the drag, and expanding the strip there would put it straight
    /// back over the input bar it exists to keep clear.
    mutating func updateCoverage() {
        guard isKeyboardTallEnoughToCover, isInputFocused else {
            return
        }

        isCoveringConversation = true
    }
}
