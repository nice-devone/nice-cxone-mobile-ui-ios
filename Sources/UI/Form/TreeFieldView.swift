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

    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var entity: TreeFieldEntity

    static let disclosureIndicatorTrailingPadding: CGFloat = 13
    static let paddingBottomTitle: CGFloat = 20
    static let paddingLeadingIndentation: CGFloat = 22
    static let paddingVerticalCell: CGFloat = 10
    
    // MARK: - Init
    
    init(entity: TreeFieldEntity) {
        self.entity = entity
    }
    
    // MARK: - Content

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            titleView
            
            nodeListView

            requiredFieldView
        }
    }
}

// MARK: - Subviews

private extension TreeFieldView {
    
    func cell(node: TreeNodeFieldEntity, leadingPadding: CGFloat) -> some View {
        VStack(spacing: 0) {
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
            nodeLabelView(node: node, leadingPadding: leadingPadding)
        }
    }
    
    func leafNodeView(node: TreeNodeFieldEntity, leadingPadding: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(node.label)
                    .padding(.leading, leadingPadding)
                    .foregroundStyle(colors.customizable.onBackground)
                
                Spacer()
                
                if entity.value == node.value {
                    Asset.check
                        .foregroundStyle(colors.customizable.primary)
                        .padding(.trailing, Self.disclosureIndicatorTrailingPadding)
                }
            }
            .contentShape(Rectangle())
            
            ColoredDivider(colors.customizable.onBackground.opacity(0.1))
                .padding(.vertical, Self.paddingVerticalCell)
        }
        .onTapGesture {
            node.isSelected.toggle()
        
            if entity.value == node.value {
                entity.value = ""
            } else {
                entity.value = node.value
            }
        }
    }

    func nodeLabelView(node: TreeNodeFieldEntity, leadingPadding: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(node.label)
                    .foregroundStyle(colors.customizable.onBackground)
                    .padding(.leading, leadingPadding)
                
                Spacer()
            }
            
            conditionalDividerView
        }
        .background(colors.customizable.background)
    }

    func childrenListView(children: [TreeNodeFieldEntity], leadingPadding: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(children.indices, id: \.self) { index in
                let child = children[index]
                AnyView(
                    cell(node: child, leadingPadding: leadingPadding + Self.paddingLeadingIndentation)
                )
            }
        }
    }

    @ViewBuilder
    var conditionalDividerView: some View {
        if #unavailable(iOS 16) {
            ColoredDivider(colors.customizable.onBackground.opacity(0.1))
                .padding(.vertical, Self.paddingVerticalCell)
        }
    }
    
    var titleView: some View {
        Text(entity.formattedTitle)
            .font(.callout)
            .bold()
            .foregroundStyle(colors.customizable.onBackground)
            .padding(.bottom, Self.paddingBottomTitle)
    }
    
    var nodeListView: some View {
        ForEach(entity.children, id: \.id) { node in
            cell(node: node, leadingPadding: 0)
        }
    }
    
    @ViewBuilder
    var requiredFieldView: some View {
        if entity.isRequired {
            Text(localization.commonRequired)
                .font(.caption)
                .foregroundStyle(colors.background.errorContrast)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Previews

struct TreeFieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ScrollView {
                TreeFieldView(entity: MockData.treeFieldEntity())
            }
            .previewDisplayName("Light Mode")
        }
        .environmentObject(ChatStyle())
        .environmentObject(ChatLocalization())
    }
}
