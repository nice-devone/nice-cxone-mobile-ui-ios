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

import AVFoundation
import Combine
import SwiftUI

struct VideoPlayerContainer: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @ObservedObject private var viewModel: VideoPlayerContainerModel
    
    @Environment(\.colorScheme) private var scheme
    
    @Binding var isPresented: Bool
    
    private static let controlButtonSize: CGFloat = 30
    
    // MARK: - Init
    
    init(videoUrl: URL, isPresented: Binding<Bool>) {
        self.viewModel = VideoPlayerContainerModel(videoUrl: videoUrl)
        self._isPresented = isPresented
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                
                VideoPlayer(url: viewModel.videoUrl, play: $viewModel.play, time: $viewModel.time)
                    .mute(viewModel.mute)
                    .onStateChanged(viewModel.onStateChanged)
                    .frame(maxWidth: .infinity, maxHeight: UIDevice.isLandscape ? .infinity : UIScreen.main.bounds.width)
                
                Spacer()
            }
            .onDisappear {
                viewModel.play = false
            }
            
            videoOverlay
                .onAppear {
                    viewModel.showOverlay.toggle()
                }
        }
        .background(style.backgroundColor)
        .onTapGesture {
            withAnimation {
                viewModel.showOverlay.toggle()
            }
        }
    }
}

// MARK: - Subviews

private extension VideoPlayerContainer {
    
    var controlButtonView: some View {
        (scheme == .dark ? Color.white : Color.black).opacity(0.2)
            .cornerRadius(StyleGuide.Message.cornerRadius)
            .frame(width: 50, height: 40)
    }
    
    var closeButton: some View {
        controlButtonView
            .overlay(
                Asset.close
                    .font(Font.body.weight(.semibold))
                    .padding()
                    .foregroundColor(.white)
            )
            .onTapGesture {
                isPresented = false
            }
    }
    
    var muteButton: some View {
        controlButtonView
            .overlay(
                (viewModel.mute ? Asset.Attachment.mute : Asset.Attachment.unmute)
                    .font(Font.body.weight(.semibold))
                    .padding()
                    .foregroundColor(.white)
            )
            .onTapGesture {
                viewModel.mute.toggle()
            }
    }
    
    var videoOverlay: some View {
        VStack(spacing: 0) {
            HStack {
                closeButton
                
                Spacer()
                
                muteButton
            }
            .padding([.leading, .top, .trailing], 10)
            
            Spacer()
            
            videoControlView
        }
        .padding(10)
        .opacity(viewModel.showOverlay ? 1 : 0)
    }
    
    var videoControlView: some View {
        VStack(spacing: 0) {
            durationSliderView
            
            HStack {
                Text(viewModel.formattedTime)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(viewModel.formattedDuration)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .font(.footnote)
            
            HStack {
                Asset.Attachment.rewind
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: Self.controlButtonSize, height: Self.controlButtonSize)
                    .onTapGesture(perform: viewModel.onRewind)
                
                Spacer()
                
                (viewModel.play ? Asset.Attachment.pauseCircle : Asset.Attachment.playCircle)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: Self.controlButtonSize, height: Self.controlButtonSize)
                    .onTapGesture {
                        viewModel.play.toggle()
                    }
                
                Spacer()
                
                Asset.Attachment.advance
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: Self.controlButtonSize, height: Self.controlButtonSize)
                    .onTapGesture(perform: viewModel.onAdvance)
            }
            .padding(.top, 10)
            .padding(.horizontal, 14)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.Message.cornerRadius)
                .fill((scheme == .dark ? Color.white : Color.black).opacity(0.2))
        )
    }
    
    var durationSliderView: some View {
        Slider(
            value: Binding(
                get: { viewModel.time.seconds },
                set: { viewModel.time = CMTimeMakeWithSeconds($0, preferredTimescale: viewModel.time.timescale) }
            ),
            in: 0...viewModel.totalDuration
        )
        .padding(.horizontal)
        .accentColor(.gray)
        .gesture(DragGesture())
    }
}

// MARK: - Preview

struct VideoPlayerContainer_Previews: PreviewProvider {
    
    @ObservedObject private static var viewModel = VideoMessageCellViewModel(item: MockData.videoItem)
    
    static var previews: some View {
        Group {
            VStack {
                if let cachedUrl = viewModel.cachedVideoURL {
                    VideoPlayerContainer(videoUrl: cachedUrl, isPresented: .constant(true))
                        .onAppear {
                            Task { @MainActor in
                                await viewModel.cacheVideoFromURL()
                            }
                        }
                } else {
                    Text("Caching URL...")
                }
            }
            .previewDisplayName("Light Mode")
            
            VStack {
                if let cachedUrl = viewModel.cachedVideoURL {
                    VideoPlayerContainer(videoUrl: cachedUrl, isPresented: .constant(true))
                        .onAppear {
                            Task { @MainActor in
                                await viewModel.cacheVideoFromURL()
                            }
                        }
                } else {
                    Text("Caching URL...")
                }
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatStyle())
    }
}
