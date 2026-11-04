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

import CXoneChatSDK
import SwiftUI

// MARK: - Constants

private enum Constants {
    
    enum Spacing {
        static let bodyVertical: CGFloat = 0
        static let contentVertical: CGFloat = 16
        static let controlButtonsVertical: CGFloat = 12
    }
    
    enum Padding {
        static let controlButtonsBottom: CGFloat = 26
        /// Horizontal inset for the scrollable content: edge-to-edge in landscape, where the extra
        /// width is worth more than the margin; inset in portrait.
        ///
        /// Takes the orientation as a parameter rather than reading it: a `static` can only reach
        /// orientation through a global, which SwiftUI cannot invalidate on. The caller reads it from
        /// ``LayoutAware`` — that read is the dependency — and the value itself stays here.
        static func contentHorizontal(isLandscape: Bool) -> CGFloat {
            isLandscape ? 0 : 16
        }
        // Fixed margin for the Cancel/Submit row in every orientation, so the buttons
        // never sit flush against the screen edge / bezel even when the scrollable
        // content goes edge-to-edge (0) in landscape.
        static let controlButtonsHorizontal: CGFloat = 16
    }
}

// MARK: - FormView

struct FormView<Content: View, FormType: Any>: View, Themed, LayoutAware {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme

    @SwiftUI.Environment(\.chatLayout) var chatLayout
    
    @ObservedObject var viewModel: FormViewModel<FormType>
    
    let title: String
    let subtitle: String
    /// Overrides the subtitle's accessibility label with different text than what's shown.
    ///
    /// `nil` (the default) reads the visible `subtitle` text as-is. Pass an override when the
    /// visible text contains something VoiceOver shouldn't read literally — e.g. a "*" character,
    /// which its default punctuation verbosity won't speak, producing a nonsensical announcement.
    var subtitleAccessibilityLabel: String?
    let content: (ScrollViewProxy) -> Content

    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.bodyVertical) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: true) {
                    VStack(alignment: .leading, spacing: Constants.Spacing.contentVertical) {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(colors.content.secondary)
                            .padding(.horizontal, Constants.Padding.contentHorizontal(isLandscape: isLandscape))
                            .accessibilityLabel(subtitleAccessibilityLabel ?? subtitle)
                            .accessibilityIdentifier(A11y.Form.Header.subtitleIdentifier)
                            .accessibilityAddTraits(.isStaticText)

                        content(proxy)
                            .padding(.horizontal, Constants.Padding.contentHorizontal(isLandscape: isLandscape))
                    }
                }
            }

            controlButtons
        }
        .interactiveDismissDisabled()
        // Not `dismissKeyboardOnTap()`: the form is full of text fields, and a simultaneous tap would
        // resign the field the user just tapped into.
        .dismissKeyboardOnUnhandledTap()
        .background(colors.background.default)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(colors.content.primary)
                    .accessibilityIdentifier(A11y.Form.Header.titleIdentifier)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var controlButtons: some View {
        VStack(spacing: Constants.Spacing.controlButtonsVertical) {
            ColoredDivider(colors.border.default)
                .ignoresSafeArea(.all)
                .accessibilityHidden(true)

            HStack {
                Button(L10n.Common.cancel, action: viewModel.onCancel)
                    .accessibilityIdentifier(A11y.Form.ButtonCancel.identifier)
                    .accessibilityHint(A11y.Form.ButtonCancel.hint)

                Spacer()

                Button(L10n.Common.submit, action: viewModel.onSubmit)
                    .disabled(!viewModel.isFormValid)
                    .accessibilityIdentifier(A11y.Form.ButtonConfirm.identifier)
                    .accessibilityHint(
                        viewModel.isFormValid
                            ? A11y.Form.ButtonConfirm.Valid.hint
                            : A11y.Form.ButtonConfirm.Invalid.hint
                    )
            }
            .font(.body.weight(.medium))
            .tint(colors.brand.primary)
            .padding(.horizontal, Constants.Padding.controlButtonsHorizontal)
            .padding(.bottom, Constants.Padding.controlButtonsBottom)
        }
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: viewModel.isFormValid)
    }
}

// MARK: - Preview

#Preview {
    let viewModel: FormViewModel<[String: String]> = FormViewModel { customFields in
        print("Submit \(customFields)")
    } onCancel: {
        print("Cancelled")
    }

    Color.clear
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                FormView<VStack, [String: String]>(viewModel: viewModel, title: "Title", subtitle: "Subtitle") { _ in
                    VStack(spacing: 0) {
                        TextFieldView(entity: MockData.textFieldEntity(), placeholder: "Enter your First Name") { }

                        ListFieldView(entity: MockData.listFieldEntity(isRequired: true)) { }
                        
                        TreeFieldView(entity: MockData.treeFieldEntity()) { }
                    }
                }
            }
        }
        .environmentObject(ChatStyle())
}
