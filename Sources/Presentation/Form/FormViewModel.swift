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

class FormViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var customFields: [FormCustomFieldType]
    @Published var isFormValid = false
    
    let onAccept: ([String: String]) -> Void
    let onCancel: () -> Void

    let title: String

    // MARK: - Init

    init(
        title: String,
        customFields: [FormCustomFieldType],
        onAccept: @escaping ([String: String]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.customFields = customFields
        self.onAccept = onAccept
        self.onCancel = onCancel
        self.title = title
        
        // Trigger the validation if some fields are pre-filled so it can show errors
        validateForm()
    }
}

// MARK: - Internal Methods

extension FormViewModel {
    
    func onConfirm() {
        LogManager.trace("Confirming form")
        
        // Retrigger the validation (just in case)
        validateForm()
        
        if isFormValid {
            LogManager.trace("The form is valid, accepting the form")
            
            onAccept(getCustomFields())
        } else {
            LogManager.error("The form is not valid")
        }
    }
    
    func validateForm() {
        LogManager.trace("Validating form")
        
        isFormValid = self.customFields.allSatisfy { type in
            var isValid = true
            
            if let textfield = type as? TextFieldEntity, textfield.isEmail {
                isValid = type.value.isValidEmail
            }
            
            return type.isRequired
                ? !type.value.isEmpty && isValid
                : isValid
        }
    }
    
}

// MARK: - Private methods

private extension FormViewModel {
    
    func getCustomFields() -> [String: String] {
        var result = [String: String]()

        customFields.forEach { type in
            result[type.ident] = type.value
        }
        
        return result
    }
}
