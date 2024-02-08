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

import SwiftUI

extension View {
    
    func alert(
        isPresented: Binding<Bool>,
        title: String = "Oops!",
        message: String = "Something went wrong. Try it again later or contact the CXone Mobile team.",
        dismissButton: Alert.Button = .cancel()
    ) -> some View {
        alert(isPresented: isPresented) {
            Alert(title: Text(title), message: Text(message), dismissButton: dismissButton)
        }
    }
    
    func alert(
        isPresented: Binding<Bool>,
        title: String = "Oops!",
        message: String = "Something went wrong. Try it again later or contact the CXone Mobile team.",
        primaryButton: Alert.Button,
        secondaryButton: Alert.Button
    ) -> some View {
        alert(isPresented: isPresented) {
            Alert(title: Text(title), message: Text(message), primaryButton: primaryButton, secondaryButton: secondaryButton)
        }
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
    
    /// Closure given view and unwrapped optional value if optional is set.
    /// - Parameters:
    ///   - conditional: Optional value.
    ///   - content: Closure to run on view with unwrapped optional.
    @ViewBuilder
    func ifNotNil<Content: View, T>(_ conditional: T?, @ViewBuilder _ content: (Self, _ value: T) -> Content) -> some View {
        if let value = conditional {
            content(self, value)
        } else {
            self
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
