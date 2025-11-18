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

struct FormView: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let bodyVertical: CGFloat = 0
            static let headerVertical: CGFloat = 4
            static let contentVertical: CGFloat = 24
            static let contentMinGap: CGFloat = 20
            static let controlButtonsVertical: CGFloat = 12
        }
        
        enum Padding {
            static let headerBottom: CGFloat = 16
            static let contentTop: CGFloat = 24
            static let controlButtonsHorizontal: CGFloat = 16
            static let controlButtonsBottom: CGFloat = 26
            static let topScrollView: CGFloat = 24
            static let contentHorizontal: CGFloat = 16
            static let bodyTop: CGFloat = 48
            static let edgeControlButtons: CGFloat = 16
            
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme

    @ObservedObject var viewModel: FormViewModel

    // MARK: - Init

    init(viewModel: FormViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.bodyVertical) {
            header
                .padding(.horizontal, Constants.Padding.contentHorizontal)
            
            ColoredDivider(colors.border.default)
            
            content
                .padding(.top, Constants.Padding.contentTop)
                .padding(.horizontal, Constants.Padding.contentHorizontal)
            
            controlButtons
        }
        .interactiveDismissDisabled()
        .onTapGesture(perform: hideKeyboard)
        .padding(.top, Constants.Padding.bodyTop)
        .background(colors.background.default)
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Constants.Spacing.contentVertical) {
                ForEach(viewModel.customFields) { entity in
                    switch entity {
                    case let entity as TreeFieldEntity:
                        TreeFieldView(entity: entity, onChange: viewModel.validateForm)
                    case let entity as ListFieldEntity:
                        ListFieldView(entity: entity, onChange: viewModel.validateForm)
                    default:
                        TextFieldView(entity: entity, onChange: viewModel.validateForm)
                    }
                }
                
                Spacer(minLength: Constants.Spacing.contentMinGap)
            }
        }
    }
    
    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.headerVertical) {
            Text(viewModel.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(colors.content.primary)
            
            Text(localization.prechatSurveySubtitle)
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

                Button(localization.commonConfirm, action: viewModel.onConfirm)
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
    let viewModel = FormViewModel(
        title: "Title",
        customFields: [
            MockData.textFieldEntity(),
            MockData.listFieldEntity(isRequired: true),
            MockData.treeFieldEntity()
        ],
        onAccept: { customFields in
            print("CustomFields: \(customFields)")
        },
        onCancel: {}
    )
    
    Color.clear
        .sheet(isPresented: .constant(true)) {
            FormView(viewModel: viewModel)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
