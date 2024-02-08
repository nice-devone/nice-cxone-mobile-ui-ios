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
                            Asset.Attachment.file
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(style.backgroundColor.opacity(0.5)).colorInvert()
                                )
                            
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
}
