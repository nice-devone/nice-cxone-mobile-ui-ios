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

    // MARK: - Properties

    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme

    @ObservedObject var viewModel: FormViewModel
    
    @State var isFormValid = false
    
    private static let paddingTopControlButtons: CGFloat = 12
    private static let paddingBottomControlButtons: CGFloat = 40
    private static let sectionSpacing: CGFloat = 24
    private static let paddingTopScrollView: CGFloat = 24
    private static let paddingHorizontalGroup: CGFloat = 16
    private static let paddingTopContent: CGFloat = 48
    private static let paddingEdgeControlButtons: CGFloat = 16
    private static let paddingBottomSubtitle: CGFloat = 10

    // MARK: - Init

    init(viewModel: FormViewModel) {
        self.viewModel = viewModel
        self.isFormValid = viewModel.isValid()
    }

    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, Self.paddingHorizontalGroup)
            
            ColoredDivider(colors.customizable.onBackground.opacity(0.1))
                .padding(.horizontal, -Self.paddingHorizontalGroup)
            
            content
            
            controlButtons
        }
        .interactiveDismissDisabled()
        .ignoresSafeArea()
        .onTapGesture(perform: hideKeyboard)
        .padding(.top, Self.paddingTopContent)
        .background(colors.customizable.background)
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Self.sectionSpacing) {
                ForEach(viewModel.customFields) { entity in
                    switch entity {
                    case let entity as TreeFieldEntity:
                        TreeFieldView(entity: entity)
                            .onReceive(entity.$value) {_ in
                                self.isFormValid = viewModel.isValid()
                            }
                    case let entity as ListFieldEntity:
                        ListFieldView(entity: entity)
                            .onReceive(entity.$value) {_ in
                                self.isFormValid = viewModel.isValid()
                            }
                            .padding(.trailing, Self.paddingHorizontalGroup)
                    default:
                        TextFieldView(entity: entity)
                            .onReceive(entity.$value) {_ in
                                self.isFormValid = viewModel.isValid()
                            }
                            .padding(.trailing, Self.paddingHorizontalGroup)
                    }
                }
            }
        }
        .padding(.top, Self.paddingTopScrollView)
        .padding(.leading, Self.paddingHorizontalGroup)
    }
    
    @ViewBuilder
    private var header: some View {
        Text(viewModel.title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(colors.customizable.onBackground)
        
        Text(localization.prechatSurveySubtitle)
            .font(.subheadline)
            .foregroundStyle(colors.customizable.onBackground)
            .opacity(0.50)
            .padding(.bottom, Self.paddingBottomSubtitle)
    }
    
    private var controlButtons: some View {
        HStack {
            Button(localization.commonCancel, action: viewModel.onCancel)
            
            Spacer()

            Button(localization.commonConfirm) { [weak viewModel] in
                guard let viewModel = viewModel, viewModel.isValid() == true else {
                    return
                }
                
                viewModel.onAccept(viewModel.getCustomFields())
            }
            .disabled(!isFormValid)
        }
        .font(.body.weight(.medium))
        .padding(.top, Self.paddingTopControlButtons)
        .padding(.horizontal, Self.paddingEdgeControlButtons)
        .padding(.bottom, Self.paddingBottomControlButtons)
        .background(colors.customizable.onBackground.opacity(0.05))
    }
}

// MARK: - Preview

#Preview {
    let viewModel = FormViewModel(
        title: "Title",
        customFields: [
            MockData.textFieldEntity(),
            MockData.listFieldEntity(),
            MockData.treeFieldEntity()
        ],
        onAccept: { _ in },
        onCancel: {}
    )
    
    Color.clear
        .sheet(isPresented: .constant(true)) {
            FormView(viewModel: viewModel)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
