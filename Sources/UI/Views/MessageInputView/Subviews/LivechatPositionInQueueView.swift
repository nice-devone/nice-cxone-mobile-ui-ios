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

import Lottie
import SwiftUI

struct LivechatPositionInQueueView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        static let animationKeypath = "**.Stroke 1.Color"
        
        enum Sizing {
            static let cornerRadius: CGFloat = 16
            static let animationDimension: CGFloat = 34
        }
        enum Spacing {
            static let contentHorizontal: CGFloat = 16
            static let titleMessageVertical: CGFloat = 4
        }
        enum Padding {
            static let content: CGFloat = 16
            static let animation: CGFloat = 10
        }
    }
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var scheme
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    let positionInQueue: Int
    
    // MARK: - Init
    
    init(position: Int) {
        self.positionInQueue = position
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: Constants.Spacing.contentHorizontal) {
            hourglassAnimation
            
            VStack(alignment: .leading, spacing: Constants.Spacing.titleMessageVertical) {
                if positionInQueue > .zero {
                    Text(String(format: localization.liveChatQueueTitle, positionInQueue))
                        .fontWeight(.medium)
                        .foregroundStyle(colors.content.primary)
                }
                
                Text(localization.liveChatQueueSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(colors.content.secondary)
            }
            .multilineTextAlignment(.leading)
        }
        .padding(Constants.Padding.content)
        .background(
            RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                .fill(colors.background.surface.emphasis)
        )
    }
}

// MARK: - Subviews

private extension LivechatPositionInQueueView {

    var hourglassAnimation: some View {
        LottieView(animation: try? LottieAnimation.from(data: Asset.Images.lottieHourglass.data.data))
            .playing(loopMode: .loop)
            .valueProvider(
                ColorValueProvider(UIColor(colors.brand.onPrimary).lottieColorValue),
                for: AnimationKeypath(keypath: Constants.animationKeypath)
            )
            .frame(width: Constants.Sizing.animationDimension, height: Constants.Sizing.animationDimension)
            .padding(Constants.Padding.animation)
            .background {
                Circle()
                    .fill(colors.brand.primary)
            }
    }
}

// MARK: - Previews

#Preview {
    let localization = ChatLocalization()
    
    NavigationView {
        VStack {
            LivechatPositionInQueueView(position: 1)
                .padding(.horizontal, 16)
            
            Spacer()
            
            MessageInputView(
                attachmentRestrictions: MockData.attachmentRestrictions,
                isEditing: .constant(false),
                isInputEnabled: .constant(true),
                alertType: .constant(nil),
                localization: localization
            ) { _, _ in
                // Do nothing
            }
        }
        .navigationTitle("No Agent")
    }
    .environmentObject(ChatStyle())
    .environmentObject(localization)
}
