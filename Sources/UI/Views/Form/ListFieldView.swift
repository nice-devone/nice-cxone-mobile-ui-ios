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

    // MARK: - Constants
    
    private enum Constants {
        
        enum Padding {
            static let chevronHorizontal: CGFloat = 4
            static let textFieldVertical: CGFloat = 4
        }
        
        enum Sizing {
            static let dividerHeight: CGFloat = 1
            static let dividerFocusedHeight: CGFloat = 2
        }
        
        enum Spacing {
            static let bodyVertical: CGFloat = 6
            static let textFieldDividerSpacing: CGFloat = 8
            static let valueDisclosureHorizontal: CGFloat = 16
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var entity: ListFieldEntity

    @State private var isActionSheetVisible = false
    @State private var error: String?
    
    let onChange: () -> Void
    
    // MARK: - Init
    
    init(entity: ListFieldEntity, onChange: @escaping () -> Void) {
        self.entity = entity
        self.onChange = onChange
    }
    
    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.bodyVertical) {
            Text(entity.isRequired ? String(format: localization.formRequiredLabel, entity.label) : entity.label)
                .font(.callout)
                .bold()
                .foregroundStyle(error != nil ? colors.status.error : colors.content.primary)
            
            VStack(spacing: Constants.Spacing.textFieldDividerSpacing) {
                Button {
                    isActionSheetVisible.toggle()
                } label: {
                    HStack(spacing: Constants.Spacing.valueDisclosureHorizontal) {
                        Text(entity.value.isEmpty ? localization.commonNoSelection : entity.selectedOption)
                            .foregroundStyle(error != nil ? colors.status.error : colors.content.primary)
                        
                        Spacer()
                        
                        Asset.down
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(error != nil ? colors.status.error : colors.content.tertiary)
                            .padding(.horizontal, Constants.Padding.chevronHorizontal)
                    }
                }
                .foregroundStyle(colors.content.primary)
                .padding(.vertical, Constants.Padding.textFieldVertical)
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
                
                ColoredDivider(
                    error != nil
                        ? colors.status.error
                        : isActionSheetVisible || !entity.value.isEmpty
                            ? colors.brand.primary
                            : colors.border.default,
                    height: isActionSheetVisible || !entity.value.isEmpty
                        ? Constants.Sizing.dividerFocusedHeight
                        : Constants.Sizing.dividerHeight
                )
            }
            
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(colors.status.error)
            }
        }
        .onChange(of: entity.value) { value in
            error = value.isEmpty && entity.isRequired ? localization.commonRequired : nil
        }
        .onChange(of: isActionSheetVisible) { isVisible in
            if !isVisible {
                error = entity.value.isEmpty && entity.isRequired ? localization.commonRequired : nil
            }
        }
        .animation(.easeInOut(duration: StyleGuide.animationDuration), value: isActionSheetVisible)
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 24) {
        ListFieldView(
            entity: ListFieldEntity(
                label: "Color",
                isRequired: false,
                ident: "color",
                options: ["blue": "Blue", "yellow": "Yellow", "experimental_green": "Experimental Green"],
                value: "yellow"
            )
        ) { }
        
        ListFieldView(
            entity: ListFieldEntity(
                label: "Color",
                isRequired: true,
                ident: "color",
                options: ["blue": "Blue", "yellow": "Yellow", "experimental_green": "Experimental Green"]
            )
        ) { }
    }
    .padding(.horizontal, 16)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
