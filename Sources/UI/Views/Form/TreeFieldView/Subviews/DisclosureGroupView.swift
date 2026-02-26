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
                .foregroundStyle(isExpanded ? colors.brand.primary : colors.content.tertiary)
                .disclosureGroupStyle(.custom)
        } else {
            DisclosureGroup(isExpanded: $isExpanded, content: content, label: label)
                .foregroundStyle(isExpanded ? colors.brand.primary : colors.content.tertiary)
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
    
    // MARK: - Constants
    
    private enum Constants {
        static let chevronExpandedAngle: CGFloat = 90
        
        enum Spacing {
            static let labelHorizontal: CGFloat = 0
        }
        enum Padding {
            static let chevronHorizontal: CGFloat = 4
        }
    }
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) var scheme
    
    @EnvironmentObject var style: ChatStyle
    
    // MARK: - Methods
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            Button {
                configuration.isExpanded.toggle()
            } label: {
                HStack(alignment: .center, spacing: Constants.Spacing.labelHorizontal) {
                    configuration.label

                    Spacer()
                    
                    Asset.right
                        .rotationEffect(Angle(degrees: configuration.isExpanded ? Constants.chevronExpandedAngle : .zero))
                        .font(.footnote.weight(.bold))
                        .padding(.horizontal, Constants.Padding.chevronHorizontal)
                }
                .background(colors.background.default)
            }
            
            ColoredDivider(colors.border.default)
            
            if configuration.isExpanded {
                configuration.content
            }
        }
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: configuration.isExpanded)
    }
}

// MARK: - Previews

#Preview {
    DisclosureGroupView(isExpanded: false) {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("iPhone 17 Air")
                
                ColoredDivider(Color(.systemGray3))
            }
            .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("iPhone 17 Pro")
                
                ColoredDivider(Color(.systemGray3))
            }
            .padding(.top, 16)
        }
    } label: {
        Text("iPhone")
            .padding(.vertical, 16)
    }
    .padding(.horizontal, 16)
    .environmentObject(ChatStyle())
}
