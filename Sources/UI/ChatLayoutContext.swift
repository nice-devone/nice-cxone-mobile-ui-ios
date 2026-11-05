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
import UIKit

/// Geometry of the chat container, republished whenever that geometry changes.
///
/// The orientation-derived layout constants — `StyleGuide.Sizing.*`, `UIDevice.isLandscape`,
/// `AttachmentThumbnailDisplayMode.size` — resolve through `StyleGuide.screenBoundsProvider`, a plain
/// global. SwiftUI records no dependency on a global, so a view whose `body` reads one of those
/// constants is not re-evaluated on rotation and keeps whichever value was resolved when that body last
/// ran. Rotation appeared to work only where something unrelated (a keyboard notification, a view model
/// update) happened to re-run the body as well.
///
/// This type supplies the missing dependency edge. `ChatContainerView` measures itself and writes the
/// result into the environment; every view that reads an orientation-derived constant reads this value
/// too — see ``LayoutAware`` — so a resize invalidates that view and its constants resolve afresh.
///
/// The sizes themselves still come from `StyleGuide.screenBoundsProvider`; ``containerSize`` takes no
/// part in any layout maths. Deriving them from the measured container instead would additionally fix
/// iPad Split View and Stage Manager — where the window is portrait-shaped on a landscape screen, and
/// every screen-derived width is consequently too wide — but it shifts each landscape measurement by the
/// safe-area insets and so requires re-recording the landscape snapshot references. That is deliberately
/// left as a follow-up; the accessors below are where it would land.
struct ChatLayoutContext: Equatable {

    // MARK: - Properties

    /// Size of the chat container as of its last measurement, or `.zero` before the first one — in a
    /// preview, a snapshot test, or any view hosted outside `ChatContainerView`.
    ///
    /// No layout calculation reads it. It is the value SwiftUI diffs, and diffing it is what invalidates
    /// the views that depend on orientation.
    let containerSize: CGSize

    /// Screen geometry and size classes as of the host's last evaluation.
    ///
    /// Also unread by any layout calculation — the accessors below resolve live — and also part of the
    /// diffed value. They exist because the container's size is not a complete trigger: an integrator
    /// may host `ChatContainerView` at a fixed frame (a UIKit parent with a static frame, a fixed-size
    /// `.formSheet`), where rotating changes the screen but never the container. Geometry alone would
    /// report nothing there and every view would keep the previous orientation's layout — the very
    /// defect this type exists to prevent, in a host the SDK cannot detect. A size-class change
    /// re-evaluates the host regardless of layout, and the resampled bounds then differ, so dependents
    /// are invalidated anyway — on a phone, whose vertical size class flips on rotation. It does not
    /// rescue an iPad in such a host: rotating one leaves both size classes `.regular`, so neither
    /// trigger fires and the previous orientation's layout survives. That case needs the values
    /// sourced from ``containerSize``, the follow-up the type doc above flags.
    let sampledScreenBounds: CGRect
    let verticalSizeClass: UserInterfaceSizeClass?
    let horizontalSizeClass: UserInterfaceSizeClass?

    /// Bounds of the screen the chat is displayed on.
    ///
    /// Resolved through `StyleGuide.screenBoundsProvider` rather than `UIScreen.currentBounds` directly,
    /// so a view reading it honours the bounds a snapshot test injects.
    @MainActor
    var screenBounds: CGRect { StyleGuide.screenBoundsProvider.screenBounds }

    /// `true` when the screen's long edge runs horizontally.
    @MainActor
    var isLandscape: Bool { UIDevice.isLandscape }

    /// `true` when the screen is too short to show a full-size message input alongside the keyboard —
    /// in practice, an iPhone in landscape.
    @MainActor
    var isCompactHeight: Bool { UIDevice.isCompactHeight }

    /// Width cap for a message bubble in the current orientation.
    @MainActor
    var messageMaxWidth: CGFloat { StyleGuide.Sizing.Message.maxWidth }

    // MARK: - Methods

    /// Thumbnail dimensions for `mode` in the current orientation.
    @MainActor
    func attachmentSize(for mode: AttachmentThumbnailDisplayMode) -> CGSize {
        mode.size
    }
}

// MARK: - Environment

private struct ChatLayoutContextKey: EnvironmentKey {

    static let defaultValue = ChatLayoutContext(
        containerSize: .zero,
        sampledScreenBounds: .zero,
        verticalSizeClass: nil,
        horizontalSizeClass: nil
    )
}

extension EnvironmentValues {

    /// Geometry of the enclosing chat container. Read it — via ``LayoutAware`` — from any view whose
    /// layout depends on the device orientation, so the view is invalidated when that geometry changes.
    var chatLayout: ChatLayoutContext {
        get { self[ChatLayoutContextKey.self] }
        set { self[ChatLayoutContextKey.self] = newValue }
    }
}

// MARK: - Modifier

extension View {

    /// Measures the receiver and publishes its size to the subtree as ``ChatLayoutContext``.
    ///
    /// Applied by `ChatContainerView`, and again by `OverlayManager` for whatever the container's
    /// overlay slot holds — today the loading and offline overlays, the inactivity popup and the
    /// end-conversation sheet. That window sits outside the container's hierarchy and inherits none
    /// of its environment, so without a host of its own the content would keep the default context
    /// and freeze at the orientation it was launched in. Both `BottomSheetView` variants are
    /// presented there, and that second host is what invalidates their horizontal inset on rotation.
    func measuringChatLayout() -> some View {
        modifier(ChatLayoutContextModifier())
    }
}

/// Publishes the measured size of the view it is applied to as the subtree's ``ChatLayoutContext``.
///
/// A `GeometryReader` in a `background` is what reports the change, rather than
/// `UIDevice.orientationDidChangeNotification`. It reports *after* layout, so the screen bounds the
/// constants read are already the post-rotation ones — the notification is posted from the device sensor
/// and can arrive while the bounds still describe the previous orientation, the same ordering hazard
/// `KeyboardCoverageState.coverageThreshold` documents. It also covers resizes that the device
/// notification never reports at all: iPad Split View, Stage Manager, and a host app driving rotation
/// programmatically.
private struct ChatLayoutContextModifier: ViewModifier {

    // MARK: - Properties

    @State private var containerSize: CGSize = .zero

    // Read so that a size-class change re-evaluates this body, and carried into the published value so
    // that the change is visible to dependents. See `ChatLayoutContext.sampledScreenBounds`.
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Builder

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    // Assigned from `onAppear`/`onChange` rather than during the `GeometryReader`'s own
                    // body, which would be a state mutation inside a layout pass.
                    Color.clear
                        .onAppear {
                            containerSize = proxy.size
                        }
                        .onChange(of: proxy.size) { newSize in
                            containerSize = newSize
                        }
                }
                .accessibilityHidden(true)
            )
            .environment(
                \.chatLayout,
                ChatLayoutContext(
                    containerSize: containerSize,
                    sampledScreenBounds: StyleGuide.screenBoundsProvider.screenBounds,
                    verticalSizeClass: verticalSizeClass,
                    horizontalSizeClass: horizontalSizeClass
                )
            )
    }
}
