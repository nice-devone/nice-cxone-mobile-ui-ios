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

import CXoneChatSDK
import SwiftUI

struct DefaultChatListCell: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    
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
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(.gray)
                    .frame(width: 50, height: 50)

                Text(initials)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            
            VStack {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(style.formTextColor)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let message {
                    Text(message)
                        .font(.body)
                        .foregroundColor(style.formTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            if showDeleteButton, #available(*, iOS 15), let onDelete {
                Spacer()
                
                Button(action: onDelete) {
                    Asset.List.delete
                        .foregroundColor(style.formTextColor)
                }
            }
        }
    }
}

// MARK: - Preview

struct DefaultChatListCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            List {
                DefaultChatListCell(title: "John Doe", message: "Hi, how are you?")
                
                DefaultChatListCell(title: "Peter Parker", message: "I need you!")
            }
            .previewDisplayName("Light Mode")
            
            List {
                DefaultChatListCell(title: "John Doe", message: "Hi, how are you?")
                
                DefaultChatListCell(title: "Peter Parker", message: "I need you!")
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
