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

import SwiftUI

struct TextFieldView: View {
    
    // MARK: - Properties
    
    @ObservedObject var entity: FormCustomFieldType
    
    @EnvironmentObject private var localization: ChatLocalization

    private var isEmail: Bool {
        (entity as? TextFieldEntity)?.isEmail ?? false
    }

    // MARK: - Content
    
    var body: some View {
        ValidatedTextField(
            entity.label,
            text: $entity.value,
            validator: allOf(
                entity.isRequired ? required(localization) : any,
                isEmail ? email(localization) : any
            ),
            label: entity.label
        )
        .keyboardType(isEmail ? .emailAddress : .default)
    }
}

// MARK: - Previews

struct TextFieldView_Previews: PreviewProvider {

    private static let firstNameEntity = TextFieldEntity(label: "First Name", isRequired: true, ident: "firstName", isEmail: false)
    private static let ageEntity = TextFieldEntity(label: "Age", isRequired: false, ident: "age", isEmail: false)
    private static let emailEntity = TextFieldEntity(label: "E-mail", isRequired: false, ident: "email", isEmail: true)
    private static let localization = ChatLocalization()

    static var previews: some View {
        Group {
            VStack {
                TextFieldView(entity: firstNameEntity)
                
                TextFieldView(entity: ageEntity)
                
                TextFieldView(entity: emailEntity)
            }
            .previewDisplayName("Light Mode")
            
            VStack {
                TextFieldView(entity: firstNameEntity)
                
                TextFieldView(entity: ageEntity)
                
                TextFieldView(entity: emailEntity)
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
