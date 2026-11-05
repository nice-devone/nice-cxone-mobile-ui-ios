//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Kingfisher
import SwiftUI

struct ListPickerSheetCell: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let optionImageSize: CGFloat = 64
            static let optionImageCornerRadius: CGFloat = 16
        }
        
        enum Padding {
            static let contentVertical: CGFloat = 10
            static let contentHorizontal: CGFloat = 16
            static let optionImageTrailing: CGFloat = 12
        }
        
        enum Spacing {
            static let elementsSpacing: CGFloat = 0
        }
        
        enum LineLimit {
            static let optionTitle: Int = 1
            static let optionDescription: Int = 2
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @Binding var selectedOption: RichMessageButton?
    
    @State private var imageA11yLabel: String?
    
    let element: RichMessageButton
    
    var isSelected: Bool {
        selectedOption == element
    }
    
    // MARK: - Init
    
    init(element: RichMessageButton, selectedOption: Binding<RichMessageButton?>) {
        self.element = element
        self._selectedOption = selectedOption
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: Constants.Spacing.elementsSpacing) {
            HStack(spacing: Constants.Spacing.elementsSpacing) {
                if let url = element.iconUrl {
                    image(from: url)
                }
                
                textContent
                
                Spacer()
                
                Asset.check
                    .foregroundStyle(colors.brand.primary)
                    .font(.title2)
                    .if(!isSelected) { view in
                        view.hidden()
                    }
                    .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Sheet.Cell.Check.identifier)
                    .accessibilityLabel(A11y.Conversation.MessageCell.ListPicker.Sheet.Cell.Check.label)
            }
            .padding(.vertical, Constants.Padding.contentVertical)
            .padding(.horizontal, Constants.Padding.contentHorizontal)
            // `in: .rect` is load-bearing, not decoration: it clips the fill to the cell's own bounds.
            // The shape-less `background(_:ignoresSafeAreaEdges:)` overload defaults to `.all`, which let
            // the fill bleed into the horizontal safe-area insets in landscape. Dropping it regresses only
            // the landscape cases of `ListPickerSheetCellSnapshotTests` — portrait has no horizontal insets.
            .background(
                isSelected
                    ? colors.background.surface.emphasis
                    : colors.background.default,
                in: .rect
            )

            ColoredDivider(colors.border.default)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Sheet.Cell.identifier(element.title))
        .accessibilityHint(A11y.Conversation.MessageCell.ListPicker.Sheet.Cell.hint)
    }
}

// MARK: - Subviews

private extension ListPickerSheetCell {

    func image(from url: URL) -> some View {
        KFImage(url)
            .placeholder {
                ProgressView()
            }
            .onSuccess { result in
                imageA11yLabel = result.image.accessibilityLabel
            }
            .resizable()
            .scaledToFit()
            .frame(width: Constants.Sizing.optionImageSize, height: Constants.Sizing.optionImageSize)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Sizing.optionImageCornerRadius))
            .padding(.trailing, Constants.Padding.optionImageTrailing)
            .ifLet(imageA11yLabel) { view, a11yLabel in
                view.accessibilityLabel(a11yLabel)
            } else: { view in
                view.accessibilityHidden(true)
            }
    }
    
    var textContent: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.elementsSpacing) {
            Text(element.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(colors.content.primary)
                .lineLimit(Constants.LineLimit.optionTitle)
                .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Sheet.Title.identifier)
            
            if let description = element.description {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(colors.content.secondary)
                    .lineLimit(Constants.LineLimit.optionDescription)
                    .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Sheet.Message.identifier)
            }
        }
        .frame(minHeight: Constants.Sizing.optionImageSize)
        .multilineTextAlignment(.leading)
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview {
    @Previewable @State var selectedOption: RichMessageButton?
    
    ScrollView(showsIndicators: true) {
        VStack(spacing: 0) {
            ForEach(MockData.richMessageOptions(), id: \.self) { element in
                Button {
                    if selectedOption == element {
                        selectedOption = nil
                    } else {
                        selectedOption = element
                    }
                } label: {
                    ListPickerSheetCell(element: element, selectedOption: $selectedOption)
                }
            }
        }
    }
    .environmentObject(ChatStyle())
}
