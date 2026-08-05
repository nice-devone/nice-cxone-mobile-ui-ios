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

/// A view-model protocol for publishing alert presentation state to SwiftUI views.
///
/// Conforming types expose an optional `alertType` that drives whether an alert
/// should be shown. Update this value to present or dismiss alerts in the UI.
@MainActor
protocol AlertableViewModel: ObservableObject {
    /// The current alert configuration to present, or `nil` if no alert is active.
    var alertType: ChatAlertType? { get set }
}

// MARK: - View+Alertable

extension View {

    /// Presents an alert for a given `ChatAlertType`.
    @ViewBuilder
    func alertable(isPresented: Binding<Bool>, presenting alertType: ChatAlertType?) -> some View {
        self.alert(alertType?.title ?? "", isPresented: isPresented, presenting: alertType) { alertType in
            alertType.actions
        } message: { alertType in
            alertType.message
        }
    }
}

// MARK: - Helpers

extension AlertableViewModel {

    /// A binding that reflects whether an alert should currently be presented.
    ///
    /// - Get: Returns `true` when `alertType` is non-`nil`.
    /// - Set: When set to `false`, clears `alertType` to dismiss the alert.
    var showAlert: Binding<Bool> {
        Binding(
            get: { self.alertType != nil },
            set: { newValue in
                if !newValue {
                    self.alertType = nil
                }
            }
        )
    }
}
