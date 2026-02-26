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

struct TextFieldView: View {
    
    // MARK: - Properties
    
    @ObservedObject private var entity: FormCustomFieldType
    
    @EnvironmentObject private var localization: ChatLocalization

    @Binding private var compareWith: String
    
    private let placeholder: String?
    private let onChange: () -> Void
    
    private var isEmail: Bool {
        (entity as? TextFieldEntity)?.isEmail ?? false
    }
    
    // MARK: - Init
    
    init(entity: FormCustomFieldType, placeholder: String? = nil, compareWith: Binding<String>? = nil, onChange: @escaping () -> Void) {
        self.entity = entity
        self.placeholder = placeholder
        self._compareWith = compareWith ?? .constant("")
        self.onChange = onChange
    }
    
    // MARK: - Content
    
    var body: some View {
        ValidatedTextField(
            entity.isRequired
                ? String(format: localization.formRequiredLabel, entity.label)
                : entity.label,
            text: $entity.value,
            placeholder: placeholder,
            validator: allOf(
                entity.isRequired ? required(localization) : any,
                isEmail ? email(localization) : any,
                !compareWith.isEmpty ? compare(compareWith, localization) : any
            )
        )
        .if(isEmail) { view in
            view
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
        }
        .onChange(of: entity.value) { _ in
            onChange()
        }
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var firstNameEntity = TextFieldEntity(label: "First Name", isRequired: true, ident: "firstName", isEmail: false)
    @Previewable @State var ageEntity = TextFieldEntity(label: "Age", isRequired: false, ident: "age", isEmail: false)
    @Previewable @State var emailEntity = TextFieldEntity(label: "E-mail", isRequired: false, ident: "email", isEmail: true)
    @Previewable @State var emailConfirmationEntity = TextFieldEntity(label: "Confirm e-mail", isRequired: true, ident: "confirm_email", isEmail: true)
    @Previewable @State var isValid = false
    
    VStack(spacing: 24) {
        TextFieldView(entity: firstNameEntity) {
            isValid = firstNameEntity.value.isEmpty == false && emailEntity.value == emailConfirmationEntity.value
        }
        
        TextFieldView(entity: ageEntity) {
            isValid = firstNameEntity.value.isEmpty == false && emailEntity.value == emailConfirmationEntity.value
        }
        
        TextFieldView(entity: emailEntity, placeholder: "Enter your e-mail") {
            isValid = firstNameEntity.value.isEmpty == false && emailEntity.value == emailConfirmationEntity.value
        }
        
        TextFieldView(entity: emailConfirmationEntity, placeholder: "Confirm your e-mail", compareWith: $emailEntity.value) {
            isValid = firstNameEntity.value.isEmpty == false && emailEntity.value == emailConfirmationEntity.value
        }
        
        HStack {
            if isValid {
                Image(systemName: "checkmark.circle")
                
                Text("Valid")
            } else {
                Image(systemName: "xmark.circle")
                
                Text("Invalid")
            }
        }
        .foregroundStyle(isValid ? .green : .red)
    }
    .padding(.horizontal, 16)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
