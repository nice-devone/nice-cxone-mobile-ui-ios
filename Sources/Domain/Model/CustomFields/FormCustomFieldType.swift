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

import Foundation

/// Base form custom field type
///
/// This class is useful for representing and managing custom fields within forms
/// and can easily be used in SwiftUI views with data binding for dynamic updates and user interactions.
///
/// ## Example
/// ```
/// let customFields = [
///     FormCustomFieldType(label: "Email", isRequired: false, ident: "emailField", value: "john.doe@gmail.com"),
///     FormCustomFieldType(label: "First Name", isRequired: true, ident: "firstName", value: "John"),
///     FormCustomFieldType(label: "Last Name", isRequired: true, ident: "lastName", value: "Doe")
/// ]
///
/// chatCoordinator.presentForm(title: "User Details", customFields: customFields) {
///     ...
/// }
/// ```
public class FormCustomFieldType: ObservableObject, Identifiable {
    
    // MARK: - Properties
    
    /// The current value associated with the field, which can be updated and observed using the `@Published` property wrapper.
    @Published public var value: String
    
    /// The label or name of the custom field.
    public let label: String
    
    /// A boolean indicating whether this field is required to be filled out.
    public let isRequired: Bool
    
    /// A unique identifier or key for this field.
    public let ident: String
    
    // MARK: - Init
    
    /// Initialization of the FormCustomFieldType
    ///
    /// - Parameters:
    ///   - label: The label or name of the custom field.
    ///   - isRequired: A boolean indicating whether this field is required to be filled out.
    ///   - ident: A unique identifier or key for this field.
    ///   - value: The current value associated with the field, which can be updated and observed using the `@Published` property wrapper.
    public init(label: String, isRequired: Bool, ident: String, value: String) {
        self.label = label
        self.isRequired = isRequired
        self.ident = ident
        self.value = value
    }
}
