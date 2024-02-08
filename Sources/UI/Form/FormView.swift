//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

struct FormView: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    
    @ObservedObject var viewModel: FormViewModel

    let title: String
    
    private let onFinished: ([String: String]) -> Void
    private let onCancel: () -> Void

    // MARK: - Init

    init(title: String, viewModel: FormViewModel, onFinished: @escaping ([String: String]) -> Void, onCancel: @escaping () -> Void) {
        self.title = title
        self.viewModel = viewModel
        self.onFinished = onFinished
        self.onCancel = onCancel
    }

    // MARK: - Content

    var body: some View {
        VStack {
            Text(title)
                .padding()
                .foregroundColor(style.formTextColor)
            
            ScrollView(showsIndicators: false) {
                ForEach($viewModel.customFields.wrappedValue) { entity in
                    switch entity {
                    case let entity as TreeFieldEntity:
                        TreeFieldView(entity: entity)
                            .padding(.vertical, 4)
                    case let entity as ListFieldEntity:
                        ListFieldView(entity: entity)
                            .padding(.vertical, 4)
                    default:
                        TextFieldView(entity: entity)
                            .padding(.vertical, 4)
                    }
                }
            }
            
            Spacer()

            cancelConfirmButtonsStack
        }
        .padding([.top, .leading, .trailing], 12)
        .padding(.bottom, UIDevice.current.hasHomeButton ? 12 : 32)
        .background(style.backgroundColor)
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension FormView {

    var cancelConfirmButtonsStack: some View {
        HStack {
            Button("Cancel") {
                onCancel()
            }
            .buttonStyle(PrimaryButtonStyle(chatStyle: style))

            Button("Confirm") {
                guard viewModel.isValid() else {
                    return
                }
                                
                onFinished(viewModel.getCustomFields())
            }
            .buttonStyle(PrimaryButtonStyle(chatStyle: style))
        }
    }
}

// MARK: - Previews

struct FormView_Previews: PreviewProvider {
    
    private static let viewModel = FormViewModel(customFields: customFields)
    private static let customFields: [FormCustomFieldType] = [
        TextFieldEntity(label: "First Name", isRequired: true, ident: "firstName", isEmail: false),
        ListFieldEntity(label: "Color", isRequired: false, ident: "color", options: ["blue": "Blue", "yellow": "Yellow"]),
        TreeFieldEntity(
            label: "Device",
            isRequired: true,
            ident: "device",
            children: [
                TreeNodeFieldEntity(label: "iPhone", value: "iphone"),
                TreeNodeFieldEntity(label: "Samsung", value: "samsung")
            ]
        )
    ]
    
    static var previews: some View {
        Group {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    FormView(title: "Details", viewModel: viewModel) { _ in } onCancel: {}
                }
                .previewDisplayName("Light Mode")
            
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    FormView(title: "Details", viewModel: viewModel) { _ in } onCancel: {}
                }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
