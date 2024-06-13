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

import Foundation

/// List field form custom field type
///
/// This class is useful for representing fields in forms that provide a list of options for the user to choose from. 
/// It can be easily integrated into SwiftUI views and offers flexibility in managing user selections and interactions.
///
/// ## Example
/// ```
/// let customFields = [
///     ListFieldEntity(label: "Color", isRequired: false, ident: "color", options: ["blue": "Blue", "yellow": "Yellow", "red": "Red"], value: "blue"),
///     ListFieldEntity(label: "Type", isRequired: false, ident: "type", options: ["optionA": "A", "optionB": "B", "optionC": "C"], value: "")
/// ]
///
/// chatCoordinator.presentForm(title: "List Options", customFields: customFields) {
///     ...
/// }
/// ```
public class ListFieldEntity: FormCustomFieldType {
    
    // MARK: - Properties
    
    /// A dictionary that holds a set of options where the keys represent option values and the values represent option labels.
    public let options: [String: String]

    // MARK: - Init

    /// Initialization of the ListFieldEntity
    ///
    /// - Parameters:
    ///   - label: The label or name of the custom field.
    ///   - isRequired: A boolean indicating whether this field is required to be filled out.
    ///   - ident: A unique identifier or key for this field.
    ///   - options: A dictionary that holds a set of options where the keys represent option values and the values represent option labels.
    ///   - value: The current value associated with the field, which can be updated and observed using the `@Published` property wrapper.
    public init(label: String, isRequired: Bool, ident: String, options: [String: String], value: String? = nil) {
        self.options = options
        
        super.init(label: label, isRequired: isRequired, ident: ident, value: value ?? "")
    }
}
