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

struct ListFieldView: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Padding {
            static let chevronHorizontal: CGFloat = 4
            static let textFieldVertical: CGFloat = 4
        }
        
        enum Sizing {
            static let dividerHeight: CGFloat = 1
            static let dividerFocusedHeight: CGFloat = 2
        }
        
        enum Spacing {
            static let bodyVertical: CGFloat = 6
            static let textFieldDividerSpacing: CGFloat = 8
            static let valueDisclosureHorizontal: CGFloat = 16
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var entity: ListFieldEntity

    @State private var isActionSheetVisible = false
    @State private var error: String?
    
    /// Whether the picker is open or the field already has a value — drives the divider's colour and thickness.
    private var isActive: Bool {
        isActionSheetVisible || !entity.value.isEmpty
    }
    
    let onChange: () -> Void
    
    // MARK: - Init
    
    init(entity: ListFieldEntity, onChange: @escaping () -> Void) {
        self.entity = entity
        self.onChange = onChange
    }
    
    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.bodyVertical) {
            Text(entity.isRequired ? L10n.Form.requiredLabel(entity.label) : entity.label)
                .font(.callout)
                .bold()
                .foregroundStyle(error != nil ? colors.status.error : colors.content.primary)
                .accessibilityHidden(true)

            VStack(spacing: Constants.Spacing.textFieldDividerSpacing) {
                buttonOptionSelector

                ColoredDivider(
                    error != nil
                        ? colors.status.error
                        : isActive
                            ? colors.brand.primary
                            : colors.border.default,
                    height: isActive
                        ? Constants.Sizing.dividerFocusedHeight
                        : Constants.Sizing.dividerHeight
                )
                .accessibilityHidden(true)
            }

            if let error {
                Text(L10n.Form.fieldError(entity.label, error))
                    .font(.caption)
                    .foregroundStyle(colors.status.error)
                    .accessibilityHidden(true) // The information that the field is mandatory is part of the button.
            }
        }
        .onChange(of: entity.value) { _ in
            error = entity.isMissingRequiredValue ? L10n.Common.required : nil
        }
        .onChange(of: isActionSheetVisible) { isVisible in
            if !isVisible {
                error = entity.isMissingRequiredValue ? L10n.Common.required : nil
            }
        }
        .onChange(of: error) { newError in
            if let newError {
                A11y.announce(L10n.Form.fieldError(entity.label, newError))
            }
        }
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: isActionSheetVisible)
    }
}

// MARK: - Internal Methods

extension ListFieldView {

    /// What VoiceOver should announce for the field's current value: the selected option (or "no
    /// selection"), whether the picker is expanded, and — persistently, not just via the one-time
    /// `A11y.announce` — whether the field is currently invalid. Pure and independent of SwiftUI
    /// state so it's directly unit-testable without rendering the view.
    ///
    /// Before this existed, "Required" on the label was the only thing that changed between a
    /// fresh required field and an invalid one, and unconditionally announcing "Required" (to fix
    /// that state not appearing on first render) made the two indistinguishable. This value is what
    /// actually carries the invalid signal now, so a VoiceOver user who returns to an invalid field
    /// later — after missing the one-time announcement — can still tell.
    static func accessibilityValueText(selectedOption: String, isExpanded: Bool, isInvalid: Bool) -> String {
        let stateText = isExpanded
            ? A11y.Form.ListFieldView.Content.Value.expanded(selectedOption)
            : A11y.Form.ListFieldView.Content.Value.collapsed(selectedOption)

        return isInvalid ? A11y.Form.ListFieldView.Content.Value.invalid(stateText) : stateText
    }
}

// MARK: - Subviews

private extension ListFieldView {

    var buttonOptionSelector: some View {
        Button {
            isActionSheetVisible.toggle()
        } label: {
            HStack(spacing: Constants.Spacing.valueDisclosureHorizontal) {
                Text(entity.value.isEmpty ? L10n.Common.noSelection : entity.selectedOption)
                    .foregroundStyle(error != nil ? colors.status.error : colors.content.primary)

                Spacer()

                Asset.down
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(error != nil && entity.value.isEmpty ? colors.status.error : colors.content.tertiary)
                    .padding(.horizontal, Constants.Padding.chevronHorizontal)
            }
            .accessibilityHidden(true) // Let the VoiceOver read only the parent label (the button itself)
        }
        .foregroundStyle(colors.content.primary)
        .padding(.vertical, Constants.Padding.textFieldVertical)
        .confirmationDialog(entity.label, isPresented: $isActionSheetVisible) {
            optionsSheet
        }
        .accessibilityIdentifier(A11y.Form.ListFieldView.Content.identifier(entity.ident))
        .accessibilityLabel(entity.isRequired ? A11y.Form.ListFieldView.Content.label(entity.label, L10n.Common.required) : entity.label)
        .accessibilityValue(
            Self.accessibilityValueText(
                selectedOption: entity.value.isEmpty ? L10n.Common.noSelection : entity.selectedOption,
                isExpanded: isActionSheetVisible,
                isInvalid: error != nil
            )
        )
        .accessibilityHint(A11y.Form.ListFieldView.Content.hint)
    }

    @ViewBuilder
    var optionsSheet: some View {
        ForEach(Array(entity.options.keys), id: \.self) { key in
            if let value = entity.options[key] {
                Button(value) {
                    // Do not use actual value, it's necessary to use key which is unique identifier for the value
                    entity.value = key

                    onChange()
                }
            } else {
                EmptyView()
                    .onAppear {
                        LogManager.error("Unable to get value for option \(key)")
                    }
            }
        }

        Button(L10n.Common.cancel, role: .cancel) {
            entity.value = ""
        }
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 24) {
        ListFieldView(
            entity: ListFieldEntity(
                label: "Color",
                isRequired: false,
                ident: "color",
                options: ["blue": "Blue", "yellow": "Yellow", "experimental_green": "Experimental Green"],
                value: "yellow"
            )
        ) { }
        
        ListFieldView(
            entity: ListFieldEntity(
                label: "Color",
                isRequired: true,
                ident: "color",
                options: ["blue": "Blue", "yellow": "Yellow", "experimental_green": "Experimental Green"]
            )
        ) { }
    }
    .padding(.horizontal, 16)
    .environmentObject(ChatStyle())
}
