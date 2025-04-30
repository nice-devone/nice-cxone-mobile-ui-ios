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

struct QuickRepliesMessageOptionsView: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    let item: QuickRepliesItem
    let optionSelected: (RichMessageButton) -> Void
    
    private static let optionCornerRadius: CGFloat = 8
    private static let optionPaddingVertical: CGFloat = 10
    private static let optionPaddingHorizontal: CGFloat = 16
    
    // MARK: - Init
    
    init(item: QuickRepliesItem, optionSelected: @escaping (RichMessageButton) -> Void) {
        self.item = item
        self.optionSelected = optionSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        OptionsView(options: item.options) { option in
            Button {
                optionSelected(option)
            } label: {
                Text(option.title)
                    .multilineTextAlignment(.leading)
            }
            .font(.footnote)
            .foregroundStyle(colors.customizable.primary)
            .padding(.horizontal, Self.optionPaddingHorizontal)
            .padding(.vertical, Self.optionPaddingVertical)
            .background(
                RoundedRectangle(cornerRadius: Self.optionCornerRadius)
                    .fill(colors.customizable.agentBackground)
            )
        }
    }
}

// MARK: - Helpers

private struct OptionsView<Content: View>: View where Data.Element: Hashable {
    
    // MARK: - Properties
    
    @State var elementsSize = [RichMessageButton: CGSize]()
    @State var screenWidth = CGFloat()
    
    private let spacing: CGFloat = 8
    
    let options: [RichMessageButton]
    let content: (RichMessageButton) -> Content
    
    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(computeElements(), id: \.self) { rowElements in
                horizontalStack(for: rowElements)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .readSize { size in
            self.screenWidth = size.width
        }
        
    }
}

// MARK: - Subviews

private extension OptionsView {
    
    func horizontalStack(for elements: [RichMessageButton]) -> some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(elements, id: \.self) { element in
                content(element)
                    .readSize { size in
                        elementsSize[element] = size
                    }
            }
        }
    }
}

// MARK: - Methods

private extension OptionsView {

    func computeElements() -> [[RichMessageButton]] {
        var rows: [[RichMessageButton]] = [[]]
        var currentRow = 0
        var remainingWidth = screenWidth
        
        for element in options {
            let elementWidthWithSpacing = elementsSize[element, default: CGSize(width: screenWidth, height: 1)].width + spacing
            
            if !(remainingWidth - elementWidthWithSpacing).isLessThanOrEqualTo(0) {
                rows[currentRow].append(element)
            } else {
                currentRow += 1
                rows.append([element])
                remainingWidth = screenWidth
            }
            
            remainingWidth -= elementWidthWithSpacing
        }
        
        return rows
    }
}

// MARK: - Previews

#Preview("Light mode") {
    let options = (0..<Int.random(in: 5...15))
        .map { _ -> RichMessageButton in
            RichMessageButton(title: Lorem.words(nbWords: Int.random(in: 1..<10)), iconUrl: nil)
        }
    let item = QuickRepliesItem(title: Lorem.sentence(), message: Lorem.sentence(), options: options)
    
    return QuickRepliesMessageOptionsView(item: item) { _ in }
        .padding(.horizontal, 12)
        .environmentObject(ChatStyle())
}

#Preview("Dark mode") {
    let options = (0..<Int.random(in: 5...15))
        .map { _ -> RichMessageButton in
            RichMessageButton(title: Lorem.words(nbWords: Int.random(in: 1..<10)), iconUrl: nil)
        }
    let item = QuickRepliesItem(title: Lorem.sentence(), message: Lorem.sentence(), options: options)
    
    return QuickRepliesMessageOptionsView(item: item) { _ in }
        .padding(.horizontal, 12)
        .environmentObject(ChatStyle())
        .preferredColorScheme(.dark)
}
