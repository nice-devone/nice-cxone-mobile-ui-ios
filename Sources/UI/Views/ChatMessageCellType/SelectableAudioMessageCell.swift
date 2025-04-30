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

struct SelectableAudioMessageCell: View, Themed {

    // MARK: - Properties

    @ObservedObject private var attachmentsViewModel: AttachmentsViewModel
    @ObservedObject private var audioPlayer: AudioPlayer

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme

    @Binding private var inSelectionMode: Bool

    private let item: SelectableAttachment
    
    static private let audioCellControlButtonSize: CGFloat = 10
    static private let selectableAudioCellProgressBarHeight: CGFloat = 6
    static private let selectableCircleEdgePadding: CGFloat = 10
    static private let progressBarBottomPadding: CGFloat = 14
    static private let playButtonHorizontalPadding: CGFloat = 35

    private var width: CGFloat {
        UIScreen.main.messageCellWidth
    }
    
    // MARK: - Init

    init(
        item: SelectableAttachment,
        attachmentsViewModel: AttachmentsViewModel,
        inSelectionMode: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization
    ) {
        self.attachmentsViewModel = attachmentsViewModel
        self.item = item
        self._inSelectionMode = inSelectionMode
        self.audioPlayer = AudioPlayer(
            url: AttachmentItemMapper.map(item.messageType)?.url ?? URL(fileURLWithPath: ""), 
            fileName: AttachmentItemMapper.map(item.messageType)?.fileName ?? "",
            alertType: alertType,
            chatLocalization: localization
        )
        self.audioPlayer.prepare()
    }

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                progressBarContainer
                    .padding(.top, StyleGuide.Message.paddingVertical)
                    .padding(.horizontal, StyleGuide.Message.paddingHorizontal)
                    .padding(.bottom, Self.progressBarBottomPadding)
                
                controlButtons
            }
            .frame(width: width, height: width)
            .background(colors.customizable.agentBackground)
            .cornerRadius(StyleGuide.Message.cornerRadius, corners: .allCorners)
            .onTapGesture {
                if inSelectionMode {
                    attachmentsViewModel.selectAttachment(uuid: item.id)
                }
            }

            if inSelectionMode {
                SelectableCircle(isSelected: item.isSelected)
                    .padding([.top, .trailing], Self.selectableCircleEdgePadding)
            }
        }
        .onAppear(perform: audioPlayer.prepare)
    }
}

// MARK: - Subviews

private extension SelectableAudioMessageCell {

    var progressBarContainer: some View {
        HStack {
            startingCounter
            
            progressBarIndicator
            
            countdownTimer
        }
    }
    
    var progressBarIndicator: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(colors.customizable.customerText)
                    
                    if !audioPlayer.progress.isNaN {
                        Capsule()
                            .fill(colors.customizable.agentText)
                            .frame(
                                width: proxy.size.width * CGFloat(audioPlayer.progress),
                                height: Self.selectableAudioCellProgressBarHeight
                            )
                    }
                }
            }
            .frame( height: Self.selectableAudioCellProgressBarHeight)
        }
    }
    
    var startingCounter: some View {
        Text(audioPlayer.formattedProgress)
            .font(.caption)
            .foregroundColor(colors.customizable.agentText)
    }
    
    var countdownTimer: some View {
        Text(audioPlayer.formattedDuration)
            .font(.caption)
            .foregroundColor(colors.customizable.agentText)
    }

    var controlButtons: some View {
        HStack {
            rewindButton

            playPauseButton

            fwdButton
        }
    }
    
    var rewindButton: some View {
        Button {
            audioPlayer.seek(-10)
        } label: {
            Asset.Attachment.rewind
                .imageScale(.large)
        }
        .frame(
            width: Self.audioCellControlButtonSize,
            height: Self.audioCellControlButtonSize
        )
        .foregroundColor(colors.customizable.agentText)
    }
    
    var playPauseButton: some View {
        Button {
            if inSelectionMode {
                attachmentsViewModel.selectAttachment(uuid: item.id)
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
        .frame(
            width: Self.audioCellControlButtonSize,
            height: Self.audioCellControlButtonSize
        )
        .foregroundColor(colors.customizable.agentText)
        .padding(.horizontal, Self.playButtonHorizontalPadding)
    }
    
    var fwdButton: some View {
        Button {
            audioPlayer.seek(10)
        } label: {
            Asset.Attachment.advance
                .imageScale(.large)
        }
        .frame(
            width: Self.audioCellControlButtonSize,
            height: Self.audioCellControlButtonSize
        )
        .foregroundColor(colors.customizable.agentText)
    }
}

// MARK: - Preview

#Preview {
    SelectableAudioMessageCell(
        item: MockData.selectableAudioAttachment,
        attachmentsViewModel: AttachmentsViewModel(messageTypes: []),
        inSelectionMode: .constant(false),
        alertType: .constant(nil),
        localization: ChatLocalization()
    )
    .environmentObject(ChatStyle())
}
