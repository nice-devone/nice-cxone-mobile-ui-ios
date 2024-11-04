//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

class StatusMessageViewModel<Label: View>: ChatContainerViewModel.ChildViewModel {
    
    // MARK: - Properties
    
    let busy: Bool

    // MARK: - Init
    
    init(
        containerViewModel: ChatContainerViewModel,
        title: String? = nil,
        busy: Bool,
        label: @escaping () -> Label?,
        onBack: (() -> Void)? = nil
    ) {
        self.busy = busy

        super.init(
            left: containerViewModel.back(title: containerViewModel.chatLocalization.commonCancel, action: onBack),
            title: title.map(Text.init)
        )

        self.content = {
            AnyView(
                VStack {
                    Spacer()
                    
                    if busy {
                        ProgressView()
                            .padding()
                    }
                    
                    label()
                    
                    Spacer()
                }
            )
        }
    }

    convenience init(
        containerViewModel: ChatContainerViewModel,
        title: String? = nil,
        message: String,
        busy: Bool = true,
        onBack: (() -> Void)? = nil
    ) where Label == Text {
        self.init(
            containerViewModel: containerViewModel,
            title: title,
            busy: busy,
            label: { Text(message) },
            onBack: onBack
        )
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    StatusMessageViewModel(
        containerViewModel: ChatContainerViewModel(
            chatProvider: CXoneChat.shared,
            chatLocalization: ChatLocalization()
        ) {},
        busy: true
    ) { Text("Loading") }
        .content()
}

#Preview("Dark Mode") {
    StatusMessageViewModel(
        containerViewModel: ChatContainerViewModel(
            chatProvider: CXoneChat.shared,
            chatLocalization: ChatLocalization()
        ) {},
        busy: true
    ) { Text("Loading") }
        .content()
        .preferredColorScheme(.dark)
}
