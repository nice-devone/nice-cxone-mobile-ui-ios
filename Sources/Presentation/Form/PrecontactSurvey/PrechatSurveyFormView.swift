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

struct PrechatSurveyFormView: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let contentVertical: CGFloat = 24
            static let contentMinGap: CGFloat = 20
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme

    @ObservedObject var viewModel: PrechatSurveyFormViewModel

    private let title: String
    
    // MARK: - Init

    init(viewModel: PrechatSurveyFormViewModel, title: String) {
        self.viewModel = viewModel
        self.title = title
    }

    // MARK: - Content

    var body: some View {
        FormView(viewModel: viewModel, title: title, subtitle: localization.prechatSurveySubtitle) {
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
    }
}

// MARK: - Preview

#Preview {
    let viewModel = PrechatSurveyFormViewModel(
        customFields: [
            MockData.textFieldEntity(),
            MockData.listFieldEntity(isRequired: true),
            MockData.treeFieldEntity(value: "iphone_14")
        ],
        onFinished: { customFields in
            print("CustomFields: \(customFields)")
        },
        onCancel: {}
    )
    
    Color.clear
        .sheet(isPresented: .constant(true)) {
            PrechatSurveyFormView(viewModel: viewModel, title: "Pre-chat survey")
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
