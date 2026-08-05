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

import SwiftUI

struct TextFieldView: View {
    
    // MARK: - Properties
    
    @ObservedObject private var entity: FormCustomFieldType

    @Binding private var compareWith: String

    @State private var currentError: String?

    private let placeholder: String?
    private let onChange: () -> Void

    private var isEmail: Bool {
        (entity as? TextFieldEntity)?.isEmail ?? false
    }

    private var fieldTitle: String {
        entity.isRequired
            ? L10n.Form.requiredLabel(entity.label)
            : entity.label
    }

    private var fieldValidator: (String) -> String? {
        allOf(
            entity.isRequired ? required : any,
            isEmail ? email : any,
            !compareWith.isEmpty ? compare(compareWith) : any
        )
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
            fieldTitle,
            text: $entity.value,
            placeholder: placeholder,
            validator: fieldValidator,
            // Apply the field-level identifier to the inner, editable `TextField` itself.
            // A wrapping `.accessibilityElement(children: .combine)` here would collapse the
            // subtree into a single `XCUIElementTypeOther`, which is not typeable (breaking
            // UI automation `sendKeys`) and strips the editable text-field trait from VoiceOver.
            accessibilityIdentifier: A11y.Form.TextFieldView.identifier(entity.label)
        )
        .if(isEmail) { view in
            view
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
        }
        .onChange(of: entity.value) { newValue in
            onChange()

            // Validate and track error state for accessibility announcements
            let newError = fieldValidator(newValue)

            // Only announce when error state changes
            if newError != currentError {
                currentError = newError
                // Announce immediately when error appears
                if let error = newError {
                    A11y.announce("\(fieldTitle), \(error)")
                }
            }
        }
        .onAppear {
            // Run validator initially to set correct state for required fields
            currentError = fieldValidator(entity.value)
        }
    }
}

// MARK: - Previews

// swiftlint:disable hardcoded_strings sf_symbol_key_in_image
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
}
// swiftlint:enable hardcoded_strings sf_symbol_key_in_image
