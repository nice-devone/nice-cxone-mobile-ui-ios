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

import CXoneChatSDK
import SwiftUI

struct ChatListCell: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @State private var offset = CGFloat.zero
    
    let title: String
    let message: String?
    let showDeleteButton: Bool
    let onDelete: (() -> Void)?
    
    private var initials: String {
        title
            .components(separatedBy: .whitespaces)
            .reduce(into: "") { result, name in
                if let character = name.first {
                    result += String(character)
                } else {
                    result += ""
                }
            }
    }
    
    // MARK: - Init
    
    init(title: String, message: String?, showDeleteButton: Bool = false, onDelete: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.showDeleteButton = showDeleteButton
        self.onDelete = onDelete
    }
    
    // MARK: - Content

    var body: some View {
        ZStack {
            if showDeleteButton, #unavailable(iOS 16) {
                HStack {
                    Spacer()
                    Button(localization.commonDelete) {
                        self.onDelete?()
                        withAnimation {
                            self.offset = .zero
                        }
                    }
                    .frame(width: 100, height: 50)
                    .foregroundColor(.white)
                    .background(Color.red)
                }
            }
            
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(.gray)
                        .frame(width: 50, height: 50)
                    
                    Text(initials)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .fontWeight(.bold)
                        .foregroundColor(style.formTextColor)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let message {
                        Text(message)
                            .font(.body)
                            .foregroundColor(style.formTextColor)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .background(style.backgroundColor)
            .offset(x: self.offset)
            .animation(.easeInOut, value: offset)
            .clipped()
            .conditionalGesture(apply: showDeleteButton && !isIOS16OrNewer(), gesture: dragGesture)
        }
    }
    
    private func isIOS16OrNewer() -> Bool {
        if #available(iOS 16, *) {
            return true
        } else {
            return false
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                let horizontalMovement = gesture.translation.width
                if horizontalMovement < 0 { // Swipe left
                    self.offset = horizontalMovement
                }
            }
            .onEnded { _ in
                if self.offset < -100 { // Custom threshold for how far to swipe
                    self.offset = -100 // Adjust this value to fit the size of the delete button
                } else {
                    self.offset = .zero
                }
            }
    }
}

// MARK: - Helpers

private extension View {
    @ViewBuilder func conditionalGesture<G: Gesture>(apply condition: Bool, gesture: G) -> some View {
        if condition {
            self.gesture(gesture)
        } else {
            self
        }
    }
}

// MARK: - Preview

struct DefaultChatListCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            List {
                ChatListCell(title: "John Doe", message: "Hi, how are you?")
                
                ChatListCell(title: "Peter Parker", message: "I need you!")
            }
            .previewDisplayName("Light Mode")
            
            List {
                ChatListCell(title: "John Doe", message: "Hi, how are you?")
                
                ChatListCell(title: "Peter Parker", message: "I need you!")
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
