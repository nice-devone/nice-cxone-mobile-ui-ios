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

struct SendTranscriptFormView: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let contentVertical: CGFloat = 24
            static let contentMinGap: CGFloat = 20
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme

    @ObservedObject var viewModel: SendTranscriptFormViewModel
    
    // MARK: - Init

    init(viewModel: SendTranscriptFormViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Content

    var body: some View {
        FormView(viewModel: viewModel, title: L10n.SendTranscript.title, subtitle: L10n.SendTranscript.subtitle) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Constants.Spacing.contentVertical) {
                    TextFieldView(
                        entity: viewModel.emailEntity,
                        placeholder: L10n.SendTranscript.Email.placeholder,
                        onChange: viewModel.validateForm
                    )
                    
                    TextFieldView(
                        entity: viewModel.confirmationEntity,
                        placeholder: L10n.SendTranscript.ConfirmEmail.placeholder,
                        compareWith: $viewModel.emailEntity.value,
                        onChange: viewModel.validateForm
                    )
                    
                    Spacer(minLength: Constants.Spacing.contentMinGap)
                }
            }
        }
        .fullScreenCover(isPresented: viewModel.isOverlayDisplayed) {
            viewModel.overlay?()
                .presentationWithBackgroundColor(.clear)
        }
        .onChange(of: viewModel.firstInvalidFieldID) { target in
            guard target != nil else {
                return
            }

            A11y.announce(A11y.Announcement.Form.Validation.Invalid.argument)
        }
    }
}

// MARK: - Preview

#Preview {
    let viewModel = SendTranscriptFormViewModel(
        chatThread: ChatThread(
            id: LowercaseUUID().uuidString,
            name: nil,
            messages: [],
            assignedAgent: nil,
            lastAssignedAgent: nil,
            ownerAssignee: nil,
            scrollToken: "",
            state: .ready,
            positionInQueue: nil
        ),
        chatProvider: MockChatProvider(),
        overlay: .constant(nil),
        onFinished: { email in
            print("E-mail: \(email)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
    
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SendTranscriptFormView(viewModel: viewModel)
        }
        .environmentObject(ChatStyle())
}
