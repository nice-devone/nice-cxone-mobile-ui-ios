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

struct ListPickerMessageCell: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var isSheetVisible = false
    @State private var isOptionSelectedVisible = false
    
    let item: ListPickerItem
    let elementSelected: (RichMessageButton) -> Void
    
    private static let spacingCell: CGFloat = 8
    private static let spacingTextAndImage: CGFloat = 10
    private static let paddingVertical: CGFloat = 10
    private static let paddingLeading: CGFloat = 18
    private static let paddingTrailing: CGFloat = 8
    
    // MARK: - Init
    
    init(item: ListPickerItem, elementSelected: @escaping (RichMessageButton) -> Void) {
        self.item = item
        self.elementSelected = elementSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Self.spacingCell) {
                cellContent
            }
            
            Spacer(minLength: UIScreen.main.bounds.size.width / 10)
        }
        .sheet(isPresented: $isSheetVisible) {
            ListPickerSheetView(item: item) { element in
                withAnimation {
                    elementSelected(element)
                    isOptionSelectedVisible = true
                    isSheetVisible = false
                }
            }
        }
    }
}

// MARK: - Subviews

private extension ListPickerMessageCell {
    
    @ViewBuilder
    var cellContent: some View {
        Button {
            isSheetVisible = true
        } label: {
            HStack(alignment: .top, spacing: Self.spacingTextAndImage) {
                VStack(alignment: .leading) {
                    Text(item.title)
                        .bold()
                        .font(.subheadline)
                        .foregroundStyle(colors.customizable.agentText)
                    
                    if let message = item.message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(colors.customizable.agentText.opacity(0.5))
                    }
                }
                
                Asset.Images.listPickerIcon
                    .swiftUIImage
            }
            .multilineTextAlignment(.leading)
        }
        .padding(.vertical, Self.paddingVertical)
        .padding(.leading, Self.paddingLeading)
        .padding(.trailing, Self.paddingTrailing)
        .background(colors.customizable.agentBackground)
        .cornerRadius(StyleGuide.Message.cornerRadius, corners: .allCorners)
        
        if isOptionSelectedVisible {
            RichContentOptionSelected()
        }
    }
}

// MARK: - Previews

#Preview {
    TestViewPreview()
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}

private struct TestViewPreview: View, Themed {
    
    // MARK: - Properties
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    
    @State private var selectedOption: RichMessageButton?
    
    private static let avatarDimension: CGFloat = 24
    private static let avatarOffset: CGFloat = 12
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                ListPickerMessageCell(item: MockData.listPickerItem) { option in
                    selectedOption = option
                }
                
                AvatarView(imageUrl: MockData.agent.avatarURL, initials: MockData.agent.initials)
                    .frame(width: Self.avatarDimension, height: Self.avatarDimension)
                    .offset(x: -Self.avatarOffset, y: Self.avatarOffset)
            }
            
            if let selectedOption {
                HStack {
                    Spacer(minLength: UIScreen.main.bounds.size.width / 10)
                    
                    Text(selectedOption.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(colors.foreground.onContrast)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colors.accent.accent)
                    )
                }
            }
            
            Spacer()
        }
        .listStyle(.inset)
        .padding(.leading, 16)
        .padding(.trailing, 4)
    }
}
