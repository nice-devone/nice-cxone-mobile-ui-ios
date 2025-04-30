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

struct MessageInputAttachmentListView: View, Themed {
    
    // MARK: - Properties

    @Environment(\.colorScheme) var scheme

    @EnvironmentObject var style: ChatStyle

    @Binding var attachments: [AttachmentItem]
    @Binding var alertType: ChatAlertType?
    
    // MARK: - Styling
    
    enum Constants {
        enum Button {
            static let offset: CGFloat = StyleGuide.buttonSmallerDimension / 2
            static let padding: CGFloat = 4
            static let imageSize: CGFloat = 20
            static let strokeWidth: CGFloat = 2
        }
        
        enum Layout {
            static let dividerHorizontalPadding: CGFloat = 12
            static let thumbnailScrollViewVerticalPadding: CGFloat = 14
            static let attachmentItemTopPadding: CGFloat = 8
            static let textTopPadding: CGFloat = 4
        }
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: .zero) {
            
            ColoredDivider(colors.customizable.onBackground.opacity(0.1))
                .padding(.horizontal, Constants.Layout.dividerHorizontalPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    Spacer()
                    
                    ForEach(0..<attachments.count, id: \.self) { index in
                        VStack(spacing: 0) {
                            ZStack(alignment: .topTrailing) {
                                MessageInputAttachmentView(
                                    attachment: attachments[index],
                                    width: StyleGuide.Attachment.regularDimension,
                                    height: StyleGuide.Attachment.regularDimension,
                                    alertType: $alertType
                                )
                                
                                closeButton {
                                    attachments.remove(at: index)
                                }
                                .offset(x: Constants.Button.offset, y: -Constants.Button.offset)
                            }
                            .padding(.top, Constants.Layout.attachmentItemTopPadding)
                            
                            Text(attachments[index].fileName)
                                .font(.caption)
                                .foregroundColor(colors.customizable.onBackground)
                                .padding(.top, Constants.Layout.textTopPadding)
                                .frame(width: StyleGuide.Attachment.regularDimension)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }
                .frame(height: StyleGuide.Attachment.regularDimension + Constants.Layout.thumbnailScrollViewVerticalPadding * 2)
            }
        }
    }
    
    private func closeButton(closure: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.default, closure)
        } label: {
            Asset.Attachment.remove
                .fixedSize(width: Constants.Button.imageSize, height: Constants.Button.imageSize)
                .foregroundColor(colors.foreground.error)
                .background(
                    Circle()
                        .fill(colors.foreground.staticLight)
                        .padding(Constants.Button.padding)
                        .overlay(
                            Circle()
                                .stroke(colors.foreground.staticLight, lineWidth: Constants.Button.strokeWidth)
                        )
                )
                .contentShape(Rectangle())
        }
        .frame(width: StyleGuide.buttonDimension, height: StyleGuide.buttonDimension)
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview("Media Attachments") {
    @Previewable @State var attachments = [
        MockData.videoItem,
        MockData.imageItem,
        MockData.audioItem
    ]
    
    VStack {
        Spacer()
        
        MessageInputAttachmentListView(attachments: $attachments, alertType: .constant(nil))
    }
    .environmentObject(ChatLocalization())
    .environmentObject(ChatStyle())
}

@available(iOS 17.0, *)
#Preview("Document Attachments") {
    @Previewable @State var attachments = [
        MockData.docPreviewItem,
        MockData.pdfPreviewItem,
        MockData.pptPreviewItem
    ]
    
    VStack {
        Spacer()
        
        MessageInputAttachmentListView(attachments: $attachments, alertType: .constant(nil))
    }
    .environmentObject(ChatLocalization())
    .environmentObject(ChatStyle())
}
