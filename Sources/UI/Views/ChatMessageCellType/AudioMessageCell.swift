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

struct AudioMessageCell: View, Themed {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var audioPlayer: AudioPlayer
    
    private let message: ChatMessage
    private let item: AttachmentItem
    private let position: MessageGroupPosition
    
    static let progressBarHeight: CGFloat = 6
    static let controlButtonsSpacing: CGFloat = 20
    static let paddingTop: CGFloat = 14
    static let paddingHorizontal: CGFloat = 14
    static let paddingBottom: CGFloat = 8
    static let progressBarElementsSpacing: CGFloat = 6
    
    // MARK: - Init

    init(message: ChatMessage, item: AttachmentItem, position: MessageGroupPosition, alertType: Binding<ChatAlertType?>, localization: ChatLocalization) {
        self.message = message
        self.item = item
        self.position = position
        
        self.audioPlayer = AudioPlayer(url: item.url, fileName: item.fileName, alertType: alertType, chatLocalization: localization)
        self.audioPlayer.prepare()
    }

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: message.isUserAgent ? .bottomLeading : .bottomTrailing) {
            VStack(spacing: 0) {
                progressBar

                controlButtons
            }
            .padding(.top, Self.paddingTop)
            .padding(.horizontal, Self.paddingHorizontal)
            .padding(.bottom, Self.paddingBottom)
            .messageChatStyle(message, position: position)
            .shareable(message, attachments: [item], spacerLength: 0)
        }
    }
}

// MARK: - Subviews

private extension AudioMessageCell {

    var progressBar: some View {
        HStack(spacing: Self.progressBarElementsSpacing) {
            Text(audioPlayer.formattedProgress)
                .font(.caption)
                .foregroundColor(
                    message.isUserAgent
                    ? colors.customizable.agentText
                    : colors.customizable.customerText
                )
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            message.isUserAgent
                            ? colors.customizable.agentText
                            : colors.customizable.customerText
                        )
                        .opacity(0.5)
                    
                    if !audioPlayer.progress.isNaN {
                        Capsule()
                            .fill(message.isUserAgent ? colors.customizable.agentText : colors.customizable.customerText)
                            .frame(
                                width: proxy.size.width * CGFloat(audioPlayer.progress),
                                height: Self.progressBarHeight
                            )
                    }
                }
            }
            .frame(height: Self.progressBarHeight)
            
            Text(audioPlayer.formattedDuration)
                .font(.caption)
                .foregroundColor(
                    message.isUserAgent
                    ? colors.customizable.agentText
                    : colors.customizable.customerText
                )
        }
    }

    var controlButtons: some View {
        HStack(alignment: .center, spacing: Self.controlButtonsSpacing) {
            Button {
                audioPlayer.seek(-10)
            } label: {
                Asset.Attachment.rewind
                    .font(.title)
            }
            .foregroundColor(
                message.isUserAgent
                    ? colors.customizable.agentText
                    : colors.customizable.customerText
            )
            .frame(
                width: StyleGuide.buttonDimension,
                height: StyleGuide.buttonDimension
            )

            Button {
                if audioPlayer.isPlaying {
                    audioPlayer.pause()
                } else {
                    audioPlayer.play()
                }
            } label: {
                (audioPlayer.isPlaying ? Asset.Attachment.pause : Asset.Attachment.play)
                    .font(.title)
            }
            .foregroundColor(
                message.isUserAgent
                    ? colors.customizable.agentText
                    : colors.customizable.customerText
            )
            .frame(
                width: StyleGuide.buttonDimension,
                height: StyleGuide.buttonDimension
            )

            Button {
                audioPlayer.seek(10)
            } label: {
                Asset.Attachment.advance
                    .font(.title)
            }
            .foregroundColor(
                message.isUserAgent
                    ? colors.customizable.agentText
                    : colors.customizable.customerText
            )
            .frame(
                width: StyleGuide.buttonDimension,
                height: StyleGuide.buttonDimension
            )
        }
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 4) {
        AudioMessageCell(
            message: MockData.audioMessage(user: MockData.customer),
            item: MockData.audioItem,
            position: .single,
            alertType: .constant(nil),
            localization: ChatLocalization()
        )
        
        AudioMessageCell(
            message: MockData.audioMessage(user: MockData.agent),
            item: MockData.audioItem,
            position: .single,
            alertType: .constant(nil),
            localization: ChatLocalization()
        )
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
}
