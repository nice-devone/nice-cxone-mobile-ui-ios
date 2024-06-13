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

import SwiftUI

protocol Alertable {
    
    var localization: ChatLocalization { get }
    
    func alertContent(for alertType: ChatAlertType) -> Alert
}

// MARK: - Default Implementation

extension Alertable {
    
    func alertContent(for alertType: ChatAlertType) -> Alert {
        let primaryAction: Alert.Button = alertType.primary
        let secondaryAction: Alert.Button? = alertType.secondary
        
        return secondaryAction.map { secondaryAction in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                primaryButton: primaryAction,
                secondaryButton: secondaryAction
            )
        } ?? Alert(
            title: Text(alertType.title),
            message: Text(alertType.message),
            dismissButton: primaryAction
        )
    }
}
