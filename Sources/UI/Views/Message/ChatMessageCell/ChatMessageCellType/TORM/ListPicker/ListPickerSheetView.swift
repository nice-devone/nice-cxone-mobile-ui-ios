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
        enum Padding {
            static let contentHorizontal: CGFloat = 16
            static let controlButtonsTop: CGFloat = 10
            static let controlButtonsBottom: CGFloat = 46
        }
        enum Spacing {
            static let elementsSpacing: CGFloat = 0
            static let scrollElementsSpacing: CGFloat = 16
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
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: Constants.Spacing.scrollElementsSpacing) {
                    if let message = item.message {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(colors.content.secondary)
                            .padding(.horizontal, Constants.Padding.contentHorizontal)
                            .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Sheet.Message.identifier)
                            .accessibilityAddTraits(.isStaticText)
                    }

                    listOptions
                }
            }

            ColoredDivider(colors.border.default)
                .ignoresSafeArea(.all)
                .accessibilityHidden(true)
            
            controlButtons
        }
        .background(colors.background.default)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(colors.content.primary)
                    .accessibilityIdentifier(A11y.Conversation.MessageCell.ListPicker.Sheet.Title.identifier)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityAddTraits(.isModal)
    }
}

// MARK: - Subviews

private extension ListPickerSheetView {

    var listOptions: some View {
        VStack(spacing: Constants.Spacing.elementsSpacing) {
            ForEach(item.buttons, id: \.self) { element in
                Button {
                    withAnimation {
                        selectedOption = (selectedOption == element) ? nil : element
                    }
                } label: {
                    ListPickerSheetCell(element: element, selectedOption: $selectedOption)
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

// Previews demonstrate each fixed size deliberately and never rotate, so they read the
// orientation-derived constants directly rather than through `LayoutAware`.
// swiftlint:disable orientation_outside_layout_context
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
            if let selectedOption {
                HStack {
                    if let iconUrl = selectedOption.iconUrl {
                        KFImage(iconUrl)
                            .placeholder {
                                ProgressView()
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: StyleGuide.Sizing.Attachment.smallDimension, height: StyleGuide.Sizing.Attachment.smallDimension)
                            .cornerRadius(20, corners: .allCorners)
                    }

                    Text(selectedOption.title)
                }
            } else {
                Text("No option selected")
            }
        }
    }
    .sheet(isPresented: $isSheetVisible) {
        NavigationStack {
            ListPickerSheetView(item: MockData.listPickerItem()) { option in
                selectedOption = option
                isSheetVisible = false
            }
        }
    }
    .environmentObject(ChatStyle())
}
// swiftlint:enable hardcoded_strings orientation_outside_layout_context
