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

struct SelectableCircle: View {

    // MARK: - Properties

    var isSelected: Bool

    // MARK: - Builder

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.white, lineWidth: 2)
                .frame(width: 30, height: 30)
                .background(Circle().fill(isSelected ? .blue : .clear))
            if isSelected {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview

struct SelectableCircle_Previews: PreviewProvider {
    
    static let viewModel = AttachmentsViewModel(messageTypes: [.image(MockData.imageItem)])
    
    static var previews: some View {
        Group {
            HStack {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.green)
                        .frame(width: 150, height: 150)
                    
                    SelectableCircle(isSelected: true)
                        .padding(8)
                }
                
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.green)
                        .frame(width: 150, height: 150)
                    
                    SelectableCircle(isSelected: false)
                        .padding(8)
                }
            }
            .previewDisplayName("Light Mode")
            
            HStack {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.green)
                        .frame(width: 150, height: 150)
                    
                    SelectableCircle(isSelected: true)
                        .padding(8)
                }
                
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.green)
                        .frame(width: 150, height: 150)
                    
                    SelectableCircle(isSelected: false)
                        .padding(8)
                }
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
