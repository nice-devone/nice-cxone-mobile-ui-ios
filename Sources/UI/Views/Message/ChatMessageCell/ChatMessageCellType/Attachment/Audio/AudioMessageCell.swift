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

struct AudioMessageCell: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        static let seekValue = 10
        
        enum Sizing {
            static let progressBarHeight: CGFloat = 6
        }
        
        enum Spacing {
            static let elementsVertical: CGFloat = 0
            static let controlButtonsHorizontal: CGFloat = 20
            static let progressBarElementsHorizontal: CGFloat = 6
        }
        
        enum Padding {
            static let elementsTop: CGFloat = 14
            static let elementsHorizontal: CGFloat = 14
            static let elementsBottom: CGFloat = 8
        }
        
        enum Colors {
            static let progressBarOpacity: Double = 0.5
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @StateObject private var audioPlayer: AudioPlayer
    
    private let message: ChatMessage
    private let item: AttachmentItem
    private let position: MessageGroupPosition
    
    // MARK: - Init

    init(
        message: ChatMessage,
        item: AttachmentItem,
        position: MessageGroupPosition,
        alertType: Binding<ChatAlertType?>,
        audioPlayer: AudioPlayer? = nil
    ) {
        self.message = message
        self.item = item
        self.position = position

        // Previews and snapshot tests pass `.preview(...)` to render a deterministic duration
        // without downloading the attachment
        _audioPlayer = StateObject(
            wrappedValue: audioPlayer ?? Self.makeDefaultPlayer(item: item, alertType: alertType)
        )
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: Constants.Spacing.elementsVertical) {
            progressBar

            controlButtons
        }
        .padding(.top, Constants.Padding.elementsTop)
        .padding(.horizontal, Constants.Padding.elementsHorizontal)
        .padding(.bottom, Constants.Padding.elementsBottom)
        .messageChatStyle(message, position: position)
        .shareable(message, attachments: [item])
        .accessibilityElement(children: .contain)
        .task {
            await audioPlayer.prepare()
        }
    }
}

// MARK: - Subviews

private extension AudioMessageCell {

    var progressBar: some View {
        HStack(spacing: Constants.Spacing.progressBarElementsHorizontal) {
            Text(audioPlayer.formattedProgress)
                .font(.caption)
                .foregroundStyle(colors.bubbleForeground(isUserAgent: message.isUserAgent))
                .accessibilityHidden(true)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(colors.bubbleForeground(isUserAgent: message.isUserAgent))
                        .opacity(Constants.Colors.progressBarOpacity)

                    if proxy.size.width.isFinite && proxy.size.width > 0 {
                        Capsule()
                            .fill(colors.bubbleForeground(isUserAgent: message.isUserAgent))
                            .frame(
                                width: getSafeProgressWidth(from: audioPlayer.progress, proxy: proxy),
                                height: Constants.Sizing.progressBarHeight
                            )
                    }
                }
            }
            .frame(height: Constants.Sizing.progressBarHeight)
            .accessibilityHidden(true)

            Text(audioPlayer.formattedDuration)
                .font(.caption)
                .foregroundStyle(colors.bubbleForeground(isUserAgent: message.isUserAgent))
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.Audio.SeekBar.identifier)
        .accessibilityLabel(A11y.Conversation.MessageCell.Audio.SeekBar.label)
        .accessibilityValue(
            A11y.Conversation.MessageCell.Audio.SeekBar.value(
                String.formattedAudioLengthForA11y(audioPlayer.currentTimeInSeconds),
                String.formattedAudioLengthForA11y(audioPlayer.duration)
            )
        )
        .accessibilityHint(A11y.Conversation.MessageCell.Audio.SeekBar.hint)
        .accessibilityAddTraits(.updatesFrequently)
    }

    var controlButtons: some View {
        HStack(alignment: .center, spacing: Constants.Spacing.controlButtonsHorizontal) {
            Button {
                audioPlayer.seek(-Constants.seekValue)
            } label: {
                Asset.Attachment.rewind
                    .font(.title)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(colors.bubbleForeground(isUserAgent: message.isUserAgent))
            .adjustForA11y()
            .accessibilityIdentifier(A11y.Conversation.MessageCell.Audio.ButtonRewind.identifier)
            .accessibilityLabel(A11y.Conversation.MessageCell.Audio.ButtonRewind.label)
            .accessibilityHint(A11y.Conversation.MessageCell.Audio.ButtonRewind.hint(Constants.seekValue))

            Button {
                if audioPlayer.isPlaying {
                    audioPlayer.pause()
                } else {
                    audioPlayer.play()
                }
            } label: {
                (audioPlayer.isPlaying ? Asset.Attachment.pause : Asset.Attachment.play)
                    .font(.title)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(colors.bubbleForeground(isUserAgent: message.isUserAgent))
            .adjustForA11y()
            .accessibilityIdentifier(
                audioPlayer.isPlaying
                    ? A11y.Conversation.MessageCell.Audio.ButtonPause.identifier
                    : A11y.Conversation.MessageCell.Audio.ButtonPlay.identifier
            )
            .accessibilityLabel(
                audioPlayer.isPlaying
                    ? A11y.Conversation.MessageCell.Audio.ButtonPause.label
                    : A11y.Conversation.MessageCell.Audio.ButtonPlay.label
            )
            .accessibilityHint(
                audioPlayer.isPlaying
                    ? A11y.Conversation.MessageCell.Audio.ButtonPause.hint
                    : A11y.Conversation.MessageCell.Audio.ButtonPlay.hint
            )

            Button {
                audioPlayer.seek(Constants.seekValue)
            } label: {
                Asset.Attachment.advance
                    .font(.title)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(colors.bubbleForeground(isUserAgent: message.isUserAgent))
            .adjustForA11y()
            .accessibilityIdentifier(A11y.Conversation.MessageCell.Audio.ButtonAdvance.identifier)
            .accessibilityLabel(A11y.Conversation.MessageCell.Audio.ButtonAdvance.label)
            .accessibilityHint(A11y.Conversation.MessageCell.Audio.ButtonAdvance.hint(Constants.seekValue))
        }
    }
}

// MARK: - Private methods

private extension AudioMessageCell {

    /// Builds the player used when the call site doesn't inject one.
    ///
    /// `ChatMessageCell` and `MultipleAttachmentsContainer` render audio attachments as part of a
    /// composite cell and have no player to forward, so inside `XCPreviewAgent` this falls back to the
    /// preview player. Without it those canvases download the fixture on every render and sit at
    /// `00:00` whenever the preview host is offline or the fixture URL has rotated.
    static func makeDefaultPlayer(item: AttachmentItem, alertType: Binding<ChatAlertType?>) -> AudioPlayer {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return .preview(item: item, alertType: alertType)
        }
        #endif

        return AudioPlayer(url: item.url, fileName: item.fileName, alertType: alertType)
    }

    /// Computes a safe, finite width for the progress bar fill.
    ///
    /// This method clamps the provided `progress` value to the 0...1 range and
    /// multiplies it by the available width from the provided `GeometryProxy`.
    /// It guards against non-finite and negative values to prevent invalid frame
    /// dimensions that can cause SwiftUI runtime warnings or crashes.
    ///
    /// - Parameters:
    ///   - progress: The raw playback progress in the range 0...1. Values outside
    ///     this range or non-finite values are clamped/treated as 0.
    ///   - proxy: The `GeometryProxy` providing the available width for the
    ///     progress bar.
    ///     
    /// - Returns: A non-negative, finite `CGFloat` representing the width of the
    ///   filled portion of the progress bar. Returns 0 if the computed width is
    ///   non-finite or negative.
    func getSafeProgressWidth(from progress: Double, proxy: GeometryProxy) -> CGFloat {
        let rawProgress = CGFloat(progress)
        let clampedProgress = rawProgress.isFinite ? max(0, min(1, rawProgress)) : 0
        let computedWidth = proxy.size.width * clampedProgress
        
        return computedWidth.finiteNonNegative
    }
}

#if DEBUG

// MARK: - Previews

#Preview {
    VStack(spacing: 4) {
        AudioMessageCell(
            message: MockData.audioMessage(user: MockData.customer),
            item: MockData.audioItem,
            position: .single,
            alertType: .constant(nil),
            audioPlayer: .preview()
        )

        AudioMessageCell(
            message: MockData.audioMessage(user: MockData.agent),
            item: MockData.audioItem,
            position: .single,
            alertType: .constant(nil),
            audioPlayer: .preview()
        )
    }
    .padding(.horizontal, 10)
    .environmentObject(ChatStyle())
}

#endif
