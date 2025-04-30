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

import AVFoundation
import AVKit
import SwiftUI

struct VideoMessageCell: View, Themed {

    // MARK: - Properties
    
    @StateObject private var viewModel: VideoMessageCellViewModel

    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization

    @Environment(\.colorScheme) var scheme

    @State private var isVideoSheetVisible = false
    
    private let displayMode: VideoThumbnailDisplayMode
    private let message: ChatMessage
    private let position: MessageGroupPosition
    
    // MARK: - Init
    
    init(
        message: ChatMessage,
        item: AttachmentItem,
        displayMode: VideoThumbnailDisplayMode,
        position: MessageGroupPosition,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        self.message = message
        self.displayMode = displayMode
        _viewModel = StateObject(wrappedValue: VideoMessageCellViewModel(item: item, alertType: alertType, localization: localization))
        self.position = position
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: message.isUserAgent ? .bottomLeading : .bottomTrailing) {
            if viewModel.isLoading {
                AttachmentLoadingView(title: localization.loadingVideo)
                    .frame(width: displayMode.width, height: displayMode.height)
            } else {
                VideoThumbnailView(
                    url: viewModel.cachedVideoURL,
                    displayMode: displayMode
                )
                .sheet(isPresented: $isVideoSheetVisible) {
                    if let videoURL = viewModel.cachedVideoURL {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                    }
                }
                .onTapGesture {
                    isVideoSheetVisible = true
                }
            }
        }
        .if(displayMode == .large) { view in
            view
                .messageChatStyle(message, position: position)
                .shareable(message, attachments: [viewModel.item], spacerLength: 0)
        }
    }
}

// MARK: - Preview

#Preview {
    let localization = ChatLocalization()
    
    VStack(spacing: 4) {
        VideoMessageCell(
            message: MockData.videoMessage(user: MockData.agent),
            item: MockData.videoItem,
            displayMode: .large,
            position: .single,
            alertType: .constant(nil),
            localization: localization
        )

        VideoMessageCell(
            message: MockData.videoMessage(user: MockData.customer),
            item: MockData.videoItem,
            displayMode: .large,
            position: .single,
            alertType: .constant(nil),
            localization: localization
        )
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
}
