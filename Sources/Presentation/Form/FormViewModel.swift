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

open class FormViewModel<T>: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isFormValid = false
    
    var onFinished: (T) -> Void
    var onCancel: () -> Void
    
    init(onFinished: @escaping (T) -> Void, onCancel: @escaping () -> Void) {
        self.onFinished = onFinished
        self.onCancel = onCancel
        
        // Trigger validation in case fields are pre-populated
        validateForm()
    }
    
    // MARK: - Methods
    
    open func onSubmit() {
        // Add custom implementation
    }
    
    open func validateForm() {
        // Add custom implementation
    }
}
