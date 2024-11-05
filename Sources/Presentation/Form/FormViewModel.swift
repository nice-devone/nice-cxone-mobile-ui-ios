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
import SwiftUI

class FormViewModel: ChatContainerViewModel.ChildViewModel {
    
    // MARK: - Properties
    
    @Published var customFields: [FormCustomFieldType]
    
    let onAccept: ([String: String]) -> Void

    var nodeSelected: TreeFieldEntity?
    
    // MARK: - Init

    init(
        containerViewModel: ChatContainerViewModel,
        title: String,
        customFields: [FormCustomFieldType],
        localization: ChatLocalization,
        onAccept: @escaping ([String: String]) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.customFields = customFields
        self.onAccept = onAccept

        super.init(left: containerViewModel.back(title: localization.commonCancel, action: onCancel), title: Text(title))

        self.content = { AnyView(FormView(viewModel: self)) }
    }
}

// MARK: - Internal Methods

extension FormViewModel {
    
    func isValid() -> Bool {
        self.customFields.allSatisfy { type in
            type.isRequired ? !type.value.isEmpty : true
        }
    }

    func getCustomFields() -> [String: String] {
        var result = [String: String]()

        customFields.forEach { type in
            result[type.ident] = type.value
        }
        
        return result
    }
}
