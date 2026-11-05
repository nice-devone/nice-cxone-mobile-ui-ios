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

class SendTranscriptFormViewModel: FormViewModel<Bool>, Overlayable {
    
    // MARK: - Properties
    
    @Published var emailEntity: TextFieldEntity
    @Published var confirmationEntity: TextFieldEntity
    
    @Binding var overlay: (() -> AnyView)?

    let chatProvider: ChatProvider
    let chatThread: ChatThread

    // MARK: - Init

    init(
        chatThread: ChatThread,
        chatProvider: ChatProvider,
        overlay: Binding<(() -> AnyView)?>,
        onFinished: @escaping (Bool) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.chatThread = chatThread
        self.chatProvider = chatProvider
        self._overlay = overlay
        self.emailEntity = TextFieldEntity(
            label: L10n.SendTranscript.Email.label,
            isRequired: true,
            ident: "email",
            isEmail: true
        )
        self.confirmationEntity = TextFieldEntity(
            label: L10n.SendTranscript.ConfirmEmail.label,
            isRequired: true,
            ident: "confirm_email",
            isEmail: true
        )
        super.init(onFinished: onFinished, onCancel: onCancel)
    }
    
    // MARK: - Methods
    
    override func onSubmit() {
        LogManager.trace("Confirming form")
        
        // Retrigger the validation (just in case)
        validateForm()
        
        if isFormValid {
            LogManager.trace("The form is valid, initializing the send transcript flow")
            
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }
                
                onFinished(await self.sendTranscript())
            }
        } else {
            LogManager.error("The form is not valid")
        }
    }
    
    override func validateForm() {
        LogManager.trace("Validating form")
        
        let isEmailValid = emailEntity.hasValidEmail
        let isConfirmationEmailValid = confirmationEntity.hasValidEmail
        let isConfirmed = emailEntity.submissionValue == confirmationEntity.submissionValue

        isFormValid = isEmailValid && isConfirmationEmailValid && isConfirmed

        if isFormValid == false {
            switch false {
            case isEmailValid:
                // E-mail field value is not valid
                firstInvalidFieldID = emailEntity.id
            case isConfirmationEmailValid:
                // E-mail confirmation field value is not valid
                firstInvalidFieldID = confirmationEntity.id
            default:
                // Confirmation field does not match e-mail field
                firstInvalidFieldID = confirmationEntity.id
            }
        }
    }
}

// MARK: - Private methods

private extension SendTranscriptFormViewModel {
    
    @MainActor
    func sendTranscript() async -> Bool {
        await self.showLoading()
        
        var isSuccessful = true
        
        do {
            let provider = try chatProvider.threads.provider(for: chatThread.id)
            try await provider.sendTranscript(to: emailEntity.submissionValue)
            
            LogManager.trace("Chat transcript successfully sent")
        } catch {
            error.logError()
            
            isSuccessful = false
        }
        
        await hideOverlay()
        
        return isSuccessful
    }
    
    @MainActor
    func showLoading(file: StaticString = #file, line: UInt = #line) async {
        LogManager.trace("Showing loading overlay", file: file, line: line)
        
        await showOverlay({
            ChatLoadingOverlay(text: L10n.Common.loading) {
                // Nothing do to here
            }
        }, file: file, line: line)
    }
}
