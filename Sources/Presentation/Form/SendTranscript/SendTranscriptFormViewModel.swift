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
import SwiftUI

class SendTranscriptFormViewModel: FormViewModel<Bool>, Overlayable {
    
    // MARK: - Properties
    
    @Published var overlay: (() -> AnyView)?
    @Published var emailEntity: TextFieldEntity
    @Published var confirmationEntity: TextFieldEntity
    
    let chatLocalization: ChatLocalization
    let chatThread: ChatThread
    
    // MARK: - Init
    
    init(chatThread: ChatThread, chatLocalization: ChatLocalization, onFinished: @escaping (Bool) -> Void, onCancel: @escaping () -> Void) {
        self.chatThread = chatThread
        self.chatLocalization = chatLocalization
        self.emailEntity = TextFieldEntity(
            label: chatLocalization.sendTranscriptEmailLabel,
            isRequired: true,
            ident: "email",
            isEmail: true
        )
        self.confirmationEntity = TextFieldEntity(
            label: chatLocalization.sendTranscriptConfirmEmailLabel,
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
        
        let isEmailValid = !emailEntity.value.isEmpty && emailEntity.value.isValidEmail
        let isConfirmationEmailValid = !confirmationEntity.value.isEmpty && confirmationEntity.value.isValidEmail
        let isConfirmed = emailEntity.value == confirmationEntity.value
        
        isFormValid = isEmailValid && isConfirmationEmailValid && isConfirmed
    }
}

// MARK: - Internal Methods

extension SendTranscriptFormViewModel {
    
    @MainActor
    func showLoading(message: String, action: (() async -> Void)? = nil, file: StaticString = #file, line: UInt = #line) async {
        LogManager.trace("Showing loading overlay", file: file, line: line)
        
        await showOverlay(file: file, line: line) {
            ChatLoadingOverlay(text: message) {
                Task { @MainActor in
                    await action?()
                }
            }
        }
    }
}

// MARK: - Private methods

private extension SendTranscriptFormViewModel {
    
    @MainActor
    func sendTranscript() async -> Bool {
        await self.showLoading(message: chatLocalization.commonLoading)
        
        var isSuccessful = true
        
        do {
            let provider = try CXoneChat.shared.threads.provider(for: chatThread.id)
            try await provider.sendTranscript(to: emailEntity.value)
            
            LogManager.trace("Chat transcript successfully sent")
        } catch {
            error.logError()
            
            isSuccessful = false
        }
        
        await hideOverlay()
        
        return isSuccessful
    }
}
