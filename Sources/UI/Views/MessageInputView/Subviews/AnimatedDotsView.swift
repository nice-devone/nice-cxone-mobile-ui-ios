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

struct AnimatedDotsView: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var dotsCount = 1

    let text: String
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: 0) {
            Text(text)
                .truncationMode(.tail)
            
            Text(String(repeating: ".", count: dotsCount))
        }
        .foregroundColor(colors.customizable.onBackground.opacity(0.5))
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            dotsCount = (dotsCount + 1) % 4
        }
    }
}

// MARK: - Previews

#Preview {
    let localization = ChatLocalization()
    
    AnimatedDotsView(text: localization.chatMessageInputAudioRecorderRecording)
        .environmentObject(localization)
        .environmentObject(ChatStyle())
}
