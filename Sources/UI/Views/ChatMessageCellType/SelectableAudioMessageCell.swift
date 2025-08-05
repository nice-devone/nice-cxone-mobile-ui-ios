//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

struct SelectableAudioMessageCell: View {

    // MARK: - Properties

    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel
    @ObservedObject private var audioPlayer: AudioPlayer

    @EnvironmentObject private var style: ChatStyle

    @Binding private var inSelectionMode: Bool

    private let item: SelectableAttachment

    private var width: CGFloat {
        UIScreen.main.messageCellWidth
    }
    
    // MARK: - Init

    init(
        item: SelectableAttachment,
        attachmentsViewModel: AttachmentsViewModel,
        inSelectionMode: Binding<Bool>
    ) {
        self.attachmentsViewModel = attachmentsViewModel
        self.item = item
        self._inSelectionMode = inSelectionMode
        self.audioPlayer = AudioPlayer(
            url: AttachmentItemMapper.map(item.messageType)?.url ?? URL(fileURLWithPath: ""), 
            fileName: AttachmentItemMapper.map(item.messageType)?.fileName ?? ""
        )
        self.audioPlayer.prepare()
    }

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                progressBar
                    .padding(.top, StyleGuide.Message.paddingVertical)
                    .padding(.horizontal, StyleGuide.Message.paddingHorizontal)
                
                controlButtons
            }
            .frame(width: width, height: width)
            .background(style.agentCellColor)
            .cornerRadius(StyleGuide.Message.cornerRadius, corners: .allCorners)
            .onTapGesture {
                if inSelectionMode {
                    attachmentsViewModel.selectAttachment(with: item.id)
                }
            }

            if inSelectionMode {
                SelectableCircle(isSelected: item.isSelected)
                    .padding([.top, .trailing], 10)
            }
        }
        .onAppear(perform: audioPlayer.prepare)
    }
}

// MARK: - Subviews

private extension SelectableAudioMessageCell {

    var progressBar: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray3))

                    if !audioPlayer.progress.isNaN {
                        Capsule()
                            .fill(style.agentFontColor)
                            .frame(width: proxy.size.width * CGFloat(audioPlayer.progress), height: 4)
                    }
                }
            }
            .frame( height: 4)

            HStack {
                Text(audioPlayer.formattedProgress)
                    .font(.caption)
                    .foregroundColor(style.agentFontColor)

                Spacer()

                Text(audioPlayer.formattedDuration)
                    .font(.caption)
                    .foregroundColor(style.agentFontColor)
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
                    .imageScale(.large)
            }
            .frame(width: 44, height: 44)
            .foregroundColor(style.agentFontColor)

            Button {
                if inSelectionMode {
                    attachmentsViewModel.selectAttachment(with: item.id)
                } else {
                    if audioPlayer.isPlaying {
                        audioPlayer.pause()
                    } else {
                        audioPlayer.play()
                    }
                }

            } label: {
                (audioPlayer.isPlaying ? Asset.Attachment.pause : Asset.Attachment.play)
                    .imageScale(.large)
            }
            .frame(width: 44, height: 44)
            .foregroundColor(style.agentFontColor)

            Button {
                audioPlayer.seek(10)
            } label: {
                Asset.Attachment.advance
                    .imageScale(.large)
            }
            .frame(width: 44, height: 44)
            .foregroundColor(style.agentFontColor)
        }
    }
}

// MARK: - Preview

struct SelectableAudioMessageCell_Previews: PreviewProvider {
    
    static let viewModel = AttachmentsViewModel(messageTypes: [])

    static var previews: some View {
        Group {
            SelectableAudioMessageCell(item: MockData.selectableAudioAttachment, attachmentsViewModel: viewModel, inSelectionMode: .constant(false))
                .previewDisplayName("Light Mode")

            SelectableAudioMessageCell(item: MockData.selectableAudioAttachment, attachmentsViewModel: viewModel, inSelectionMode: .constant(false))
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
