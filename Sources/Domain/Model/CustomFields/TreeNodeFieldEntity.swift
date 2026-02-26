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

/// Child of the ``TreeFieldEntity`` custom field type
///
/// This class is designed for representing individual nodes within a hierarchical tree structure,
/// and it can be used to create complex hierarchical data models for use in forms and other applications.
///
/// ```
/// let children = [
///     TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Mobile Phone", value: "phone", children: [
///         TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Apple", value: "apple", children: [
///             TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "iPhone 15", value: "iphone_15"),
///             TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "iPhone 15 Pro", value: "iphone_15_pro")
///         ]),
///         TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Android", value: "android", children: [
///             ...
///         ])
///     ]),
///     TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Laptop", value: "laptop", children: [
///         TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "MacOS", value: "macos", children: [
///             TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "MacBook", value: "macbook"),
///             TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "MacBook Pro", value: "macbook_pro")
///         ]),
///         TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Windows", value: "windows", children: [
///             ...
///         ]),
///         TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Linux", value: "linux", children: [
///             ...
///         ])
///     ]),
///     TreeNodeFieldEntity(id: LowercaseUUID().uuidString, label: "Other", value: "other")
/// ]
/// let treeFieldEntity = TreeFieldEntity(...)
///
/// chatCoordinator.presentForm(title: "Tree Options", customFields: [treeFieldEntity]) {
///     ...
/// }
/// ```
public class TreeNodeFieldEntity: ObservableObject, Identifiable {
    
    // MARK: - Properties
    
    /// The unique identifier of the tree node.
    @available(*, deprecated, renamed: "idString", message: "Use `idString`. It preserves the original case-sensitive identifier from the backend.")
    public let id: UUID // swiftlint:disable:this no_uuid
    
    /// The unique identifier of the tree node.
    public let idString: String
    
    /// The label or name associated with the tree node.
    public let label: String
    
    /// The value or unique identifier of the tree node.
    public let value: String
    
    /// An array of `TreeNodeFieldEntity` objects, representing child nodes within the tree.
    public let children: [TreeNodeFieldEntity]?
    
    /// A boolean flag indicating whether the tree node is currently selected.
    public var isSelected: Bool
    
    // MARK: - Init
    
    /// Initialization of the ListFieldEntity
    ///
    /// - `id`: The unique identifier of the tree node.
    /// - `label`: The label or name associated with the tree node.
    /// - `value`: The value or unique identifier of the tree node.
    /// - `children`: An array of `TreeNodeFieldEntity` objects, representing child nodes within the tree.
    /// - `isSelected`: A boolean flag indicating whether the tree node is currently selected.
    @available(*, deprecated, message: "Due to replacement of the `id` atrribute with `idString`, this initializer will be removed in a future.")
    public init(
        id: UUID = UUID(), // swiftlint:disable:this no_uuid
        label: String,
        value: String,
        children: [TreeNodeFieldEntity]? = nil,
        isSelected: Bool = false
    ) {
        self.id = id
        self.idString = id.uuidString
        self.label = label
        self.value = value
        self.children = children
        self.isSelected = isSelected
    }
    
    /// Initialization of the ListFieldEntity
    ///
    /// - `id`: The unique identifier of the tree node.
    /// - `label`: The label or name associated with the tree node.
    /// - `value`: The value or unique identifier of the tree node.
    /// - `children`: An array of `TreeNodeFieldEntity` objects, representing child nodes within the tree.
    /// - `isSelected`: A boolean flag indicating whether the tree node is currently selected.
    init(
        id: String = LowercaseUUID().uuidString,
        label: String,
        value: String,
        children: [TreeNodeFieldEntity]? = nil,
        isSelected: Bool = false
    ) {
        self.id = UUID() // swiftlint:disable:this no_uuid
        self.idString = id
        self.label = label
        self.value = value
        self.children = children
        self.isSelected = isSelected
    }
}
