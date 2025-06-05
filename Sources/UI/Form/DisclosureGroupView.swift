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

import SwiftUI

struct DisclosureGroupView<Label, Content>: View, Themed where Label: View, Content: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @State private var isExpanded: Bool
    
    var content: () -> Content
    var label: () -> Label
    
    // MARK: - Init
    
    init(isExpanded: Bool, content: @escaping () -> Content, label: @escaping () -> Label) {
        self.isExpanded = isExpanded
        self.content = content
        self.label = label
    }
    
    // MARK: - Builder
    
    var body: some View {
        if #available(iOS 16, *) {
            DisclosureGroup(isExpanded: $isExpanded, content: content, label: label)
                .foregroundStyle(colors.customizable.primary)
                .disclosureGroupStyle(.custom)
        } else {
            DisclosureGroup(isExpanded: $isExpanded, content: content, label: label)
                .foregroundStyle(colors.customizable.primary)
        }
    }
}

// MARK: - DisclosureGroupStyle

@available(iOS 16.0, *)
extension DisclosureGroupStyle where Self == CustomDisclosureGroupStyle {
    
    static var custom: CustomDisclosureGroupStyle { CustomDisclosureGroupStyle() }
}

@available(iOS 16.0, *)
private struct CustomDisclosureGroupStyle: DisclosureGroupStyle, Themed {
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    
    // MARK: - Methods
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Button(action: {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            }, label: {
                HStack(alignment: .center) {
                    configuration.label
                                        
                    (configuration.isExpanded ? Asset.down : Asset.right)
                        .padding(.trailing, TreeFieldView.disclosureIndicatorTrailingPadding)
                }
            })
            .buttonStyle(.plain)
            
            ColoredDivider(colors.customizable.onBackground.opacity(0.1))
                .padding(.vertical, TreeFieldView.paddingVerticalCell)
            
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}
