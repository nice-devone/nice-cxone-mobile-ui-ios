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

// MARK: - Sheets

extension ChatContainerViewModel {

    /// Presents the pre-chat survey form as a sheet and suspends until the customer submits or cancels.
    @MainActor
    func showPrechatSurveyForm(title: String, fields: [FormCustomFieldType]) async -> [String: String]? {
        await withCheckedContinuation { continuation in
            let formViewModel = PrechatSurveyFormViewModel(customFields: fields) { [weak self] fields in
                Task { @MainActor in
                    await self?.hideSheet()
                }

                continuation.resume(returning: fields)
            } onCancel: { [weak self] in
                Task { @MainActor in
                    await self?.hideSheet()
                }

                continuation.resume(returning: nil)
            }

            Task { @MainActor [weak self] in
                await self?.showSheet {
                    PrechatSurveyFormView(viewModel: formViewModel, title: title)
                }
            }
        }
    }

    @MainActor
    func showSendTranscriptForm(for thread: ChatThread) async -> Bool? {
        await withCheckedContinuation { continuation in
            let binding = Binding<(() -> AnyView)?> { [weak self] in
                self?.overlay ?? nil
            } set: { [weak self] newValue in
                self?.overlay = newValue
            }

            let sendTranscriptViewModel = SendTranscriptFormViewModel(
                chatThread: thread,
                chatProvider: chatProvider,
                overlay: binding
            ) { [weak self] result in
                Task { @MainActor in
                    await self?.hideSheet()

                    // Return Bool to indicate the form has been sent (either successfully or with a failure result)
                    continuation.resume(returning: result)
                }
            } onCancel: { [weak self] in
                Task { @MainActor in
                    await self?.hideSheet()

                    // Return nil if user cancelled.
                    continuation.resume(returning: nil)
                }
            }

            Task { @MainActor [weak self] in
                await self?.showSheet {
                    SendTranscriptFormView(viewModel: sendTranscriptViewModel)
                }
            }
        }
    }
}
