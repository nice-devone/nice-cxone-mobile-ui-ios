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

    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let shareButtonMinLength: CGFloat = 0
        }
    }
    
    // MARK: - Properties
    
    @StateObject private var viewModel: VideoMessageCellViewModel

    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization

    @Environment(\.colorScheme) var scheme

    @State private var isVideoSheetVisible = false
    
    private let displayMode: AttachmentThumbnailDisplayMode = .regular
    private let message: ChatMessage
    private let position: MessageGroupPosition?
    
    // MARK: - Init
    
    init(
        message: ChatMessage,
        item: AttachmentItem,
        position: MessageGroupPosition? = nil,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        self.message = message
        self.position = position
        self._viewModel = StateObject(wrappedValue: VideoMessageCellViewModel(item: item, alertType: alertType, localization: localization))
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: message.isUserAgent ? .bottomLeading : .bottomTrailing) {
            if viewModel.isLoading {
                AttachmentLoadingView(
                    title: localization.loadingVideo,
                    width: displayMode.size.width,
                    height: displayMode.size.height
                )
            } else {
                Button {
                    isVideoSheetVisible = true
                } label: {
                    VideoThumbnailView(
                        url: viewModel.cachedVideoURL,
                        displayMode: displayMode
                    )
                }
                .sheet(isPresented: $isVideoSheetVisible) {
                    if let videoURL = viewModel.cachedVideoURL {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                    }
                }
            }
        }
        .ifNotNil(position) { view, position in
            view
                .messageChatStyle(message, position: position)
                .shareable(message, attachments: [viewModel.item], spacerLength: Constants.Spacing.shareButtonMinLength)
        }
    }
}

// MARK: - Preview

#Preview("Single") {
    let localization = ChatLocalization()
    
    ScrollView {
        VStack(spacing: 4) {
            VideoMessageCell(
                message: MockData.videoMessage(user: MockData.agent),
                item: MockData.videoItem,
                position: .single,
                alertType: .constant(nil),
                localization: localization
            )

            VideoMessageCell(
                message: MockData.videoMessage(user: MockData.customer),
                item: MockData.videoItem,
                position: .single,
                alertType: .constant(nil),
                localization: localization
            )
            
            VStack(spacing: 4) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    position: .first,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    position: .inside,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    position: .last,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
            
            VStack(spacing: 4) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    position: .first,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    position: .inside,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    position: .last,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
        }
        .padding(.horizontal, 16)
    }
    .environmentObject(ChatStyle())
    .environmentObject(localization)
}

@available(iOS 17, *)
#Preview("Multiple") {
    @Previewable @Environment(\.colorScheme) var scheme
    
    let style = ChatStyle()
    let localization = ChatLocalization()
    VStack {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
            
            HStack(spacing: 12) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.agent),
                    item: MockData.videoItem,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.colors(for: scheme).background.surface.default)
        )
        
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
            
            HStack(spacing: 12) {
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    alertType: .constant(nil),
                    localization: localization
                )
                
                VideoMessageCell(
                    message: MockData.videoMessage(user: MockData.customer),
                    item: MockData.videoItem,
                    alertType: .constant(nil),
                    localization: localization
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(style.colors(for: scheme).brand.primary)
        )
    }
    .environmentObject(style)
    .environmentObject(localization)
}
