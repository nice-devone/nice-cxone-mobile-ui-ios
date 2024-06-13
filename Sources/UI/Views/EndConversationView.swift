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

import SwiftUI

struct EndConversationView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var localization: ChatLocalization
    @EnvironmentObject private var style: ChatStyle
    
    let agentAvatarUrl: URL?
    let agentName: String?
    let onStartNewTapped: () -> Void
    let onBackToConversationTapped: () -> Void
    let onCloseChatTapped: () -> Void
    
    private var agentNameInitials: String {
        guard let agentName else {
            return "??"
        }
        
        let formatter = PersonNameComponentsFormatter()
        
        return formatter.personNameComponents(from: agentName).map { components in
            formatter.style = .abbreviated
            
            return formatter.string(from: components)
        } ?? "??"
    }
    
    // MARK: - Builder
    
    var body: some View {
        ZStack {
            Color(.darkGray)
                .opacity(0.5)
            
            VStack(spacing: 0) {
                if let agentName {
                    MessageAvatarView(avatarUrl: agentAvatarUrl, initials: agentNameInitials)
                        .frame(width: 80, height: 80, alignment: .center)
                        .shadow(radius: 4, x: 2, y: 2)
                        .padding(.bottom, 12)
                    
                    Text(localization.liveChatEndConversationAssignedAgent)
                        .foregroundColor(style.formTextColor)
                    
                    Text(agentName)
                        .font(.title)
                        .bold()
                        .foregroundColor(style.formTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 24)
                }
                
                VStack {
                    Button(action: onStartNewTapped) {
                        HStack {
                            Asset.LiveChat.newChat
                            
                            Text(localization.liveChatEndConversationNew)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(chatStyle: style))
                    
                    Button(action: onBackToConversationTapped) {
                        HStack {
                            Asset.back
                            
                            Text(localization.liveChatEndConversationBack)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(chatStyle: style))
                    
                    Button(action: onCloseChatTapped) {
                        HStack {
                            Asset.disconnect
                            
                            Text(localization.liveChatEndConversationClose)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(chatStyle: style))
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(style.backgroundColor)
            )
            .compositingGroup()
            .shadow(radius: 4, x: 2, y: 2)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Previews

struct EndConversationView_Previews: PreviewProvider {

    // MARK: - Properties

    static var previews: some View {
        Group {
            ChatExampleView(withHistory: true)
                .overlay(getEndConversationView(agentAvatarUrl: MockData.agent.avatarURL, agentName: MockData.agent.userName), alignment: .center)
                .environmentObject(ChatStyle(formTextColor: Color(.darkText)))
                .previewDisplayName("Agent with image - Light Mode")
            
            ChatExampleView(withHistory: true)
                .overlay(getEndConversationView(agentAvatarUrl: MockData.agent.avatarURL, agentName: MockData.agent.userName), alignment: .center)
                .environmentObject(ChatStyle(formTextColor: Color(.lightText)))
                .preferredColorScheme(.dark)
                .previewDisplayName("Agent with image - Dark Mode")
            
            ChatExampleView(withHistory: true)
                .overlay(getEndConversationView(agentName: MockData.agent.userName), alignment: .center)
                .environmentObject(ChatStyle(formTextColor: Color(.darkText)))
                .previewDisplayName("Agent without image - Light Mode")
            
            ChatExampleView(withHistory: true)
                .overlay(getEndConversationView(agentName: MockData.agent.userName), alignment: .center)
                .environmentObject(ChatStyle(formTextColor: Color(.lightText)))
                .preferredColorScheme(.dark)
                .previewDisplayName("Agent without image - Dark Mode")
            
            ChatExampleView(withHistory: true)
                .overlay(getEndConversationView(), alignment: .center)
                .environmentObject(ChatStyle(formTextColor: Color(.darkText)))
                .previewDisplayName("Agent without name - Light Mode")
            
            ChatExampleView(withHistory: true)
                .overlay(getEndConversationView(), alignment: .center)
                .environmentObject(ChatStyle(formTextColor: Color(.lightText)))
                .preferredColorScheme(.dark)
                .previewDisplayName("Agent without name - Dark Mode")
        }
        .ignoresSafeArea()
        .environmentObject(ChatLocalization())
    }
    
    static func getEndConversationView(
        agentAvatarUrl: URL? = nil,
        agentName: String? = nil,
        onStartNewTapped: @escaping () -> Void = { },
        onBackToConversationTapped: @escaping () -> Void = { },
        onCloseChatTapped: @escaping () -> Void = { }
    ) -> some View {
        EndConversationView(
            agentAvatarUrl: agentAvatarUrl,
            agentName: agentName,
            onStartNewTapped: onStartNewTapped,
            onBackToConversationTapped: onBackToConversationTapped,
            onCloseChatTapped: onCloseChatTapped
        )
    }
}
