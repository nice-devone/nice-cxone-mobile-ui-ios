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

struct MessageInputAttachmentView: View, Themed {
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    @Binding var alertType: ChatAlertType?
    
    let attachment: AttachmentItem
    let width: CGFloat
    let height: CGFloat

    // MARK: - Init
    
    init(attachment: AttachmentItem, width: CGFloat, height: CGFloat, alertType: Binding<ChatAlertType?>) {
        self.attachment = attachment
        self.width = width
        self.height = height
        self._alertType = alertType
    }
    
    // MARK: - Builder
    
    var body: some View {
        switch attachment.mimeType {
        case let type where type.starts(with: "image/"):
            MessageInputImageThumbnailView(url: attachment.url, width: width, height: height)
        case let type where type.starts(with: "video/"):
            VideoThumbnailView(url: attachment.url, displayMode: .small)
        default:
            ApplicationMimeTypeThumbnailView(
                item: attachment,
                width: width,
                height: height,
                alertType: $alertType
            )
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        MessageInputAttachmentView(
            attachment: MockData.imageItem,
            width: StyleGuide.Attachment.regularDimension,
            height: StyleGuide.Attachment.regularDimension,
            alertType: .constant(nil)
        )
        
        MessageInputAttachmentView(
            attachment: MockData.audioItem,
            width: StyleGuide.Attachment.regularDimension,
            height: StyleGuide.Attachment.regularDimension,
            alertType: .constant(nil)
        )
        
        MessageInputAttachmentView(
            attachment: MockData.videoItem,
            width: StyleGuide.Attachment.regularDimension,
            height: StyleGuide.Attachment.regularDimension,
            alertType: .constant(nil)
        )
        
        MessageInputAttachmentView(
            attachment: MockData.docPreviewItem,
            width: StyleGuide.Attachment.regularDimension,
            height: StyleGuide.Attachment.regularDimension,
            alertType: .constant(nil)
        )
        
        MessageInputAttachmentView(
            attachment: MockData.pdfPreviewItem,
            width: StyleGuide.Attachment.regularDimension,
            height: StyleGuide.Attachment.regularDimension,
            alertType: .constant(nil)
        )
        
        MessageInputAttachmentView(
            attachment: MockData.xlsPreviewItem,
            width: StyleGuide.Attachment.regularDimension,
            height: StyleGuide.Attachment.regularDimension,
            alertType: .constant(nil)
        )
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
