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

import CXoneChatSDK
import Foundation
import SwiftUI

final class ChatAlertType: Identifiable {
    
    // MARK: - Properties
    
    let title: String
    let message: String
    let primary: Alert.Button
    let secondary: Alert.Button?
    
    // MARK: - Init
    
    init(title: String, message: String, primary: Alert.Button, secondary: Alert.Button? = nil) {
        self.title = title
        self.message = message
        self.primary = primary
        self.secondary = secondary
    }
    
    // MARK: - Static Methods
    
    static func genericError(localization: ChatLocalization, primaryAction: Alert.Button? = nil) -> ChatAlertType {
        if let primaryAction {
            return ChatAlertType(
                title: localization.commonAttention,
                message: localization.alertGenericErrorMessage,
                primary: primaryAction,
                secondary: .cancel()
            )
        } else {
            return ChatAlertType(
                title: localization.commonAttention,
                message: localization.alertGenericErrorMessage,
                primary: .cancel(Text(localization.commonConfirm))
            )
        }
    }
    
    static func cameraPermissionDenied(localization: ChatLocalization, action: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(
            title: localization.commonAttention,
            message: localization.alertCameraPermissionMessage,
            primary: .default(Text(localization.commonSettings), action: action),
            secondary: .cancel()
        )
    }
    
    static func microphonePermissionDenied(localization: ChatLocalization, action: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(
            title: localization.commonAttention,
            message: localization.alertMicrophonePermissionMessage,
            primary: .default(Text(localization.commonSettings), action: action),
            secondary: .cancel()
        )
    }
    
    static func connectionErrorAlert(localization: ChatLocalization, action: @escaping () -> Void) -> ChatAlertType {
        ChatAlertType(
            title: localization.commonAttention,
            message: localization.alertDisconnectErrorMessage,
            primary: .destructive(Text(localization.alertDisconnectConfirm), action: action)
        )
    }
    
    static func invalidAttachmentType(localization: ChatLocalization) -> ChatAlertType {
        ChatAlertType(
            title: localization.alertFileValidationTitle,
            message: localization.alertInvalidFileTypeMessage,
            primary: .cancel()
        )
    }
    
    static func invalidAttachmentSize(localization: ChatLocalization) -> ChatAlertType {
        ChatAlertType(
            title: localization.alertFileValidationTitle,
            message: String(
                format: localization.alertInvalidFileSizeMessage,
                CXoneChat.shared.connection.channelConfiguration.fileRestrictions.allowedFileSize
            ),
            primary: .cancel()
        )
    }
    
    static func endConversation(
        localization: ChatLocalization,
        primaryAction: @escaping () -> Void
    ) -> ChatAlertType {
        ChatAlertType(
            title: localization.commonAttention,
            message: localization.alertEndConversationMessage,
            primary: .destructive(Text(localization.commonConfirm), action: primaryAction),
            secondary: .cancel()
        )
    }
}
