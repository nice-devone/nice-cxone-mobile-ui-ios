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

struct SatisfactionSurveyOverlayView<SurveyContent: View>: View, Themed, LayoutAware {

    // MARK: - Constants

    private enum Constants {

        enum Sizing {
            static var navigationBarHeight: CGFloat { 44 }
            static var headerDividerHeight: CGFloat { 0.5 }
            /// Total height of the control bar, including its top border.
            static var controlBarHeight: CGFloat { 52 }
            static var controlBarBorderHeight: CGFloat { 1 }
        }

        enum Padding {
            static var headerHorizontal: CGFloat { 64 }
            static var controlBarHorizontal: CGFloat { 12 }
            static var controlBarHorizontalLandscape: CGFloat { 64 }
            static var controlBarTop: CGFloat { 11 }
        }
    }

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    @SwiftUI.Environment(\.colorScheme) var scheme
    @SwiftUI.Environment(\.chatLayout) var chatLayout

    @State private var didFailToLoad: Bool

    let prompt: String
    let onClose: () -> Void
    let onFailure: (Error) -> Void

    private let surveyContent: (@escaping (Error) -> Void) -> SurveyContent

    // MARK: - Init

    init(
        survey: SatisfactionSurvey,
        initiallyFailedToLoad: Bool = false,
        onClose: @escaping () -> Void,
        onFailure: @escaping (Error) -> Void,
        @ViewBuilder surveyContent: @escaping (@escaping (Error) -> Void) -> SurveyContent
    ) {
        self.init(
            prompt: survey.prompt,
            initiallyFailedToLoad: initiallyFailedToLoad,
            onClose: onClose,
            onFailure: onFailure,
            surveyContent: surveyContent
        )
    }

    init(
        prompt: String,
        initiallyFailedToLoad: Bool = false,
        onClose: @escaping () -> Void,
        onFailure: @escaping (Error) -> Void,
        @ViewBuilder surveyContent: @escaping (@escaping (Error) -> Void) -> SurveyContent
    ) {
        self.prompt = prompt
        self._didFailToLoad = State(initialValue: initiallyFailedToLoad)
        self.onClose = onClose
        self.onFailure = onFailure
        self.surveyContent = surveyContent
    }

    // MARK: - Builder

    var body: some View {
        VStack(spacing: .zero) {
            header
                .padding(.horizontal, Constants.Padding.headerHorizontal)
                .frame(minHeight: Constants.Sizing.navigationBarHeight)

            ColoredDivider(colors.border.default, height: Constants.Sizing.headerDividerHeight)
                .ignoresSafeArea(.all)
                .accessibilityHidden(true)

            surveyBody
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            ColoredDivider(colors.border.default, height: Constants.Sizing.controlBarBorderHeight)
                .ignoresSafeArea(.all)
                .accessibilityHidden(true)

            cancelButton
                .padding(.horizontal, controlBarHorizontalPadding)
                .padding(.top, Constants.Padding.controlBarTop)
                .padding(.bottom, Constants.Padding.controlBarTop)
                .frame(
                    minHeight: Constants.Sizing.controlBarHeight - Constants.Sizing.controlBarBorderHeight,
                    alignment: .top
                )
                // Figma measures the bar's side padding from the screen edge, without a safe area
                .ignoresSafeArea(.container, edges: .horizontal)
        }
        .background(colors.background.default)
        .accessibilityAddTraits(.isModal)
    }
}

// MARK: - Subviews

private extension SatisfactionSurveyOverlayView {

    var controlBarHorizontalPadding: CGFloat {
        isLandscape ? Constants.Padding.controlBarHorizontalLandscape : Constants.Padding.controlBarHorizontal
    }

    var header: some View {
        Text(prompt)
            .font(.headline)
            .foregroundStyle(colors.content.primary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityIdentifier(A11y.SatisfactionSurvey.Header.identifier)
            .accessibilityAddTraits(.isHeader)
    }

    var cancelButton: some View {
        Button(L10n.Common.cancel, action: onClose)
            .font(.body.weight(.medium))
            .tint(colors.brand.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier(A11y.SatisfactionSurvey.ButtonClose.identifier)
            .accessibilityLabel(A11y.SatisfactionSurvey.ButtonClose.label)
            .accessibilityHint(A11y.SatisfactionSurvey.ButtonClose.hint)
    }

    @ViewBuilder
    var surveyBody: some View {
        if didFailToLoad {
            Text(L10n.Alert.GenericError.message)
                .font(.body)
                .foregroundStyle(colors.content.primary)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(colors.background.default)
        } else {
            surveyContent { error in
                didFailToLoad = true
                onFailure(error)
            }
            .background(colors.background.default)
        }
    }
}

// MARK: - Preview

#Preview {
    SatisfactionSurveyOverlayView(
        prompt: "How was your experience?",
        onClose: {},
        onFailure: { error in
            error.logError()
        },
        surveyContent: { _ in
            Color.clear
        }
    )
    .environmentObject(ChatStyle())
}
