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

struct TreeFieldView: View, Themed {

    // MARK: - Constants
    
    private enum Constants {
        
        enum Spacing {
            static let bodyVertical: CGFloat = 6
            static let cellVertical: CGFloat = 0
            static let nodeVertical: CGFloat = 16
            static let childrenListVertical: CGFloat = 0
        }
        
        enum Padding {
            static let indentationLeading: CGFloat = 16
            static let nodeInitialLeading: CGFloat = 0
            static let nodeVertical: CGFloat = 16
            static let checkHorizontal: CGFloat = 4
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var entity: TreeFieldEntity
    
    let onChange: () -> Void
    
    // MARK: - Init
    
    init(entity: TreeFieldEntity, onChange: @escaping () -> Void) {
        self.entity = entity
        self.onChange = onChange
    }
    
    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.bodyVertical) {
            Text(entity.isRequired ? String(format: localization.prechatSurveyRequiredLabel, entity.label) : entity.label)
                .font(.callout)
                .bold()
                .foregroundStyle(entity.isRequired && entity.value.isEmpty ? colors.status.error : colors.content.primary)
            
            ForEach(entity.children, id: \.id) { node in
                cell(node: node, leadingPadding: Constants.Padding.nodeInitialLeading)
            }

            if entity.isRequired, entity.value.isEmpty {
                Text(localization.commonRequired)
                    .font(.caption)
                    .foregroundStyle(colors.status.error)
            }
        }
    }
}

// MARK: - Subviews

private extension TreeFieldView {
    
    func cell(node: TreeNodeFieldEntity, leadingPadding: CGFloat) -> some View {
        VStack(spacing: Constants.Spacing.cellVertical) {
            if let children = node.children, !children.isEmpty {
                parentNodeView(node: node, leadingPadding: leadingPadding)
            } else {
                leafNodeView(node: node, leadingPadding: leadingPadding)
            }
        }
    }
        
    func parentNodeView(node: TreeNodeFieldEntity, leadingPadding: CGFloat) -> some View {
        DisclosureGroupView(isExpanded: !entity.value.isEmpty) {
            childrenListView(children: node.children ?? [], leadingPadding: leadingPadding)
        } label: {
            parentNoteLabelView(node: node, leadingPadding: leadingPadding)
        }
    }
    
    func leafNodeView(node: TreeNodeFieldEntity, leadingPadding: CGFloat) -> some View {
        Button {
            node.isSelected.toggle()
        
            entity.value = entity.value == node.value ? "" : node.value
            
            onChange()
        } label: {
            VStack(spacing: Constants.Spacing.nodeVertical) {
                HStack {
                    Text(node.label)
                        .padding(.leading, leadingPadding)
                        .foregroundStyle(colors.content.primary)
                    
                    Spacer()
                    
                    if entity.value == node.value {
                        Asset.check
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(colors.brand.primary)
                            .padding(.horizontal, Constants.Padding.checkHorizontal)
                    }
                }
                .contentShape(Rectangle())
                
                ColoredDivider(colors.border.default)
            }
        }
        .padding(.top, Constants.Padding.nodeVertical)
        .background(entity.value == node.value ? colors.background.surface.emphasis : colors.background.default)
    }

    func parentNoteLabelView(node: TreeNodeFieldEntity, leadingPadding: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.nodeVertical) {
            Text(node.label)
                .foregroundStyle(colors.content.primary)
                .padding(.leading, leadingPadding)
            
            if #unavailable(iOS 16) {
                ColoredDivider(colors.border.default)
            }
        }
        .background(colors.background.default)
        .padding(.vertical, Constants.Padding.nodeVertical)
    }

    func childrenListView(children: [TreeNodeFieldEntity], leadingPadding: CGFloat) -> some View {
        VStack(spacing: Constants.Spacing.childrenListVertical) {
            ForEach(children.indices, id: \.self) { index in
                AnyView(cell(node: children[index], leadingPadding: leadingPadding + Constants.Padding.indentationLeading))
            }
        }
    }
}

// MARK: - Previews

#Preview {
    ScrollView {
        TreeFieldView(entity: MockData.treeFieldEntity()) { }
    }
    .padding(.horizontal, 12)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
