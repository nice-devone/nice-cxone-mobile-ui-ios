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

/// Tree field form custom field type
///
/// This class is designed for representing hierarchical tree structures within forms. 
/// The `children` property allows you to define the hierarchy of child nodes, 
/// making it suitable for capturing complex data structures.
/// It can be easily integrated into SwiftUI views for managing and displaying hierarchical data in forms.
///
/// ## Example
/// ```
/// let children = [...]
/// let treeFieldEntity = TreeFieldEntity(label: "Devices", isRequired: true, ident: "devices", children: children, value: "iPhone 14")
///
/// chatCoordinator.presentForm(title: "Tree Options", customFields: [treeFieldEntity]) {
///     ...
/// }
/// ```
public class TreeFieldEntity: FormCustomFieldType {

    // MARK: - Properties

    /// An array of `TreeNodeFieldEntity` objects, representing the children of the tree field.
    public var children: [TreeNodeFieldEntity]

    // MARK: - Init
    
    /// Initialization of the TreeFieldEntity
    ///
    /// - Parameters:
    ///   - label: The label or name of the custom field.
    ///   - isRequired: A boolean indicating whether this field is required to be filled out.
    ///   - ident: A unique identifier or key for this field.
    ///   - children: An array of `TreeNodeFieldEntity` objects, representing the children of the tree field.
    ///   - value: The current value associated with the field, which can be updated and observed using the `@Published` property wrapper.
    public init(label: String, isRequired: Bool, ident: String, children: [TreeNodeFieldEntity] = [], value: String? = nil) {
        self.children = children
        
        super.init(label: label, isRequired: isRequired, ident: ident, value: value ?? "")
    }
}
