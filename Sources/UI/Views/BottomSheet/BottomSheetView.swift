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

struct BottomSheetView: View, Themed, LayoutAware {
    
    // MARK: - Constants
    
    private enum Constants {
        enum Sizing {
            static let contentTopCornerRadius: CGFloat = 28
        }
        enum Padding {
            static let contentTop: CGFloat = 32
            /// Keys off *device* orientation (via the screen bounds), not the width the
            /// sheet is actually laid out in. Deliberate: this module targets iPhone,
            /// where the two always agree. On iPad multitasking they do not — a
            /// portrait-width column on a landscape screen would get the wider inset.
            /// Switch to the container width or `horizontalSizeClass` if iPad becomes
            /// a supported layout.
            static func contentHorizontal(isLandscape: Bool) -> CGFloat {
                isLandscape ? 64 : 24
            }
            static let contentBottom: CGFloat = 12
            /// Floor for the bottom clearance on home-button devices. They report a zero
            /// bottom safe-area inset, so `contentBottom` alone would leave the last row
            /// 12pt from the physical screen edge — this keeps the flat clearance the sheet
            /// reserved on every device before the inset was added back. `ChatView`'s
            /// `archivedChatMessageBottom` follows the same approach.
            ///
            /// Takes the container's bottom inset (the `GeometryReader` proxy at the call site)
            /// rather than reading `UIDevice.hasHomeButton`. That getter queries the key window's
            /// `safeAreaInsets`, and when the sheet is hosted by `OverlayManager` the key window is
            /// the overlay's own. On iOS 26 UIKit answers that query by asking the overlay's
            /// `UIHostingController` for its status-bar preference, which re-enters the SwiftUI
            /// graph mid-update — an AttributeGraph cycle that leaves the sheet's content frozen
            /// (the inactivity popup's countdown stopped redrawing).
            ///
            /// `.fixedHeight` snapshot renders report a zero container inset, so they exercise the
            /// 40pt branch; `.device` renders report the simulator's real inset and do not.
            static func contentBottomMinimum(bottomSafeAreaInset: CGFloat) -> CGFloat {
                bottomSafeAreaInset.isNegligibleSafeAreaInset ? 40 : .zero
            }
        }
        enum Colors {
            static let backgroundOpacity: Double = 0.5
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @Environment(\.chatLayout) var chatLayout
    
    @ViewBuilder var content: () -> any View
    
    // MARK: - Builder
    
    var body: some View {
        // `GeometryReader` sits outside `ignoresSafeArea` so it reports the real bottom
        // inset; reading it from inside would always yield zero.
        //
        // The reader is greedy in both axes and lays its content out top-leading, so the
        // layout relies on the `ZStack` claiming the full proposed size — that is what keeps
        // the sheet at the bottom edge. The `ZStack`'s *horizontal* alignment (`.bottom`
        // implies centre horizontally) is likewise what centres the sheet once
        // `overlayMaxWidth` caps its width on wide screens; changing that alignment would
        // silently left- or right-align the sheet there.
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Color.black
                    .opacity(Constants.Colors.backgroundOpacity)

                AnyView(content())
                    .padding(.top, Constants.Padding.contentTop)
                    .padding(.horizontal, Constants.Padding.contentHorizontal(isLandscape: isLandscape))
                    // The sheet deliberately bleeds past the bottom safe area so its background
                    // reaches the screen edge. Adding the inset back on the content keeps
                    // `contentBottom` of real clearance between the last row and the home
                    // indicator, instead of the row sitting underneath it. The floor only ever
                    // raises that total — it covers home-button devices, which have no inset
                    // to add back and would otherwise be left with `contentBottom` alone.
                    .padding(.bottom, max(
                        Constants.Padding.contentBottom + proxy.safeAreaInsets.bottom,
                        Constants.Padding.contentBottomMinimum(bottomSafeAreaInset: proxy.safeAreaInsets.bottom)
                    ))
                    .background(
                        Rectangle()
                            .fill(colors.background.surface.subtle)
                    )
                    .cornerRadius(Constants.Sizing.contentTopCornerRadius, corners: [.topLeft, .topRight])
                    .frame(maxWidth: StyleGuide.Sizing.overlayMaxWidth)
            }
            .ignoresSafeArea()
        }
        .presentationWithBackgroundColor(.clear)
    }
}

// MARK: - Previews

// swiftlint:disable hardcoded_strings sf_symbol_key_in_image
private struct TestView: View {
    
    // MARK: - Properties
    
    @StateObject var overlayManager = OverlayManager()
    @State var showOverlay = false
    
    // MARK: - Builder
    
    var body: some View {
        NavigationStack {
            Button {
                showOverlay = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .padding()

                    Text("Show overlay")
                }
            }
            .onChange(of: showOverlay) { show in
                if show {
                    overlayManager.show {
                        overlayContent
                    }
                } else {
                    overlayManager.hide()
                }
            }
            .onDisappear(perform: overlayManager.hide)
            .navigationTitle("Dashboard")
        }
    }
}

// MARK: - Subviews

private extension TestView {

    var overlayContent: some View {
        BottomSheetView {
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text("Time is up")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.black)

                        Text("This conversation will now end due to inactivity")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "hourglass")
                        .font(.title2)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.yellow)
                        )
                }

                Button {
                    showOverlay = false
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "xmark")

                        Text("Close chat")

                        Spacer()
                    }
                }
                .adjustForA11y()
            }
        }
        .environmentObject(ChatStyle())
    }
}

#Preview {
    TestView()
        .environmentObject(ChatStyle())
}
// swiftlint:enable hardcoded_strings sf_symbol_key_in_image
