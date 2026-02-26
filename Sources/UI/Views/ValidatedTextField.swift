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

import Combine
import SwiftUI

struct ValidatedTextField: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let dividerFocusedHeight: CGFloat = 2
            static let dividerHeight: CGFloat = 1
        }
        
        enum Spacing {
            static let bodyVertical: CGFloat = 6
            static let textFieldDividerSpacing: CGFloat = 8
        }
        
        enum Padding {
            static let textFieldVertical: CGFloat = 4
            static let errorTextBottom: CGFloat = 4
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @FocusState private var isFocused: Bool
    
    @Binding var text: String
    
    @State private var error: String?
    
    let title: String
    let placeholder: String?
    let validator: ((String) -> String?)?
    
    // MARK: - Init
    
    init(
        _ title: String,
        text: Binding<String>,
        placeholder: String? = nil,
        validator: ((String) -> String?)? = nil,
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.validator = validator
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.bodyVertical) {
            Text(title)
                .font(.callout)
                .bold()
                .foregroundStyle(error == nil ? colors.content.primary : colors.status.error)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.textFieldDividerSpacing) {
                TextField(placeholder ?? "", text: $text)
                .tint(error == nil ? colors.content.primary : colors.status.error)
                .foregroundStyle(error == nil ? colors.content.primary : colors.status.error)
                .padding(.vertical, Constants.Padding.textFieldVertical)
                .autocapitalization(.none)
                .submitLabel(.done)
                .focused($isFocused)
                .onSubmit {
                    isFocused = false
                }
                
                ColoredDivider(
                    error != nil
                        ? colors.status.error
                        : isFocused || !text.isEmpty
                            ? colors.brand.primary
                            : colors.border.default,
                    height: isFocused || !text.isEmpty ? Constants.Sizing.dividerFocusedHeight : Constants.Sizing.dividerHeight
                )
            }
            
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(colors.status.error)
            }
        }
        .onChange(of: text) { value in
            error = validator?(value)
        }
        .onChange(of: isFocused) { focused in
            if !focused {
                error = validator?(text)
            }
        }
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: isFocused)
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: error)
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
        !text.isValidEmail ? localization.commonInvalidEmail : nil
    }
}

func compare(_ expected: String, _ localization: ChatLocalization) -> (String) -> String? {
    { text in
        text != expected ? localization.commonFieldsDontMatch : nil
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

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    @Previewable @State var text: String = ""
    
    let localization = ChatLocalization()

    var isRequired: (String) -> String? {
        required(localization)
    }
    var isEmail: (String) -> String? {
        email(localization)
    }
    var isNumeric: (String) -> String? {
        numeric(localization)
    }
    
    ScrollView {
        VStack(spacing: 24) {
            ValidatedTextField("Text", text: $text)
            
            ValidatedTextField("Required Text", text: $text, validator: isRequired)

            ValidatedTextField("Numeric", text: $text, placeholder: "Enter a number", validator: isNumeric)
                .keyboardType(.decimalPad)
            
            ValidatedTextField("Required Numeric", text: $text, validator: allOf(isNumeric, isRequired))
                .keyboardType(.decimalPad)
            
            ValidatedTextField("Email", text: $text, placeholder: "Enter your e-mail", validator: isEmail)
                .keyboardType(.emailAddress)
            
            ValidatedTextField("Required Email", text: $text, validator: allOf(isRequired, isEmail))
                .keyboardType(.emailAddress)
        }
    }
    .padding(.horizontal, 24)
    .environmentObject(localization)
    .environmentObject(ChatStyle())
}
