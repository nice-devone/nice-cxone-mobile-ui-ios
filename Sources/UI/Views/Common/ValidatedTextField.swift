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
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @FocusState private var isFocused: Bool
    
    @Binding var text: String

    @State private var error: String?

    let title: String
    let isRequired: Bool
    let placeholder: String?
    let validator: ((String) -> String?)?
    /// Overrides the accessibility identifier applied to the inner `TextField`.
    ///
    /// When `nil`, falls back to `A11y.ValidatedTextField.identifier(title)`. Callers that embed
    /// `ValidatedTextField` in a larger field (e.g. `TextFieldView`) pass their own identifier so that
    /// it resolves to the editable `TextField` element rather than a wrapping container.
    let accessibilityIdentifier: String?

    /// The visible title, with the "*" suffix appended when required.
    ///
    /// Kept separate from the accessibility label: the same string can't serve both, since
    /// VoiceOver's default punctuation verbosity doesn't speak a bare "*" — a required field would
    /// silently lose its required state for VoiceOver users if this were also the accessibility
    /// label. `accessibilityLabelText` conveys the same fact explicitly instead.
    private var displayTitle: String {
        isRequired ? L10n.Form.requiredLabel(title) : title
    }

    /// Whether the field is focused or already has content — drives the divider's colour and thickness.
    private var isActive: Bool {
        isFocused || !text.isEmpty
    }

    private var accessibilityLabelText: String {
        isRequired ? A11y.ValidatedTextField.requiredLabel(title, L10n.Common.required) : title
    }

    // MARK: - Init

    init(
        _ title: String,
        isRequired: Bool = false,
        text: Binding<String>,
        placeholder: String? = nil,
        validator: ((String) -> String?)? = nil,
        accessibilityIdentifier: String? = nil
    ) {
        self.title = title
        self.isRequired = isRequired
        self._text = text
        self.placeholder = placeholder
        self.validator = validator
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    // MARK: - Builder

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.bodyVertical) {
            Text(displayTitle)
                .font(.callout)
                .bold()
                .foregroundStyle(error == nil ? colors.content.primary : colors.status.error)
                .accessibilityHidden(true)

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
                .accessibilityIdentifier(accessibilityIdentifier ?? A11y.ValidatedTextField.identifier(title.lowercased()))
                .accessibilityLabel(accessibilityLabelText)
                .accessibilityHint(A11y.ValidatedTextField.hint(title))
                .accessibilityValue(
                    text.isEmpty
                        ? error == nil ? A11y.ValidatedTextField.Validation.Valid.Empty.value : A11y.ValidatedTextField.Validation.Invalid.Empty.value
                        : error == nil ? A11y.ValidatedTextField.Validation.Valid.value(text) : A11y.ValidatedTextField.Validation.Invalid.value(text)
                )

                ColoredDivider(
                    error != nil
                        ? colors.status.error
                        : isActive
                            ? colors.brand.primary
                            : colors.border.default,
                    height: isActive ? Constants.Sizing.dividerFocusedHeight : Constants.Sizing.dividerHeight
                )
                .accessibilityHidden(true)
            }

            if let error {
                Text(L10n.Form.fieldError(title, error))
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

                if let error {
                    // Announce only when focus is lost
                    A11y.announce(L10n.Form.fieldError(title, error))
                }
            }
        }
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: isFocused)
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: error)
    }
}

// MARK: - Validators

@MainActor
var required: (String) -> String? {
    { text in
        text.trimmed.isEmpty ? L10n.Common.required : nil
    }
}

@MainActor
var numeric: (String) -> String? {
    { text in
        let value = text.trimmed
        
        return value.isEmpty || Double(value) != nil ? nil : L10n.Common.invalidNumber
    }
}

@MainActor
var email: (String) -> String? {
    { text in
        let value = text.trimmed
        
        return value.isEmpty || value.isValidEmail ? nil : L10n.Common.invalidEmail
    }
}

@MainActor
func compare(_ expected: String) -> (String) -> String? {
    { text in
        text.trimmed != expected.trimmed ? L10n.Common.fieldsDontMatch : nil
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

    ScrollView {
        VStack(spacing: 24) {
            ValidatedTextField("Text", text: $text)

            ValidatedTextField("Required Text", text: $text, validator: required)

            ValidatedTextField("Numeric", text: $text, placeholder: "Enter a number", validator: numeric)
                .keyboardType(.decimalPad)

            ValidatedTextField("Required Numeric", text: $text, validator: allOf(numeric, required))
                .keyboardType(.decimalPad)

            ValidatedTextField("Email", text: $text, placeholder: "Enter your e-mail", validator: email)
                .keyboardType(.emailAddress)

            ValidatedTextField("Required Email", text: $text, validator: allOf(required, email))
                .keyboardType(.emailAddress)
        }
    }
    .padding(.horizontal, 24)
    .environmentObject(ChatStyle())
}
