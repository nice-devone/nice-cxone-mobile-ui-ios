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

class PrechatSurveyFormViewModel: FormViewModel<[String: String]> {
    
    // MARK: - Properties
    
    @Published var customFields: [FormCustomFieldType]

    // MARK: - Init

    init(
        customFields: [FormCustomFieldType],
        onFinished: @escaping ([String: String]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.customFields = customFields
        super.init(onFinished: onFinished, onCancel: onCancel)
    }
    
    // MARK: - Methods
    
    override func onSubmit() {
        LogManager.trace("Confirming form")
        
        // Retrigger the validation (just in case)
        validateForm()
        
        if isFormValid {
            LogManager.trace("The form is valid, accepting the form")
            
            onFinished(getCustomFields())
        } else {
            LogManager.error("The form is not valid")
        }
    }
    
    override func validateForm() {
        LogManager.trace("Validating form")

        self.firstInvalidFieldID = customFields
            .first { field in
                // Check if the custom field is an e-mail with valid value
                if let textfield = field as? TextFieldEntity, textfield.hasInvalidEmail {
                    return true
                } else {
                    // Required fields must be non-empty
                    return field.isMissingRequiredValue
                }
            }?
            .id

        isFormValid = firstInvalidFieldID == nil
    }
}

// MARK: - Private methods

private extension PrechatSurveyFormViewModel {
    
    func getCustomFields() -> [String: String] {
        var result = [String: String]()

        customFields.forEach { type in
            result[type.ident] = type.submissionValue
        }
        
        return result
    }
}
