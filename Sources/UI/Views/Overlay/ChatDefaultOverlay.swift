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

struct ChatDefaultOverlay<Content: View>: View, Themed {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let overlay: () -> Content

    private let rounding: CGFloat = 32
    private let shadowSize: CGFloat = 8
    private let shadowOffsetX: CGFloat = 0
    private let shadowOffsetY: CGFloat = 4
    private let shadowColor = Color.black.opacity(0.25)
    private let horizontalPadding: CGFloat = 16
    private let verticalOffset: CGFloat

    // MARK: - Init

    init(verticalOffset: CGFloat, @ViewBuilder _ overlay: @escaping () -> Content) {
        self.overlay = overlay
        self.verticalOffset = verticalOffset
    }

    var body: some View {
        ZStack(alignment: .top) {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
                .ignoresSafeArea(.all)
                .opacity(0.85)

            overlay()
                .background(colors.customizable.background)
                .cornerRadius(rounding)
                .shadow(
                    color: shadowColor,
                    radius: shadowSize,
                    x: shadowOffsetX,
                    y: shadowOffsetY
                )
                .padding(.top, verticalOffset)
                .padding(.horizontal, horizontalPadding)
        }
    }
}

// MARK: - Previews

#Preview("Long") {
    ChatDefaultOverlayPreview {
        VStack(alignment: .center) {
            ProgressView()
            
            Text(ChatLocalization().alertGenericErrorMessage)
        }
        .padding()
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}

#Preview("Short") {
    ChatDefaultOverlayPreview {
        VStack(alignment: .center) {
            ProgressView()
            
            Text(ChatLocalization().commonLoading)
        }
        .padding()
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
