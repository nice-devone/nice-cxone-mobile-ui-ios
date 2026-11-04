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
        FormView(viewModel: viewModel, title: title, subtitle: subtitle, subtitleAccessibilityLabel: L10n.PreChatSurvey.subtitle) { proxy in
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
            .onChange(of: viewModel.firstInvalidFieldID) { target in
                guard let target else {
                    return
                }

                withAnimation {
                    proxy.scrollTo(target, anchor: .center)
                }

                A11y.announce(A11y.Announcement.Form.Validation.Invalid.argument)
            }
        }
    }
}

// MARK: - Private Methods

private extension PrechatSurveyFormView {

    /// Appends the required-fields legend to the base subtitle when the form has at least one
    /// required field — sighted users otherwise have no explanation for what "*" means on a field
    /// label. VoiceOver users already hear "Required" explicitly on each field's own accessibility
    /// label/value, so this is meant to be a visual-only addition — enforced by always passing the
    /// base subtitle as `FormView`'s `subtitleAccessibilityLabel`, since the legend text itself
    /// contains a bare "*" that VoiceOver's default punctuation verbosity wouldn't speak, and the
    /// `Text` isn't otherwise hidden from accessibility.
    var subtitle: String {
        viewModel.customFields.contains { entity in
            entity.isRequired
        }
            ? L10n.PreChatSurvey.subtitleWithRequiredFieldsLegend(L10n.PreChatSurvey.subtitle, L10n.PreChatSurvey.requiredFieldsLegend)
            : L10n.PreChatSurvey.subtitle
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
            NavigationStack {
                PrechatSurveyFormView(viewModel: viewModel, title: "Pre-chat survey")
            }
        }
        .environmentObject(ChatStyle())
}
