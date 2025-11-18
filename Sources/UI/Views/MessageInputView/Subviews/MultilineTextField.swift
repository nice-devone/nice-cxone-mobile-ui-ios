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

@available(iOS 16.0, *)
struct MultilineTextField: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        static let editingTimerInternalDelay: TimeInterval = 1.0
        static let typingTimeoutThreshold = 3
        
        enum Sizing {
            static let lineLimit = 6
        }
        
        enum Padding {
            static let content: CGFloat = 8
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @Binding var text: String
    @Binding var isEditing: Bool
    
    @State private var timer: Timer?
    @State private var textInputWaitTime = 0
    
    // MARK: - Builder
    
    var body: some View {
        TextField(text: $text, axis: .vertical) {
            Text(localization.chatMessageInputPlaceholder)
                .font(.body)
                .foregroundStyle(colors.content.tertiary)
        }
        .foregroundStyle(colors.content.primary)
        .lineLimit(Constants.Sizing.lineLimit)
        .padding(Constants.Padding.content)
        .onChange(of: text) { _ in
            if timer != nil {
                if textInputWaitTime > .zero {
                    textInputWaitTime = .zero
                }
            } else {
                isEditing = true
                
                self.timer = Timer.scheduledTimer(withTimeInterval: Constants.editingTimerInternalDelay, repeats: true) { _ in
                    textInputWaitTime += 1
                    
                    if self.textInputWaitTime >= Constants.typingTimeoutThreshold {
                        self.timer?.invalidate()
                        self.timer = nil
                        
                        self.isEditing = false
                        self.textInputWaitTime = .zero
                    }
                }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var message = ""
    @Previewable @State var isEditing = false
    
    VStack {
        Spacer()
        
        MultilineTextField(text: $message, isEditing: $isEditing)
            .padding(20)
            .environmentObject(ChatStyle())
            .environmentObject(ChatLocalization())
    }
}
