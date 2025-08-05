//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

struct FormView: View {

    // MARK: - Properties

    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject private var style: ChatStyle
    
    @ObservedObject var viewModel: FormViewModel

    // MARK: - Init

    init(viewModel: FormViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Content

    var body: some View {
        VStack {
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

            Button(localization.commonConfirm) { [weak viewModel] in
                guard let viewModel = viewModel, viewModel.isValid() == true else {
                    return
                }

                viewModel.onAccept(viewModel.getCustomFields())
            }
            .buttonStyle(PrimaryButtonStyle(chatStyle: style))
        }
        .onTapGesture(perform: hideKeyboard)
        .padding([.top, .leading, .trailing], 12)
        .padding(.bottom, UIDevice.current.hasHomeButton ? 12 : 32)
        .background(style.backgroundColor)
        .ignoresSafeArea()
    }
}

// MARK: - Previews

struct FormView_Previews: PreviewProvider {
    
    private static let viewModel = FormViewModel(
        containerViewModel: ChatContainerViewModel(
            chatProvider: CXoneChat.shared,
            chatLocalization: ChatLocalization()
        ) {},
        title: "Title",
        customFields: customFields,
        localization: ChatLocalization(), 
        onAccept: { _ in },
        onCancel: {}
    )
    
    private static let customFields: [FormCustomFieldType] = [
        TextFieldEntity(label: "First Name", isRequired: true, ident: "firstName", isEmail: false),
        ListFieldEntity(label: "Color", isRequired: false, ident: "color", options: ["blue": "Blue", "yellow": "Yellow"]),
        TreeFieldEntity(
            label: "Device",
            isRequired: true,
            ident: "device",
            children: [
                TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "iPhone", value: "iphone"),
                TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Samsung", value: "samsung")
            ]
        )
    ]
    
    static var previews: some View {
        Group {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    FormView(viewModel: viewModel)
                }
                .previewDisplayName("Light Mode")
            
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    FormView(viewModel: viewModel)
                }
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
