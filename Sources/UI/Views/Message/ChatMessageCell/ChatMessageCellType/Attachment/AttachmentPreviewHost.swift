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

import CXoneChatSDK
import SwiftUI

/// A full-screen attachment preview, requested by a cell and presented by an ancestor.
///
/// Carries only values. A cell must not hand over its own view model: the host outlives the cell, and
/// the whole point of hosting the presentation is that it no longer depends on the cell surviving.
enum AttachmentPreviewContent {

    // MARK: - Cases

    case image(UIImage, name: String)
    case video(URL, name: String)
    case document(URL)
    /// The viewer needs a live loading state and a retry action, so the host builds a `PDFViewModel`
    /// from this item — an `AttachmentItem` rather than a bare `URL`, which would drop
    /// `requiresSecurityScope` on the way and break locally-picked files.
    ///
    /// `preparePDFForViewing()` consults `AttachmentCache` first, so a warm cache is reused rather than
    /// refetched, and the host builds the view model with `loadsThumbnail: false` — the viewer renders
    /// `documentLoadingState` only, so an eager thumbnail render would fetch the document again for an
    /// image nothing displays.
    ///
    /// A tap on a cold cache can still overlap the cell's own download: no path here awaits
    /// `AttachmentLoader`, each only samples its state once, so `loadPDF(from:)` falls through to its own
    /// `PDFDocument(url:)`. That fan-out predates hosting — the cell's `init` has always done it — and
    /// coalescing it needs an awaitable loader, which is a change across every attachment type.
    case pdf(AttachmentItem)
}

// MARK: - AttachmentPreviewPayload

/// What the host actually presents: ``AttachmentPreviewContent`` after the host has built whatever the
/// viewer needs from it.
///
/// Separate from the request so the PDF view model rides in the case that requires it. Carrying it
/// alongside as an optional left `.pdf` + `nil` representable, and that pairing renders a
/// `fullScreenCover` over an `EmptyView` — no toolbar, no grabber, no way out. Exactly the trap this
/// file exists to close, reached from the other side.
enum AttachmentPreviewPayload {

    // MARK: - Cases

    case image(UIImage, name: String)
    case video(URL, name: String)
    case document(URL)
    case pdf(PDFViewModel)
}

// MARK: - AttachmentPreviewItem

/// Identity for a single presentation. A fresh id per request means asking for the same attachment
/// twice re-presents it rather than being swallowed as an unchanged value.
struct AttachmentPreviewItem: Identifiable {

    // MARK: - Properties

    let id = LowercaseUUID().uuidString

    /// Resolved once, when the preview is requested — never inside the cover's content closure, which
    /// SwiftUI re-evaluates on every update of the presenting view. `PDFViewModel.init` starts a
    /// download (`AttachmentLoader.init` calls `load()`) and a thumbnail render, and `PDFViewer` holds
    /// it with `@ObservedObject`, so building it there reset the viewer to its spinner and spawned a
    /// fresh download on every re-render of the conversation.
    ///
    /// Owned by the host rather than borrowed from a cell, so it outlives the cell that asked for it.
    let payload: AttachmentPreviewPayload
}

// MARK: - Action

/// Opens an attachment preview on the nearest enclosing ``AttachmentPreviewHost``.
///
/// Defaults to a no-op, so a cell rendered outside a host — a `#Preview`, a snapshot test — is inert
/// rather than crashing. Every cell the app renders sits under one: `ChatView` hosts its whole body,
/// input bar included, so the composer's staged thumbnails present through it too.
struct PresentAttachmentPreviewAction {

    // MARK: - Properties

    private let handler: ((AttachmentPreviewContent) -> Void)?

    // MARK: - Init

    init(handler: ((AttachmentPreviewContent) -> Void)?) {
        self.handler = handler
    }

    // MARK: - Methods

    func callAsFunction(_ content: AttachmentPreviewContent) {
        handler?(content)
    }
}

// MARK: - Environment

private struct PresentAttachmentPreviewKey: EnvironmentKey {

    // Computed, so the no-op default isn't stored global state under strict concurrency.
    static var defaultValue: PresentAttachmentPreviewAction {
        PresentAttachmentPreviewAction(handler: nil)
    }
}

extension EnvironmentValues {

    /// Call this to open an attachment preview instead of declaring a presentation on the cell itself.
    ///
    /// Presentation state must not live on a view inside a lazy container. `ChatView`'s conversation is a
    /// `LazyVStack` and the attachments overview is a `LazyVGrid`: both discard off-screen children, and
    /// a discarded child takes its `.sheet`/`.fullScreenCover` with it, so the preview is dismissed
    /// rather than merely hidden. Where the presentation flag lives on a view model that outlives the
    /// view, the stale `true` then re-presents the preview unprompted when the cell is realized again.
    var presentAttachmentPreview: PresentAttachmentPreviewAction {
        get { self[PresentAttachmentPreviewKey.self] }
        set { self[PresentAttachmentPreviewKey.self] = newValue }
    }
}

// MARK: - Modifier

extension View {

    /// Hosts attachment previews for the subtree, presenting them above the receiver.
    ///
    /// Apply to a view that outlives the cells requesting the preview — `ChatView` above its
    /// `LazyVStack`, `AttachmentGalleryView` above its `LazyVGrid` — never inside the lazy container.
    /// The gallery needs its own host despite sitting under `ChatView`'s: it is presented in a sheet, and
    /// a cover from beneath a sheet does not render above it.
    func attachmentPreviewHost(alertType: Binding<ChatAlertType?>) -> some View {
        modifier(AttachmentPreviewHost(alertType: alertType))
    }
}

private struct AttachmentPreviewHost: ViewModifier {

    // MARK: - Properties

    @State private var item: AttachmentPreviewItem?

    @Binding var alertType: ChatAlertType?

    // MARK: - Builder

    func body(content: Content) -> some View {
        content
            .environment(
                \.presentAttachmentPreview,
                PresentAttachmentPreviewAction { requested in
                    item = makeItem(for: requested)
                }
            )
            .fullScreenCover(item: $item) { presented in
                previewView(for: presented)
            }
    }
}

// MARK: - Subviews

private extension AttachmentPreviewHost {

    func makeItem(for content: AttachmentPreviewContent) -> AttachmentPreviewItem {
        switch content {
        case .image(let image, let name):
            return AttachmentPreviewItem(payload: .image(image, name: name))
        case .video(let url, let name):
            return AttachmentPreviewItem(payload: .video(url, name: name))
        case .document(let url):
            return AttachmentPreviewItem(payload: .document(url))
        case .pdf(let attachmentItem):
            return AttachmentPreviewItem(
                payload: .pdf(
                    PDFViewModel(attachmentItem: attachmentItem, alertType: $alertType, loadsThumbnail: false)
                )
            )
        }
    }

    /// Only the viewers that draw a toolbar are wrapped in a `NavigationStack`. `QuickLookPreview`
    /// embeds `QLPreviewController` in its own `UINavigationController` and installs the Done button
    /// there, so wrapping it would stack a second, empty bar above its own and push the content down.
    @ViewBuilder
    func previewView(for presented: AttachmentPreviewItem) -> some View {
        switch presented.payload {
        case .image(let image, let name):
            NavigationStack {
                ImageViewer(image: image, name: name)
            }
        case .video(let url, let name):
            NavigationStack {
                VideoViewer(fileURL: url, name: name)
            }
        case .document(let url):
            QuickLookPreview(url: url, isPresented: isPresentedBinding)
        case .pdf(let pdfViewModel):
            NavigationStack {
                PDFViewer(viewModel: pdfViewModel)
            }
        }
    }

    /// `QuickLookPreview` dismisses itself through an `isPresented` binding rather than
    /// `@Environment(\.dismiss)`, so map it onto the host's item.
    var isPresentedBinding: Binding<Bool> {
        Binding(
            get: {
                item != nil
            },
            set: { isPresented in
                if !isPresented {
                    item = nil
                }
            }
        )
    }
}
