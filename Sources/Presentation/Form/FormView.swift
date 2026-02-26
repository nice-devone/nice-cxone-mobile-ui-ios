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

import CXoneChatSDK
import SwiftUI

// MARK: - Constants

private enum Constants {
    
    enum Spacing {
        static let bodyVertical: CGFloat = 0
        static let headerVertical: CGFloat = 4
        static let controlButtonsVertical: CGFloat = 12
    }
    
    enum Padding {
        static let headerBottom: CGFloat = 16
        static let contentTop: CGFloat = 24
        static let controlButtonsHorizontal: CGFloat = 16
        static let controlButtonsBottom: CGFloat = 26
        static let contentHorizontal: CGFloat = 16
        static let bodyTop: CGFloat = 48
    }
}

// MARK: - FormView

struct FormView<Content: View, FormType: Any>: View, Themed {

    // MARK: - Properties

    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @ObservedObject var viewModel: FormViewModel<FormType>
    
    let title: String
    let subtitle: String
    let content: () -> Content

    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.bodyVertical) {
            header
                .padding(.horizontal, Constants.Padding.contentHorizontal)
            
            ColoredDivider(colors.border.default)
            
            content()
                .padding(.top, Constants.Padding.contentTop)
                .padding(.horizontal, Constants.Padding.contentHorizontal)
            
            controlButtons
        }
        .interactiveDismissDisabled()
        .onTapGesture(perform: hideKeyboard)
        .padding(.top, Constants.Padding.bodyTop)
        .background(colors.background.default)
    }
    
    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.headerVertical) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(colors.content.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(colors.content.secondary)
                .padding(.bottom, Constants.Padding.headerBottom)
        }
    }
    
    private var controlButtons: some View {
        VStack(spacing: Constants.Spacing.controlButtonsVertical) {
            ColoredDivider(colors.border.default)
            
            HStack {
                Button(localization.commonCancel, action: viewModel.onCancel)

                Spacer()

                Button(localization.commonSubmit, action: viewModel.onSubmit)
                    .disabled(!viewModel.isFormValid)
            }
            .font(.body.weight(.medium))
            .tint(colors.brand.primary)
            .padding(.horizontal, Constants.Padding.controlButtonsHorizontal)
            .padding(.bottom, Constants.Padding.controlButtonsBottom)
        }
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: viewModel.isFormValid)
    }
}

// MARK: - Preview

#Preview {
    let viewModel: FormViewModel<[String: String]> = FormViewModel { customFields in
        print("Submit \(customFields)")
    } onCancel: {
        print("Cancelled")
    }

    Color.clear
        .sheet(isPresented: .constant(true)) {
            FormView<VStack, [String: String]>(viewModel: viewModel, title: "Title", subtitle: "Subtitle") {
                VStack {
                    TextFieldView(entity: MockData.textFieldEntity()) {
                        
                    }
                    
                    ListFieldView(entity: MockData.listFieldEntity(isRequired: true)) {
                        
                    }
                }
            }
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
