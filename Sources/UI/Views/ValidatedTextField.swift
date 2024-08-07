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

import Combine
import SwiftUI

struct ValidatedTextField: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @Binding var text: String
    
    @State var error: String?
    
    let label: String?
    let title: String
    let validator: ((String) -> String?)?

    // MARK: - Init
    
    init(
        _ title: String,
        text: Binding<String>,
        validator: ((String) -> String?)? = nil,
        label: String? = nil,
        error: String? = nil
    ) {
        self.title = title
        self._text = text
        self.validator = validator
        self.error = error
        self.label = label
    }
    
    // MARK: - Builder
    
    var body: some View {
        let error = validator?(text)
        
        VStack(alignment: .leading, spacing: 4) {
            if let label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(style.formTextColor)
            }
            
            VStack(alignment: .leading) {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(title)
                            .foregroundColor(style.formTextColor.opacity(0.5))
                    }
                    .font(.body)
                    .foregroundColor(style.formTextColor)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                Divider()
                    .background(error == nil ? Color(.separator) : .red)
                
                if let error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(style.formErrorColor)
                }
            }
        }
    }
}

// MARK: - Validators

func required(_ localization: ChatLocalization) -> (String) -> String? {
    { text in
        text.isEmpty ? localization.commonRequired : nil
    }
}

func numeric(_ localization: ChatLocalization) -> (String) -> String? {
    { text in
        text.isEmpty
            ? nil
            : (Double(text) == nil) ? localization.commonInvalidNumber : nil
    }
}

func email(_ localization: ChatLocalization) -> (String) -> String? {
    { text in
        let emailRegEx = #"^(?:|([A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}))$"#
        let isValidFormat = text.range(of: emailRegEx, options: [.regularExpression]) != nil

        return !isValidFormat ? localization.commonInvalidEmail : nil
    }
}

func any(_: String) -> String? {
    nil
}

func allOf(_ validators: ((String) -> String?)...) -> (String) -> String? {
    { text in
        validators.reduce(nil) { error, validator in
            error ?? validator(text)
        }
    }
}

// MARK: - Helpers

private extension View {
    
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            
            self
        }
    }
}

// MARK: - Preview

struct ValidatedTextField_Previews: PreviewProvider {
    
    @State static var text: String = ""

    private static let localization = ChatLocalization()

    private static var isRequired: (String) -> String? {
        required(localization)
    }
    private static var isEmail: (String) -> String? {
        email(localization)
    }
    private static var isNumeric: (String) -> String? {
        numeric(localization)
    }

    static var previews: some View {
        Group {
            ScrollView {
                VStack(spacing: 24) {
                    ValidatedTextField("Placeholder", text: $text, label: "Text")
                    
                    ValidatedTextField("Placeholder", text: $text, validator: isRequired, label: "Required Text")

                    ValidatedTextField("Placeholder", text: $text, validator: isNumeric, label: "Numeric")
                        .keyboardType(.decimalPad)
                    
                    ValidatedTextField("Placeholder", text: $text, validator: allOf(isNumeric, isRequired), label: "Required Numeric")
                        .keyboardType(.decimalPad)
                    
                    ValidatedTextField("Placeholder", text: $text, validator: isEmail, label: "Email")
                        .keyboardType(.emailAddress)
                    
                    ValidatedTextField("Placeholder", text: $text, validator: allOf(isRequired, isEmail), label: "Required Email")
                        .keyboardType(.emailAddress)
                }
            }
            .padding(.horizontal, 24)
            .previewDisplayName("Light Mode")
            
            ScrollView {
                VStack(spacing: 24) {
                    ValidatedTextField("Placeholder", text: $text, label: "Text")
                    
                    ValidatedTextField("Placeholder", text: $text, validator: isRequired, label: "Required Text")

                    ValidatedTextField("Placeholder", text: $text, validator: isNumeric, label: "Numeric")
                        .keyboardType(.decimalPad)
                    
                    ValidatedTextField("Placeholder", text: $text, validator: allOf(isNumeric, isRequired), label: "Required Numeric")
                        .keyboardType(.decimalPad)
                    
                    ValidatedTextField("Placeholder", text: $text, validator: isEmail, label: "Email")
                        .keyboardType(.emailAddress)
                    
                    ValidatedTextField("Placeholder", text: $text, validator: allOf(isRequired, isEmail), label: "Required Email")
                        .keyboardType(.emailAddress)
                }
            }
            .padding(.horizontal, 24)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatStyle())
        .environmentObject(localization)
    }
}
