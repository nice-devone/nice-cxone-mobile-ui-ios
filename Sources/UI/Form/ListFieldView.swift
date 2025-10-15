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

struct ListFieldView: View, Themed {

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var entity: ListFieldEntity

    @State private var isActionSheetVisible = false
    @State private var hStackWidth: CGFloat = 0
    
    static let paddingBottomTitle: CGFloat = 10
    static let paddingLeadingChevron: CGFloat = 2
    static let paddingBottomSelectionButton: CGFloat = 10
    static let paddingTopRequiredText: CGFloat = 4
    static let dividerHeight: CGFloat = 1
    static let dividerFocusedHeight: CGFloat = 2
    static let placeholderOpacity: CGFloat = 0.5
    static let valueDisclosureSpacing: CGFloat = 16

    let onChange: () -> Void
    
    // MARK: - Content

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(entity.formattedTitle)
                    .font(.callout)
                    .bold()
                    .foregroundStyle(colors.customizable.onBackground)
                    .padding(.bottom, Self.paddingBottomTitle)
                 
                Button {
                    isActionSheetVisible.toggle()
                } label: {
                    HStack(spacing: Self.valueDisclosureSpacing) {
                        Text(entity.value.isEmpty ? localization.commonNoSelection : entity.selectedOption)
                            .foregroundStyle(colors.customizable.onBackground)
                            .opacity(entity.value.isEmpty ? Self.placeholderOpacity : 1)
                        
                        Asset.down
                            .font(.footnote)
                            .foregroundStyle(colors.customizable.primary)
                            .padding(.leading, Self.paddingLeadingChevron)
                    }
                }
                .overlay(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: PreferenceKeys.ContentSizeThatFitsKey.self, value: geometry.size)
                    }
                )
                .foregroundStyle(colors.customizable.onBackground)
                .padding(.bottom, Self.paddingBottomSelectionButton)
                
                ColoredDivider(
                    isActionSheetVisible ? colors.customizable.primary : colors.customizable.onBackground.opacity(0.1),
                    width: hStackWidth,
                    height: isActionSheetVisible ? Self.dividerFocusedHeight : Self.dividerHeight
                )
                
                if entity.isRequired {
                    Text(localization.commonRequired)
                        .font(.caption)
                        .foregroundStyle(colors.background.errorContrast)
                        .padding(.top, Self.paddingTopRequiredText)
                }
            }
            
            Spacer()
        }
        .onPreferenceChange(PreferenceKeys.ContentSizeThatFitsKey.self) { size in
            self.hStackWidth = size.width
        }
        .confirmationDialog(entity.value, isPresented: $isActionSheetVisible) {
            ForEach(Array(entity.options.keys), id: \.self) { key in
                if let value = entity.options[key] {
                    Button(value) {
                        // Do not use actual value, it's necessary to use key which is unique identifier for the value
                        entity.value = key
                        onChange()
                    }
                } else {
                    EmptyView()
                        .onAppear {
                            LogManager.error("Unable to get value for option \(key)")
                        }
                }
                
            }
            
            Button(localization.commonCancel, role: .cancel) {
                entity.value = ""
            }
        }
        .animation(.default, value: isActionSheetVisible)
        .animation(.default, value: hStackWidth)
    }
}

// MARK: - Previews

#Preview {
    let entity = ListFieldEntity(
        label: "Color",
        isRequired: true,
        ident: "color",
        options: ["blue": "Blue", "yellow": "Yellow", "experimental_green": "Experimental Green"],
        value: "yellow"
    )
    
    ListFieldView(entity: entity) { }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
}
