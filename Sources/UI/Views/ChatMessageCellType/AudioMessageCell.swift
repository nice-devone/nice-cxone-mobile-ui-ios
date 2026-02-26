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
            static let shareButtonMinLength: CGFloat = 0
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
    
    @ObservedObject var audioPlayer: AudioPlayer
    
    private let message: ChatMessage
    private let item: AttachmentItem
    private let position: MessageGroupPosition
    
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
            VStack(spacing: Constants.Spacing.elementsVertical) {
                progressBar

                controlButtons
            }
            .padding(.top, Constants.Padding.elementsTop)
            .padding(.horizontal, Constants.Padding.elementsHorizontal)
            .padding(.bottom, Constants.Padding.elementsBottom)
            .messageChatStyle(message, position: position)
            .shareable(message, attachments: [item], spacerLength: Constants.Spacing.shareButtonMinLength)
        }
    }
}

// MARK: - Subviews

private extension AudioMessageCell {

    var progressBar: some View {
        HStack(spacing: Constants.Spacing.progressBarElementsHorizontal) {
            Text(audioPlayer.formattedProgress)
                .font(.caption)
                .foregroundStyle(
                    message.isUserAgent
                        ? colors.content.primary
                        : colors.brand.onPrimary
                )
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            message.isUserAgent
                                ? colors.content.primary
                                : colors.brand.onPrimary
                        )
                        .opacity(Constants.Colors.progressBarOpacity)
                    
                    if proxy.size.width.isFinite && proxy.size.width > 0 {
                        Capsule()
                            .fill(message.isUserAgent ? colors.content.primary : colors.brand.onPrimary)
                            .frame(
                                width: getSafeProgressWidth(from: audioPlayer.progress, proxy: proxy),
                                height: Constants.Sizing.progressBarHeight
                            )
                    }
                }
            }
            .frame(height: Constants.Sizing.progressBarHeight)
            
            Text(audioPlayer.formattedDuration)
                .font(.caption)
                .foregroundStyle(
                    message.isUserAgent
                        ? colors.content.primary
                        : colors.brand.onPrimary
                )
        }
    }

    var controlButtons: some View {
        HStack(alignment: .center, spacing: Constants.Spacing.controlButtonsHorizontal) {
            Button {
                audioPlayer.seek(-Constants.seekValue)
            } label: {
                Asset.Attachment.rewind
                    .font(.title)
            }
            .foregroundStyle(
                message.isUserAgent
                    ? colors.content.primary
                    : colors.brand.onPrimary
            )
            .adjustForA11y()

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
            .foregroundStyle(
                message.isUserAgent
                    ? colors.content.primary
                    : colors.brand.onPrimary
            )
            .adjustForA11y()

            Button {
                audioPlayer.seek(Constants.seekValue)
            } label: {
                Asset.Attachment.advance
                    .font(.title)
            }
            .foregroundStyle(
                message.isUserAgent
                    ? colors.content.primary
                    : colors.brand.onPrimary
            )
            .adjustForA11y()
        }
    }
}

// MARK: - Private methods

private extension AudioMessageCell {

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
        
        return computedWidth.isFinite && computedWidth >= 0 ? computedWidth : 0
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
