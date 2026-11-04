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

import SwiftUI

/// Preview helper that shows a button next to the label describing it.
private struct LabeledButton<Content: View>: View {
    
    let label: String
    let content: () -> Content
    
    init(_ label: String, content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        VStack {
            Text(label)
                 .font(.footnote)
            
            content()
            
            Divider()
        }
    }
}

// MARK: - Preview
// swiftlint:disable hardcoded_strings sf_symbol_key_in_image
#Preview {
    VStack {
        LabeledButton("<Text(LocalizedStringKey)>") {
            Button(LocalizedStringKey("Button"))
        }
        
        LabeledButton("role: .destructive, <Text(LocalizedStringKey)>") {
            Button(LocalizedStringKey("Button"), role: .destructive)
        }
        
        LabeledButton("<Text(String)>") {
            Button("Button")
        }
        
        LabeledButton("role: .destructive, <Text(String)>") {
            Button("Button", role: .destructive)
        }
        
        LabeledButton("role: .destructive, <Text(String), Image>") {
            Button("Button", systemImage: "play")
        }
        
        LabeledButton("role: .destructive, <Text(String), Image>") {
            Button("Button", systemImage: "play", role: .destructive)
        }
        
        LabeledButton("role: .destructive, <Text(LocalizedStringKey), Image>") {
            Button(LocalizedStringKey("Button"), systemImage: "play")
        }
        
        LabeledButton("role: .destructive, <Text(LocalizedStringKey), Image>") {
            Button(LocalizedStringKey("Button"), systemImage: "play", role: .destructive)
        }
        
        LabeledButton("<View>") {
            Button {
                Text("Choose")
                
                Image(systemName: "gear")
                
                Text("Button")
            }
        }
        
        LabeledButton("role: .destructive, <View>") {
            Button(role: .destructive) {
                Text("Choose")
                
                Image(systemName: "gear")
                
                Text("Button")
            }
        }
    }
    .padding(.horizontal, 12)
}
// swiftlint:enable hardcoded_strings sf_symbol_key_in_image
