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

struct AttachmentLoadingView<ClipShape: InsettableShape>: View, Themed {

    // MARK: - Properties

    let size: CGSize

    /// Bubble-matched shape for cells grouped in a conversation (see `MessageGroupPosition.attachmentClipShape`);
    /// defaults to the plain attachment corner radius for standalone/gallery contexts.
    let clipShape: ClipShape

    /// `true` only at the handful of call sites that own the only border drawn around their
    /// cell (`ImageMessageCell`/`VideoMessageCell`/`DocumentMessageCell`'s non-loaded
    /// branches, plus `MessageInputDocumentThumbnailView`'s unresolved-MIME branch). Every
    /// other call site is nested inside a caller that already draws its own border around
    /// the whole cell regardless of loading state — passing `true` there would stroke the
    /// same border twice, stacked exactly on top of itself.
    let drawsBorder: Bool

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    // MARK: - Init

    init(
        size: CGSize,
        clipShape: ClipShape = RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius),
        drawsBorder: Bool = false
    ) {
        self.size = size
        self.clipShape = clipShape
        self.drawsBorder = drawsBorder
    }

    /// Convenience for callers holding the two dimensions separately rather than as a `CGSize` —
    /// typically previews and snapshot tests, which name a `StyleGuide` constant per axis.
    init(
        width: CGFloat,
        height: CGFloat,
        clipShape: ClipShape = RoundedRectangle(cornerRadius: StyleGuide.Sizing.Attachment.cornerRadius),
        drawsBorder: Bool = false
    ) {
        self.init(size: CGSize(width: width, height: height), clipShape: clipShape, drawsBorder: drawsBorder)
    }

    // MARK: - Builder

    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: colors.content.primary))
            .frame(size: size)
            .overlay {
                if drawsBorder {
                    clipShape
                        .strokeBorder(colors.border.default, lineWidth: StyleGuide.Sizing.Attachment.borderWidth)
                }
            }
    }
}

// Previews demonstrate each fixed size deliberately and never rotate, so they read the
// orientation-derived constants directly rather than through `LayoutAware`.
// swiftlint:disable orientation_outside_layout_context
// MARK: - Previews

#Preview("Small") {
    AttachmentLoadingView(
        width: StyleGuide.Sizing.Attachment.smallDimension,
        height: StyleGuide.Sizing.Attachment.smallDimension,
        drawsBorder: true
    )
    .environmentObject(ChatStyle())
}

#Preview("Regular - single") {
    AttachmentLoadingView(
        width: StyleGuide.Sizing.Attachment.regularDimension,
        height: StyleGuide.Sizing.Attachment.regularDimension,
        drawsBorder: true
    )
    .environmentObject(ChatStyle())
}

#Preview("Regular - first") {
    HStack {
        AttachmentLoadingView(
            width: StyleGuide.Sizing.Attachment.regularDimension,
            height: StyleGuide.Sizing.Attachment.regularDimension,
            clipShape: MessageGroupPosition.first.clipShape(isUserAgent: true),
            drawsBorder: true
        )

        AttachmentLoadingView(
            width: StyleGuide.Sizing.Attachment.regularDimension,
            height: StyleGuide.Sizing.Attachment.regularDimension,
            clipShape: MessageGroupPosition.first.clipShape(isUserAgent: false),
            drawsBorder: true
        )
    }
    .environmentObject(ChatStyle())
}

#Preview("Regular - inside") {
    HStack {
        AttachmentLoadingView(
            width: StyleGuide.Sizing.Attachment.regularDimension,
            height: StyleGuide.Sizing.Attachment.regularDimension,
            clipShape: MessageGroupPosition.inside.clipShape(isUserAgent: true),
            drawsBorder: true
        )

        AttachmentLoadingView(
            width: StyleGuide.Sizing.Attachment.regularDimension,
            height: StyleGuide.Sizing.Attachment.regularDimension,
            clipShape: MessageGroupPosition.inside.clipShape(isUserAgent: false),
            drawsBorder: true
        )
    }
    .environmentObject(ChatStyle())
}

#Preview("Regular - last") {
    HStack {
        AttachmentLoadingView(
            width: StyleGuide.Sizing.Attachment.regularDimension,
            height: StyleGuide.Sizing.Attachment.regularDimension,
            clipShape: MessageGroupPosition.last.clipShape(isUserAgent: true),
            drawsBorder: true
        )

        AttachmentLoadingView(
            width: StyleGuide.Sizing.Attachment.regularDimension,
            height: StyleGuide.Sizing.Attachment.regularDimension,
            clipShape: MessageGroupPosition.last.clipShape(isUserAgent: false),
            drawsBorder: true
        )
    }
    .environmentObject(ChatStyle())
}

#Preview("Large") {
    AttachmentLoadingView(
        width: StyleGuide.Sizing.Attachment.largeWidth,
        height: StyleGuide.Sizing.Attachment.largeHeight,
        drawsBorder: true
    )
    .environmentObject(ChatStyle())
}
// swiftlint:enable orientation_outside_layout_context
