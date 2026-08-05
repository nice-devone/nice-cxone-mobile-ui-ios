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

struct ListPickerSheetView: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let optionImageCornerRadius: CGFloat = 16
        }
        
        enum Padding {
            static let contentTop: CGFloat = 48
            static let contentHorizontal: CGFloat = 16
            static let optionsTitleInnerTop: CGFloat = 36
            static let optionsTitleBottom: CGFloat = 8
            static let optionsTitleOuterTop: CGFloat = 10
            static let optionImageTrailing: CGFloat = 12
            static let optionTop: CGFloat = 10
            static let listOptionsTop: CGFloat = 24
            static let controlButtonsTop: CGFloat = 11
            static let controlButtonsBottom: CGFloat = 47
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
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    
    @State private var selectedOption: RichMessageButton?
    
    let item: ListPickerItem
    let onFinished: (RichMessageButton) -> Void
    
    // MARK: - Init
    
    init(item: ListPickerItem, onFinished: @escaping (RichMessageButton) -> Void) {
        self.item = item
        self.onFinished = onFinished
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.elementsSpacing) {
            content

            Spacer()

            ColoredDivider(colors.border.default)
                .accessibilityHidden(true)

            controlButtons
        }
        .background(colors.background.default)
        .accessibilityAddTraits(.isModal)
    }
}

// MARK: - Subviews

private extension ListPickerSheetView {
    
    var content: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.elementsSpacing) {
            header

            listOptions
                .padding(.top, Constants.Padding.listOptionsTop)
        }
        .padding(.top, Constants.Padding.contentTop)
    }

    var header: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.elementsSpacing) {
            Text(item.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(colors.content.primary)
                .padding(.horizontal, Constants.Padding.contentHorizontal)
                .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Sheet.Title.identifier)
                .accessibilityAddTraits(.isStaticText)

            if let message = item.message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(colors.content.secondary)
                    .padding(.horizontal, Constants.Padding.contentHorizontal)
                    .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Sheet.Message.identifier)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
    
    var listOptions: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.elementsSpacing) {
                ForEach(item.buttons, id: \.self) { element in
                    let isSelected = (selectedOption == element)

                    VStack(spacing: Constants.Spacing.elementsSpacing) {
                        Button {
                            withAnimation { selectedOption = isSelected ? nil : element }
                        } label: {
                            ListPickerSheetCell(element: element, selectedOption: $selectedOption)
                        }
                        .background(
                            isSelected
                                ? colors.background.surface.emphasis
                                : colors.background.default)

                        ColoredDivider(colors.border.default)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
    }
    
    var controlButtons: some View {
        HStack(spacing: Constants.Spacing.elementsSpacing) {
            Button(L10n.Common.cancel, action: dismiss.callAsFunction)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(colors.brand.primary)
                .accessibilityIdentifier(A11y.Form.ButtonCancel.identifier)
                .accessibilityHint(A11y.Form.ButtonCancel.hint)

            Spacer()

            Button(L10n.Common.confirm) {
                guard let selectedOption else {
                    LogManager.error(.failed("Unable to get selected option"))
                    return
                }

                onFinished(selectedOption)
            }
            .disabled(selectedOption == nil)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(selectedOption == nil ? colors.content.tertiary : colors.brand.primary)
            .accessibilityIdentifier(A11y.Form.ButtonConfirm.identifier)
            .ifLet(selectedOption?.title) { view, title in
                view.accessibilityValue(title)
            }
            .accessibilityHint(selectedOption == nil ? A11y.Form.ButtonConfirm.Invalid.hint : A11y.Form.ButtonConfirm.Valid.hint)
        }
        .padding(.top, Constants.Padding.controlButtonsTop)
        .padding(.bottom, Constants.Padding.controlButtonsBottom)
        .padding(.horizontal, Constants.Padding.contentHorizontal)
        .background(colors.background.default)
    }
}

// MARK: - Previews

// swiftlint:disable hardcoded_strings
@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selectedOption: RichMessageButton?
    @Previewable @State var isSheetVisible = true
    
    VStack {
        Text("Selected option:")
            .font(.headline)
        
        Button {
            isSheetVisible = true
        } label: {
            if let url = selectedOption?.iconUrl {
                KFImage(url)
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.currentBounds.width / 1.5, height: UIScreen.currentBounds.width / 2)
                    .cornerRadius(20, corners: .allCorners)
            } else {
                Text("No option selected")
            }
        }
    }
    .sheet(isPresented: $isSheetVisible) {
        ListPickerSheetView(item: MockData.listPickerItem()) { option in
            selectedOption = option
            isSheetVisible = false
        }
    }
    .environmentObject(ChatStyle())
}
// swiftlint:enable hardcoded_strings
