//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

struct AudioMessageCell: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle

    @ObservedObject var audioPlayer: AudioPlayer

    private let message: ChatMessage
    private let item: AttachmentItem
    private let isMultiAttachment: Bool
    
    static private let buttonDimension: CGFloat  = 44

    // MARK: - Init

    init(message: ChatMessage, item: AttachmentItem, isMultiAttachment: Bool) {
        self.message = message
        self.item = item
        self.isMultiAttachment = isMultiAttachment
        self.audioPlayer = AudioPlayer(url: item.url, fileName: item.fileName)
        self.audioPlayer.prepare()
    }

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: message.user.isAgent ? .bottomLeading : .bottomTrailing) {
            VStack {
                progressBar

                controlButtons
            }
            .padding(.top, 10)
            .padding(.horizontal, isMultiAttachment ? 0 : 12)
            .background(message.user.isAgent ? style.agentCellColor : style.customerCellColor)
            .cornerRadius(14, corners: .allCorners)
            .if(isMultiAttachment) { view in
                view.frame(width: MultipleAttachmentContainer.cellDimension, height: MultipleAttachmentContainer.cellDimension)
            }
            .if(!isMultiAttachment) { view in
                view.shareable(message, attachments: [item], spacerLength: 0)
            }
        }
        .padding(.leading, isMultiAttachment ? 0 : 14)
        .padding(.trailing, isMultiAttachment ? 0 : 4)
        .padding(.bottom, isMultiAttachment ? 0 : message.user.isAgent ? 14 : 0)
    }
}

// MARK: - Subviews

private extension AudioMessageCell {

    var progressBar: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray3))

                    if !audioPlayer.progress.isNaN {
                        Capsule()
                            .fill(message.user.isAgent ? style.agentFontColor : style.customerFontColor)
                            .if(!audioPlayer.progress.isNaN) { view in
                                view.frame(width: proxy.size.width * CGFloat(audioPlayer.progress), height: 4)
                            }
                    }
                }
            }
            .frame(height: 4)

            HStack {
                Text(audioPlayer.formattedProgress)
                    .font(.caption)
                    .foregroundColor(message.user.isAgent ? style.agentFontColor : style.customerFontColor)

                Spacer()

                Text(audioPlayer.formattedDuration)
                    .font(.caption)
                    .foregroundColor(message.user.isAgent ? style.agentFontColor : style.customerFontColor)
            }
            .offset(y: 12)
        }
    }

    var controlButtons: some View {
        HStack {
            Button {
                audioPlayer.seek(-10)
            } label: {
                Asset.Attachment.rewind
                    .imageScale(isMultiAttachment ? .medium : .large)
            }
            .foregroundColor(message.user.isAgent ? style.agentFontColor : style.customerFontColor)
            .frame(width: Self.buttonDimension, height: Self.buttonDimension)

            Button {
                if audioPlayer.isPlaying {
                    audioPlayer.pause()
                } else {
                    audioPlayer.play()
                }
            } label: {
                (audioPlayer.isPlaying ? Asset.Attachment.pause : Asset.Attachment.play)
                    .imageScale(isMultiAttachment ? .medium : .large)
            }
            .foregroundColor(message.user.isAgent ? style.agentFontColor : style.customerFontColor)
            .frame(width: Self.buttonDimension, height: Self.buttonDimension)

            Button {
                audioPlayer.seek(10)
            } label: {
                Asset.Attachment.advance
                    .imageScale(isMultiAttachment ? .medium : .large)
            }
            .foregroundColor(message.user.isAgent ? style.agentFontColor : style.customerFontColor)
            .frame(width: Self.buttonDimension, height: Self.buttonDimension)
        }
    }
}

// MARK: - Preview

struct AudioMessageCell_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            VStack(spacing: 4) {
                AudioMessageCell(message: MockData.audioMessage(user: MockData.customer), item: MockData.audioItem, isMultiAttachment: true)

                AudioMessageCell(message: MockData.audioMessage(user: MockData.agent), item: MockData.audioItem, isMultiAttachment: false)
            }
            .previewDisplayName("Light Mode")

            VStack(spacing: 4) {
                AudioMessageCell(message: MockData.audioMessage(user: MockData.customer), item: MockData.audioItem, isMultiAttachment: false)

                AudioMessageCell(message: MockData.audioMessage(user: MockData.agent), item: MockData.audioItem, isMultiAttachment: false)
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
