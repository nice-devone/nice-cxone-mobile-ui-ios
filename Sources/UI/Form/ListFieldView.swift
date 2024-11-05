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

struct ListFieldView: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @ObservedObject var entity: ListFieldEntity

    @State private var isActionSheetVisible = false
    
    // MARK: - Content

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entity.label)
                    .font(.caption)
                    .foregroundColor(style.formTextColor)
                
                HStack(spacing: 4) {
                    Button(entity.value.isEmpty ? localization.commonNoSelection : entity.selectedOption) {
                        isActionSheetVisible.toggle()
                    }
                    
                    Asset.disclosure
                        .font(.caption)
                        .rotationEffect(.degrees(isActionSheetVisible ? 90 : .zero))
                }
                .foregroundColor(style.formTextColor)

                if entity.isRequired {
                    Text(localization.commonRequired)
                        .font(.caption)
                        .foregroundColor(style.formErrorColor)
                }
            }
            
            Spacer()
        }
        .actionSheet(isPresented: $isActionSheetVisible) {
            var options: [ActionSheet.Button] = entity.options.map { option in
                .default(Text(option.value)) { entity.value = option.key }
            }
            options.append(.cancel { entity.value = "" })

            return ActionSheet(title: Text(entity.label), buttons: options)
        }
        .animation(.bouncy, value: isActionSheetVisible)
    }
}

// MARK: - Previews

struct ListFieldView_Previews: PreviewProvider {

    private static let entity = ListFieldEntity(
        label: "Color",
        isRequired: true,
        ident: "color",
        options: ["blue": "Blue", "yellow": "Yellow"],
        value: "yellow"
    )

    static var previews: some View {
        Group {
            ListFieldView(entity: entity)
                .previewDisplayName("Light Mode")
            
            ListFieldView(entity: entity)
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
