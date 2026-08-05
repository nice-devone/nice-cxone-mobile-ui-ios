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

import Foundation
import SwiftUI

@MainActor
final class ChatAlertType: Identifiable {
    private typealias A11yAlert = A11y.ChatContainer.Alert

    // MARK: - Properties

    let id = LowercaseUUID()
    let title: String
    let message: Text
    let actions: AnyView

    // MARK: - Init

    init<Content: View>(title: String, message: String, @ViewBuilder actions: () -> Content) {
        self.title = title
        self.message = Text(message)
        self.actions = AnyView(actions())
    }

    // MARK: - Static Methods

    static var genericError: ChatAlertType {
        ChatAlertType(title: L10n.Common.attention, message: L10n.Alert.GenericError.message) {
            Button(L10n.Common.confirm, role: .cancel)
                .accessibilityIdentifier(A11yAlert.GenericError.ButtonCancel.identifier)
                .accessibilityHint(A11yAlert.GenericError.ButtonCancel.hint)
        }
    }

    static func cameraPermissionDenied(action: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(title: L10n.Common.attention, message: L10n.Alert.CameraPermission.message) {
            Button(L10n.Common.cancel, role: .cancel)
                .accessibilityIdentifier(A11yAlert.ButtonCancel.identifier)
                .accessibilityHint(A11yAlert.ButtonCancel.hint)

            Button(L10n.Common.settings, action: action)
                .accessibilityIdentifier(A11yAlert.CameraPermissionDenied.ButtonSettings.identifier)
                .accessibilityHint(A11yAlert.CameraPermissionDenied.ButtonSettings.hint)
        }
    }

    static func microphonePermissionDenied(action: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(title: L10n.Common.attention, message: L10n.Alert.MicrophonePermission.message) {
            Button(L10n.Common.cancel, role: .cancel)
                .accessibilityIdentifier(A11yAlert.ButtonCancel.identifier)
                .accessibilityHint(A11yAlert.ButtonCancel.hint)

            Button(L10n.Common.settings, action: action)
                .accessibilityIdentifier(A11yAlert.MicrophonePermissionDenied.ButtonSettings.identifier)
                .accessibilityHint(A11yAlert.MicrophonePermissionDenied.ButtonSettings.hint)
        }
    }

    static func connectionErrorAlert(action: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(title: L10n.Common.attention, message: L10n.Alert.DisconnectError.message) {
            // `.cancel` role so SwiftUI doesn't auto-add its own Cancel button — this alert has a
            // single action that closes the chat.
            Button(L10n.Common.closeChat, role: .cancel, action: action)
                .accessibilityIdentifier(A11yAlert.ConnectionError.ButtonDisconnect.identifier)
                .accessibilityHint(A11yAlert.ConnectionError.ButtonDisconnect.hint)
        }
    }

    static func featureUnavailableAlert(featureName: String, action: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(
            title: L10n.Common.attention,
            message: L10n.Alert.FeatureUnavailable.message(featureName)
        ) {
            // `.cancel` role so SwiftUI doesn't auto-add its own Cancel button — this alert has a
            // single action that closes the chat.
            Button(L10n.Common.closeChat, role: .cancel, action: action)
                .accessibilityIdentifier(A11yAlert.FeatureUnavailable.ButtonDisconnect.identifier)
                .accessibilityHint(A11yAlert.FeatureUnavailable.ButtonDisconnect.hint)
        }
    }

    static var invalidAttachmentType: ChatAlertType {
        ChatAlertType(title: L10n.Alert.FileValidation.title, message: L10n.Alert.InvalidFileType.message) {
            Button(L10n.Common.cancel, role: .cancel)
                .accessibilityIdentifier(A11yAlert.ButtonCancel.identifier)
                .accessibilityHint(A11yAlert.ButtonCancel.hint)
        }
    }

    static func invalidAttachmentSize(allowedFileSize: Int32) -> ChatAlertType {
        ChatAlertType(
            title: L10n.Alert.FileValidation.title,
            message: L10n.Alert.InvalidFileSize.message(Int(allowedFileSize))
        ) {
            Button(L10n.Common.cancel, role: .cancel)
                .accessibilityIdentifier(A11yAlert.ButtonCancel.identifier)
                .accessibilityHint(A11yAlert.ButtonCancel.hint)
        }
    }

    static func endConversation(primaryAction: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(title: L10n.Common.attention, message: L10n.Alert.EndConversation.message) {
            Button(L10n.Common.cancel, role: .cancel)
                .accessibilityIdentifier(A11yAlert.ButtonCancel.identifier)
                .accessibilityHint(A11yAlert.ButtonCancel.hint)

            Button(L10n.Common.confirm, role: .destructive, action: primaryAction)
                .accessibilityIdentifier(A11yAlert.EndConversation.ButtonConfirm.identifier)
                .accessibilityHint(A11yAlert.EndConversation.ButtonConfirm.hint)
        }
    }

    static func sendTranscript(isSuccess: Bool, action: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(
            title: L10n.Alert.SendTranscript.title,
            message: isSuccess ? L10n.Alert.SendTranscript.success : L10n.Alert.SendTranscript.errorMessage
        ) {
            Button(L10n.Common.cancel, role: .cancel, action: action)
                .accessibilityIdentifier(A11yAlert.ButtonCancel.identifier)
                .accessibilityHint(A11yAlert.ButtonCancel.hint)
        }
    }
}

// MARK: - Equatable

extension ChatAlertType: @preconcurrency Equatable {

    static func == (lhs: ChatAlertType, rhs: ChatAlertType) -> Bool {
        lhs.id == rhs.id
    }
}
