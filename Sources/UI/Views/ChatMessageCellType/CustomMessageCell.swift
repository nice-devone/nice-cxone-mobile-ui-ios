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

import Kingfisher
import SwiftUI

struct CustomMessageCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    private var applyPadding = true
    
    let message: ChatMessage
    let item: CustomPluginMessageItem
    let buttonPressed: (URL) -> Void
    
    // MARK: - Init
    
    init(message: ChatMessage, item: CustomPluginMessageItem, buttonPressed: @escaping (URL) -> Void) {
        self.message = message
        self.item = item
        self.buttonPressed = buttonPressed
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack(alignment: message.user.isAgent ? .bottomLeading : .bottomTrailing) {
            HStack {
                AnyView(parseVariables())
                    .background(style.agentCellColor)
                    .cornerRadius(14, corners: .allCorners)
                
                if applyPadding {
                    Spacer(minLength: UIScreen.main.bounds.size.width / 3)
                }
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 4)
    }
    
    // MARK: - Methods
    
    func applyPadding(_ apply: Bool) -> Self {
        var view = self
        
        view.applyPadding = apply
        
        return view
    }
}

// MARK: - Private methods

private extension CustomMessageCell {
    
    func parseVariables() -> any View {
        guard let thumbnail = item.variables["thumbnail"] as? URL else {
            LogManager.error(.unableToParse("thumbnail", from: item.variables))
            return EmptyView()
        }
        guard let videoUrl = item.variables["url"] as? URL else {
            LogManager.error(.unableToParse("url", from: item.variables))
            return EmptyView()
        }
        guard let openButton = (item.variables["buttons"] as? [[String: String]])?.first,
              let openButtonTitle = openButton["name"]
        else {
            LogManager.error(.unableToParse("button name", from: item.variables))
            return EmptyView()
        }
        guard let size = item.variables["size"] as? [String: String], let iOS = size["ios"] else {
            LogManager.error(.unableToParse("iOS size", from: item.variables))
            return EmptyView()
        }
        
        return VStack(alignment: .leading, spacing: 0) {
            if let title = item.title {
                Text(title)
                    .padding(10)
            }
            
            KFImage(thumbnail)
                .resizable()
                .frame(maxHeight: 150)
            
            Button(openButtonTitle) {
                buttonPressed(videoUrl)
            }
            .frame(maxWidth: .infinity, maxHeight: CGFloat.getButtonSize(type: iOS))
            .foregroundColor(style.agentFontColor)
        }
    }
}

// MARK: - Helpers

private extension CGFloat {
    
    private static let a11ySize: CGFloat = 44
    
    static func getButtonSize(type: String) -> CGFloat {
        switch type {
        case "small":
            return a11ySize * 0.75
        case "big":
            return a11ySize * 1.25
        default:
            return a11ySize
        }
    }
}

// MARK: - Preview

struct CustomMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            CustomMessageCell(message: MockData.customMessage(), item: MockData.customItem) { _ in }
                .previewDisplayName("Light Mode")
            
            CustomMessageCell(message: MockData.customMessage(), item: MockData.customItem) { _ in }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
