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

import Foundation

/// List field form custom field type
///
/// This class is designed for managing text input fields within forms, 
/// and the `isEmail` flag allows you to specify whether the field should validate email addresses. 
/// It can be seamlessly integrated into SwiftUI views, providing flexibility in handling various text-based input requirements.
///
/// ## Example
/// ```
/// let customFields = [
///     TextFieldEntity(label: "Full Name", isRequired: true, ident: "userName", isEmail: false, value: "Peter Parker"),
///     TextFieldEntity(label: "E-mail", isRequired: false, ident: "email", isEmail: true, value: "p.parker@gmail.com")
/// ]
///
/// chatCoordinator.presentForm(title: "User Details", customFields: customFields) {
///     ...
/// }
/// ```
public class TextFieldEntity: FormCustomFieldType {

    // MARK: - Properties
    
    /// A boolean flag indicating whether this text field is expected to contain an email address.
    public let isEmail: Bool
    
    // MARK: - Init
    
    /// Initialization of the TextFieldEntity
    ///
    /// - Parameters:
    ///   - label: The label or name of the custom field.
    ///   - isRequired: A boolean indicating whether this field is required to be filled out.
    ///   - ident: A unique identifier or key for this field.
    ///   - isEmail: A boolean flag indicating whether this text field is expected to contain an email address.
    ///   - value: The current value associated with the field, which can be updated and observed using the `@Published` property wrapper.
    public init(label: String, isRequired: Bool, ident: String, isEmail: Bool, value: String? = nil) {
        self.isEmail = isEmail
        
        super.init(label: label, isRequired: isRequired, ident: ident, value: value ?? "")
    }
}
