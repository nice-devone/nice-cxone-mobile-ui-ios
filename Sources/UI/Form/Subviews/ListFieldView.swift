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

import SwiftUI

struct ListFieldView: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    
    @ObservedObject var entity: ListFieldEntity

    // MARK: - Content

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(entity.label)
                    .font(.caption)
                    .foregroundColor(style.formTextColor)

                Picker("", selection: $entity.value) {
                    Text("No Selection")
                        .tag("")
                    
                    ForEach(entity.options.map(\.value), id: \.self) { value in
                        Text(value)
                            .tag(entity.getKey(listOption: value))
                    }
                }
                .pickerStyle(.menu)
                .accentColor(style.formTextColor)

                if entity.isRequired {
                    Text("Required Field")
                        .font(.caption)
                        .foregroundColor(style.formErrorColor)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Helpers

private extension ListFieldEntity {
    
    func getKey(listOption: String) -> String {
        guard let key = options.first(where: { $1 == listOption })?.key else {
            LogManager.error(.unableToParse(listOption, from: options))
            return ""
        }
        
        return key
    }
}

// MARK: - Previews

struct ListFieldView_Previews: PreviewProvider {

    private static let entity = ListFieldEntity(label: "Color", isRequired: true, ident: "color", options: ["blue": "Blue", "yellow": "Yellow"])

    static var previews: some View {
        Group {
            ListFieldView(entity: entity)
                .previewDisplayName("Light Mode")
            
            ListFieldView(entity: entity)
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
        .environmentObject(ChatStyle())
    }
}
