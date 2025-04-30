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

struct ChatDefaultOverlayView<Content: View>: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @Binding var isHeaderVisible: Bool
    
    let title: String?
    let subtitle: String?
    let cardImage: Image
    let content: ((StyleColors) -> Content)?
    
    private let headerPaddingTop: CGFloat = 36
    private let headerGradientStartPoint = UnitPoint(x: 0.12, y: 0)
    private let headerGradientEndPoint = UnitPoint(x: 0.88, y: 1)
    private let headerIconDimension: CGFloat = 76
    private let headerPaddingBottom: CGFloat = 22
    private let actionFooterTitlePaddingTop: CGFloat = 24
    private let actionFooterTitlePaddingBottomSmall: CGFloat = 8
    private let actionFooterTitlePaddingBottomLarge: CGFloat = 16
    private let actionFooterContentPaddingTop: CGFloat = 16
    private let actionFooterContentSpacing: CGFloat = 12
    private let actionFooterPaddingHorizontal: CGFloat = 24
    private let actionFooterPaddingBottomLarge: CGFloat = 32
    private let actionFooterPaddingBottomSmall: CGFloat = 24
    private let darkModeOpacity: CGFloat = 0.75
    
    // MARK: - Init
    
    init(
        title: String?,
        subtitle: String?,
        cardImage: Image,
        @ViewBuilder content: @escaping (StyleColors) -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.cardImage = cardImage
        self.content = content
        self._isHeaderVisible = .constant(true)
    }
    
    init(title: String?, subtitle: String?, cardImage: Image, isHeaderVisible: Binding<Bool> = .constant(true)) where Content == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.cardImage = cardImage
        self._isHeaderVisible = isHeaderVisible
        self.content = nil
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: 0) {
            if isHeaderVisible {
                statusHeader
            }
            
            actionFooter
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(
            ZStack {
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: colors.accent.bold, location: .zero),
                        Gradient.Stop(color: colors.accent.pop, location: .one)
                    ],
                    startPoint: headerGradientStartPoint,
                    endPoint: headerGradientEndPoint
                )
            }
        )
        .animation(.easeInOut, value: isHeaderVisible)
    }
    
    var statusHeader: some View {
        cardImage
            .resizable()
            .scaledToFit()
            .frame(width: headerIconDimension, height: headerIconDimension)
            .foregroundStyle(colors.accent.primary)
            .padding(.bottom, headerPaddingBottom)
            .padding(.top, headerPaddingTop)
            .frame(maxWidth: .infinity)
    }
    
    var actionFooter: some View {
        VStack(spacing: 0) {
            if let title {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(colors.customizable.onBackground)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, subtitle != nil ? actionFooterTitlePaddingBottomSmall : actionFooterTitlePaddingBottomLarge)
            }
            
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .foregroundStyle(colors.customizable.onBackground.opacity(0.5))
            }
            
            if let content {
                VStack(spacing: actionFooterContentSpacing) {
                    content(colors)
                }
                .padding(.top, subtitle != nil ? actionFooterContentPaddingTop : 0)
            }
        }
        .padding(.top, actionFooterTitlePaddingTop)
        .padding(.horizontal, actionFooterPaddingHorizontal)
        .padding(.bottom, content != nil ? actionFooterPaddingBottomSmall : actionFooterPaddingBottomLarge)
        .frame(maxWidth: .infinity)
        .background(
            colors.customizable.background
                .opacity(scheme == .dark ? darkModeOpacity : .one)
        )
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview("PositionInQueueView (with header visibility toggle)") {
    @Previewable @State var visibility = true
    
    VStack {
        ChatDefaultOverlayPreview {
            ChatDefaultOverlayView(
                title: "You are number X in line",
                subtitle: "Please hold, we'll be with you shortly. Your patience is appreciated!",
                cardImage: Asset.LiveChat.personWithClock,
                isHeaderVisible: $visibility
            )
        }
        .background(Color.black.opacity(.one))
        
        Spacer()
        
        Button("Toggle Header Visibility") {
            visibility.toggle()
        }
    }
    .environmentObject(ChatStyle())
}

#Preview("EndConversationView (No Agent)") {
    ChatDefaultOverlayPreview {
        ChatDefaultOverlayView(
            title: "This conversation was closed",
            subtitle: nil,
            cardImage: Asset.LiveChat.personWithClock
        ) { _ in
            Button("Start A New Chat") { }
                .buttonStyle(.primary)
            Button("Back To Conversation") { }
                .buttonStyle(.primary)
            Button("Close The Chat") { }
                .buttonStyle(.destructive)
        }
    }
}

#Preview("EndConversationView (with Agent)") {
    ChatDefaultOverlayPreview {
        ChatDefaultOverlayView(
            title: "You chatted with",
            subtitle: "Joal Arcos",
            cardImage: Asset.LiveChat.personWithClock
        ) { _ in
            Button("Start A New Chat") { }
                .buttonStyle(.primary)
            Button("Back To Conversation") { }
                .buttonStyle(.primary)
            Button("Close The Chat") { }
                .buttonStyle(.destructive)
        }
    }
}

#Preview("EndConversationView (with Agent)") {
    ChatDefaultOverlayPreview {
        ChatDefaultOverlayView(
            title: "We are currently offline",
            subtitle: "Please check back soon",
            cardImage: Asset.LiveChat.offline
        ) { _ in
            Button("Disconnect") { }
                .buttonStyle(.destructive)
        }
    }
}
