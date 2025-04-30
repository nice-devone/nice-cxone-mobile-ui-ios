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

struct LoadingImageMessageCell: View, Themed {

    // MARK: - Properties
    
    typealias Styling = StyleGuide.Attachment
    
    @StateObject var viewModel: ImageMessageCellViewModel
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var isImagePresented = false
    
    let isMultiAttachment: Bool
    
    private static let largeWidth: CGFloat = 242
    private static let largeHeight: CGFloat = 285
    
    // MARK: - Init
    
    init(item: AttachmentItem, isMultiAttachment: Bool, alertType: Binding<ChatAlertType?>, localization: ChatLocalization) {
        _viewModel = StateObject(wrappedValue: ImageMessageCellViewModel(item: item, alertType: alertType, localization: localization))
        self.isMultiAttachment = isMultiAttachment
    }
    
    // MARK: - Builder
    
    var body: some View {
        let displayImage = viewModel.image.map(Image.init(uiImage:)) ?? Asset.Attachment.placeholder
        
        displayImage
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                width: isMultiAttachment ? Styling.largeDimension : Self.largeWidth,
                height: isMultiAttachment ? Styling.largeDimension : Self.largeHeight
            )
            .clipped()
            .background {
                if viewModel.image == nil {
                    colors.foreground.subtle
                }
            }
            .foregroundColor(
                viewModel.image == nil 
                    ? colors.foreground.staticDark
                    : Color.clear
            )
            .contentShape(Rectangle())
            .if(viewModel.image != nil) {
                $0.onTapGesture {
                    isImagePresented = true
                }
                .sheet(isPresented: $isImagePresented) {
                    ImageViewer(image: displayImage, viewerShown: $isImagePresented)
                }
            }
    }
}

// MARK: - Preview

#Preview {
    let localization = ChatLocalization()
    
    VStack(spacing: 100) {
        LoadingImageMessageCell(item: MockData.imageItem, isMultiAttachment: true, alertType: .constant(nil), localization: localization)
        LoadingImageMessageCell(item: MockData.imageItem, isMultiAttachment: false, alertType: .constant(nil), localization: localization)
    }
    .environmentObject(ChatStyle())
}
