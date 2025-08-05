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

struct TreeFieldView: View {

    // MARK: - Properties

    @EnvironmentObject private var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @ObservedObject var entity: TreeFieldEntity
    
    @State private var selectedNodeId: String?
    
    // MARK: - Init
    
    init(entity: TreeFieldEntity) {
        self.entity = entity
        self.selectedNodeId = entity.children.find(with: entity.value)?.idString
    }
    
    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entity.label)
                .font(.caption)
                .foregroundColor(style.formTextColor)
            
            ForEach(entity.children, id: \.idString) { node in
                cell(node: node, leadingPadding: 0)
                    .padding(.vertical, 4)
            }
            
            if entity.isRequired {
                Text(localization.commonRequired)
                    .font(.caption)
                    .foregroundColor(style.formErrorColor)
            }
        }
    }
}

// MARK: - Subviews

private extension TreeFieldView {

    @ViewBuilder
    func cell(node: TreeNodeFieldEntity, leadingPadding: CGFloat) -> some View {
        if let children = node.children, !children.isEmpty {
            DisclosureGroupView(node: node, isExpanded: !entity.value.isEmpty) {
                ForEach(children, id: \.idString) { child in
                    AnyView(cell(node: child, leadingPadding: leadingPadding + 20))
                }
            } label: {
                Text(node.label)
                    .padding(.leading, leadingPadding)
                    .foregroundColor(style.formTextColor)
            }
        } else {
            HStack {
                Text(node.label)
                    .padding(.leading, leadingPadding)
                    .foregroundColor(style.formTextColor)
                
                Spacer()

                if entity.value == node.value {
                    Asset.check
                        .foregroundColor(style.formTextColor)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                node.isSelected.toggle()
                
                let shouldDeselectNode = selectedNodeId != nil && selectedNodeId == node.idString
                selectedNodeId = shouldDeselectNode ? nil : node.idString
                entity.value = shouldDeselectNode ? "" : node.value
            }
        }
    }
}

private struct DisclosureGroupView<Label, Content>: View where Label: View, Content: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @State private var isExpanded: Bool
    
    let node: TreeNodeFieldEntity
    var content: () -> Content
    var label: () -> Label
    
    init(node: TreeNodeFieldEntity, isExpanded: Bool, content: @escaping () -> Content, label: @escaping () -> Label) {
        self.node = node
        self.isExpanded = isExpanded
        self.content = content
        self.label = label
    }
    
    // MARK: - Builder
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded, content: content, label: label)
            .foregroundColor(style.formTextColor)
    }
}

// MARK: - Previews

struct TreeFieldView_Previews: PreviewProvider {
    
    private static let entity = TreeFieldEntity(
        label: "Devices",
        isRequired: true,
        ident: "devices",
        children: [
            TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Mobile Phone", value: "phone", children: [
                TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Apple", value: "apple", children: [
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "iPhone 14", value: "iphone_14"),
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "iPhone 14 Pro", value: "iphone_14_pro"),
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "iPhone 15", value: "iphone_15"),
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "iPhone 15 Pro", value: "iphone_15_pro")
                ]),
                TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Android", value: "android", children: [
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Samsung", value: "samsung", children: [
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Galaxy A5", value: "samsung_galaxy_a5"),
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Galaxy A51", value: "samsung_galaxy_a51"),
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Galaxy S5", value: "samsung_galaxy_s5")
                    ]),
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Xiaomi", value: "xiaomi", children: [
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "mi 5", value: "xiaomi_mi_5"),
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "mi 6", value: "xiaomi_mi_6"),
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "mi 7", value: "xiaomi_mi_7")
                    ])
                ])
            ]),
            TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Laptop", value: "laptop", children: [
                TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Windows", value: "windows", children: [
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Acer", value: "acer", children: [
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Aspire E5", value: "acer_aspire_e5"),
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Aspire E5 Pro", value: "acer_aspire_e5_pro")
                    ]),
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Asus", value: "asus", children: [
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "ZenBook", value: "zenbook"),
                        TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "ZenBook Pro", value: "zenbook_pro")
                    ])
                ]),
                TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "MacOS", value: "macos", children: [
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "MacBook", value: "macbook"),
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "MacBook Air", value: "macbook_air"),
                    TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "MacBook Pro", value: "macbook_pro")
                ])
            ]),
            TreeNodeFieldEntity(id: UUID().uuidString.lowercased(), label: "Other", value: "other")
        ],
        value: "iphone_14"
    )
    
    static var previews: some View {
        Group {
            ScrollView {
                TreeFieldView(entity: entity)
            }
            .previewDisplayName("Light Mode")
            
            ScrollView {
                TreeFieldView(entity: entity)
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .padding(.horizontal, 16)
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
