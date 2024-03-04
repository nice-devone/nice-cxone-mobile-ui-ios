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

struct GalleryMessageCell: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    private var applyPadding = true
    
    let message: ChatMessage
    let elements: [ChatRichMessageType]
    let elementSelected: (_ textToSend: String?, RichMessageSubElementType) -> Void
    
    // MARK: - Init
    
    init(message: ChatMessage, elements: [ChatRichMessageType], elementSelected: @escaping (_ textToSend: String?, RichMessageSubElementType) -> Void) {
        self.message = message
        self.elements = elements
        self.elementSelected = elementSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    Spacer(minLength: 14)
                    
                    ForEach(0..<elements.count, id: \.self) { index in
                        let isFirst = index == 0
                        
                        handleType(elements[index], isFirst: isFirst)
                            .frame(width: UIScreen.main.bounds.size.width * 0.85)
                            .padding(.bottom, isFirst ? 10 : 0)
                    }
                }
            }
        }
        .padding(.bottom, 14)
        .padding(.trailing, 4)
    }
    
    // MARK: - Methods
    
    func applyPadding(_ apply: Bool) -> Self {
        var view = self
        
        view.applyPadding = apply
        
        return view
    }
}

// MARK: - Subviews

private extension GalleryMessageCell {

    @ViewBuilder
    func handleType(_ type: ChatRichMessageType, isFirst: Bool) -> some View {
        switch type {
        case .gallery(let elements):
            ForEach(elements, id: \.self) { type in
                AnyView(handleType(type, isFirst: isFirst))
            }
        case .menu(let elements):
            MenuMessageCell(message: message, elements: elements) { element in
                elementSelected(nil, element)
            }
        case .quickReplies(let content):
            QuickRepliesMessageCell(message: message, item: content) { element in
                elementSelected(element.title, .button(element))
            }
        case .listPicker(let content):
            ListPickerMessageCell(message: message, item: content) { element in
                elementSelected(nil, element)
            }
        case .richLink(let content):
            RichLinkMessageCell(message: message, item: content) { url in
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        case .satisfactionSurvey(let content):
            SatisfactionSurveyMessageCell(message: message, item: content) { url in
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        case .custom(let content):
            CustomMessageCell(message: message, item: content) { url in
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

// MARK: - Preview

struct GalleryMessageCell_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            GalleryMessageCell(message: MockData.galleryMessage(), elements: MockData.galleryRichMessageElements) { _, _ in }
                .previewDisplayName("Light Mode")
            
            GalleryMessageCell(message: MockData.galleryMessage(), elements: MockData.galleryRichMessageElements) { _, _ in }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
