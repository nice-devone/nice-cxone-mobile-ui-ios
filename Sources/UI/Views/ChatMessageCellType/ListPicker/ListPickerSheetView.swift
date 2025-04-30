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

struct ListPickerSheetView: View, Themed {

    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    
    @State private var selectedOption: RichMessageButton?
    
    let item: ListPickerItem
    let onFinished: (RichMessageButton) -> Void
    
    private static let paddingHorizontalSheet: CGFloat = 16
    private static let paddingTopSheetOptionsTitle: CGFloat = 36
    private static let paddingBottomSheetOptionsTitle: CGFloat = 8
    private static let paddingTopSheetOptionsTitleSection: CGFloat = 10
    private static let spacingSheetOptionsDivider: CGFloat = 10
    private static let sizeOptionImage: CGFloat = 64
    private static let cornerRadiusOptionImage: CGFloat = 16
    private static let paddingTrailingSheetOptionImage: CGFloat = 12
    private static let paddingTopOption: CGFloat = 10
    private static let paddingTopSheetControlButtons: CGFloat = 12
    private static let paddingBottomSheetControlButtons: CGFloat = 40
    
    // MARK: - Init
    
    init(item: ListPickerItem, onFinished: @escaping (RichMessageButton) -> Void) {
        self.item = item
        self.onFinished = onFinished
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
            
            Spacer()
            
            controlButtons
        }
        .background(colors.customizable.background)
    }
}

// MARK: - Subviews

private extension ListPickerSheetView {
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(.title3)
                .bold()
                .foregroundStyle(colors.customizable.onBackground)
                .padding(.horizontal, Self.paddingHorizontalSheet)
            
            if let message = item.message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(colors.customizable.onBackground.opacity(0.5))
                    .padding(.horizontal, Self.paddingHorizontalSheet)
            }
            
            Text(localization.chatMessageListPickerSheetOptionsTitle)
                .font(.footnote)
                .foregroundStyle(colors.customizable.onBackground.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Self.paddingTopSheetOptionsTitle)
                .padding(.horizontal, Self.paddingHorizontalSheet)
                .padding(.bottom, Self.paddingBottomSheetOptionsTitle)
                .background(colors.customizable.onBackground.opacity(0.05))
                .padding(.top, Self.paddingTopSheetOptionsTitleSection)
            
            listOptions
        }
        .padding(.top, 48)
    }
    
    var listOptions: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(item.buttons, id: \.self) { element in
                    Button {
                        withAnimation {
                            if selectedOption == element {
                                selectedOption = nil
                            } else {
                                selectedOption = element
                            }
                        }
                    } label: {
                        labelForItemOption(element)
                    }
                    .background(selectedOption == element ? colors.customizable.onBackground.opacity(0.05) : colors.customizable.background)
                }
            }
        }
    }
    
    func labelForItemOption(_ element: RichMessageButton) -> some View {
        VStack(alignment: .leading, spacing: Self.spacingSheetOptionsDivider) {
            HStack(spacing: 0) {
                if let url = element.iconUrl {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: Self.sizeOptionImage, height: Self.sizeOptionImage)
                    .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadiusOptionImage))
                    .padding(.trailing, Self.paddingTrailingSheetOptionImage)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(element.title)
                        .foregroundStyle(colors.customizable.onBackground)
                        .font(.headline)
                    
                    if let description = element.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(colors.customizable.onBackground)
                            .opacity(0.5)
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                Asset.check
                    .foregroundColor(colors.customizable.accent)
                    .font(.headline)
                    .if(selectedOption != element) { view in
                        view.hidden()
                    }
            }
            .padding(.top, Self.paddingTopOption)
            .padding(.horizontal, Self.paddingHorizontalSheet)
            
            ColoredDivider(colors.customizable.onBackground.opacity(0.1))
                .if(selectedOption == element) { view in
                    view.hidden()
                }
        }
    }
    
    var controlButtons: some View {
        HStack {
            Button(localization.commonCancel, action: dismiss.callAsFunction)
            
            Spacer()
            
            Button(localization.chatMessageListPickerSheetConfirm) {
                guard let selectedOption else {
                    LogManager.error(.failed("Unable to get selected option"))
                    return
                }
                
                onFinished(selectedOption)
            }
            .disabled(selectedOption == nil)
            .foregroundStyle(selectedOption == nil ? colors.foreground.disabled : colors.customizable.primary)
        }
        .font(.callout)
        .padding(.top, Self.paddingTopSheetControlButtons)
        .padding(.bottom, Self.paddingBottomSheetControlButtons)
        .padding(.horizontal, Self.paddingHorizontalSheet)
        .background(colors.customizable.onBackground.opacity(0.05))
    }
}

// MARK: - Previews

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
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: UIScreen.main.bounds.size.width / 1.5, height: UIScreen.main.bounds.size.width / 2)
                .cornerRadius(20, corners: .allCorners)
            } else {
                Text("No option selected")
            }
        }
    }
    .sheet(isPresented: $isSheetVisible) {
        ListPickerSheetView(item: MockData.listPickerItem) { option in
            selectedOption = option
            isSheetVisible = false
        }
    }
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
