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

struct AlertTextFieldView: View {

    // MARK: - Properties

    @State private var text = ""

    @Binding var isPresented: Bool

    let onConfirm: (String) -> Void

    // MARK: - Body

    var body: some View {
        VStack {
            TextField(L10n.Alert.UpdateThreadName.placeholder, text: $text)
                .accessibilityIdentifier(A11y.Alert.UpdateThreadName.identifier)

            HStack {
                Button(L10n.Common.confirm) {
                    onConfirm(text)
                    text = ""
                    isPresented = false
                }

                Button(L10n.Common.cancel, role: .cancel) {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - Preview

// swiftlint:disable hardcoded_strings
@available(iOS 17.0, *)
#Preview("Alert Text Field") {
    @Previewable @State var text = ""
    @Previewable @State var isPresented = true

    VStack {
        Text(text)

        Button("Show") {
            isPresented = true
        }
    }
    .alert(L10n.Alert.UpdateThreadName.title, isPresented: $isPresented) {
        AlertTextFieldView(isPresented: $isPresented) { newText in
            text = newText
        }
    }
}
// swiftlint:enable hardcoded_strings
