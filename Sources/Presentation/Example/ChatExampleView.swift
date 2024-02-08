//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

import Combine
import SwiftUI

/// Example of usage of the ``ChatView``
///
/// This view is designed to showcase a chat interface, demonstrating the display of messages, typing indicators, and interactions with rich message elements.
/// It utilizes a view model (`ChatExampleViewModel`) for managing its state and data, making it suitable for creating chat interfaces in SwiftUI applications.
public struct ChatExampleView: View {
    
    // MARK: - Properties
    
    @ObservedObject private var viewModel: ChatExampleViewModel
    
    // MARK: - Init
    
    /// Initialization of the ChatExampleView
    public init() {
        self.viewModel = ChatExampleViewModel()
    }
    
    // MARK: - Builder
    
    /// Content of the view
    public var body: some View {
        ChatView(
            messages: $viewModel.messages,
            isAgentTyping: $viewModel.isAgentTyping,
            isUserTyping: $viewModel.isUserTyping,
            onNewMessage: viewModel.onNewMessage,
            onPullToRefresh: viewModel.onPullToRefresh, 
            onRichMessageElementSelected: viewModel.onRichMessageElementSelected
        )
        .environmentObject(ChatStyle(navigationBarLogo: Asset.exampleNavigationIcon))
        .onAppear(perform: viewModel.onAppear)
        .navigationBarTitle(MockData.agent.userName)
        .navigationBarItems(leading: Button("Reset", action: viewModel.onReset))
        .navigationBarItems(trailing: Button("Add", action: viewModel.onAdd))
    }
}

// MARK: - Preview

struct ChatExampleView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            NavigationView {
                ChatExampleView()
            }
            .navigationViewStyle(.stack)
            .previewDisplayName("Light Mode")
            
            NavigationView {
                ChatExampleView()
            }
            .previewDisplayName("Dark Mode")
            .preferredColorScheme(.dark)
        }
        
    }
}
