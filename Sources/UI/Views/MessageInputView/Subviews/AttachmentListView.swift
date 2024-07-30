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

import SwiftUI

struct AttachmentListView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @Binding var attachments: [AttachmentItem]
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 12)
            
            ScrollView(.horizontal) {
                HStack {
                    Spacer()
                    
                    ForEach(0..<attachments.count, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            thumbnailPreview(for: attachments[index])

                            Button {
                                withAnimation {
                                    _ = attachments.remove(at: index)
                                }
                            } label: {
                                Asset.Attachment.remove
                                    .imageScale(.large)
                                    .foregroundColor(.red)
                                    .background(
                                        Circle()
                                            .fill(style.backgroundColor)
                                            .padding(4)
                                    )
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                .padding(.top, 6)
            }
            .frame(height: 60)
        }
    }
    
    @ViewBuilder
    private func thumbnailPreview(for attachment: AttachmentItem) -> some View {
        if attachment.mimeType.starts(with: "image/"), let uiImage = imageFromURL(attachment.url) {
            Image(uiImage: uiImage)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 50, height: 50)
        } else if attachment.mimeType.starts(with: "video/") {
            VideoThumbnailView(videoURL: attachment.url)
        } else {
            Asset.Attachment.file
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 10).fill(style.formTextColor.opacity(0.5)))
        }
    }
    
    private func imageFromURL(_ url: URL) -> UIImage? {
        guard let imageData = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
