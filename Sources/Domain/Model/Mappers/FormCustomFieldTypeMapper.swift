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

import CXoneChatSDK
import Foundation

enum FormCustomFieldTypeMapper {
    
    static func map(_ customField: PreChatSurveyCustomField, with customFieldValues: [String: String]) -> FormCustomFieldType {
        switch customField.type {
        case .textField(let entity):
            return TextFieldEntity(
                label: entity.label,
                isRequired: customField.isRequired,
                ident: entity.ident,
                isEmail: entity.isEmail,
                value: customFieldValues[entity.ident]
            )
        case .selector(let entity):
            return ListFieldEntity(
                label: entity.label,
                isRequired: customField.isRequired,
                ident: entity.ident,
                options: entity.options,
                value: customFieldValues[entity.ident]
            )
        case .hierarchical(let entity):
            return TreeFieldEntity(
                label: entity.label,
                isRequired: customField.isRequired,
                ident: entity.ident,
                children: entity.nodes.map(mapChild),
                value: customFieldValues[entity.ident]
            )
        }
    }
    
    static func map(_ type: CustomFieldType) -> FormCustomFieldType {
        switch type {
        case .textField(let entity):
            return TextFieldEntity(label: entity.label, isRequired: false, ident: entity.ident, isEmail: entity.isEmail, value: entity.value)
        case .selector(let entity):
            return ListFieldEntity(label: entity.label, isRequired: false, ident: entity.ident, options: entity.options, value: entity.value)
        case .hierarchical(let entity):
            return TreeFieldEntity(label: entity.label, isRequired: false, ident: entity.ident, children: entity.nodes.map(mapChild), value: entity.value)
        }
    }
}

// MARK: - Helpers

private extension FormCustomFieldTypeMapper {
    
    static func mapChild(_ entity: CustomFieldHierarchicalNode) -> TreeNodeFieldEntity {
        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: entity.label, value: entity.value, children: entity.children.map(mapChild))
    }
}
