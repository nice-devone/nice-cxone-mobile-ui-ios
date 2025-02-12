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

import Foundation
import SwiftUI

// MARK: - Styleable NavigationBar

struct NavigationBar: View {
    
    // MARK: - Properties
    
    @Binding var left: NavigationItem.Left?
    @Binding var title: NavigationItem.Title?
    @Binding var right: [NavigationItem.Action]

    // MARK: - Init
    
    init(
        left: Binding<NavigationItem.Left?>,
        title: Binding<NavigationItem.Title?>,
        right: Binding<[NavigationItem.Action]>
    ) {
        self._left = left
        self._title = title
        self._right = right
    }

    init(item: ObservedObject<NavigationItem>.Wrapper) {
        self.init(
            left: item.left,
            title: item.title,
            right: item.right
        )
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            HStack {
                left?
                    .padding(.leading)
                
                Spacer()
                
                rightView
            }
            .frame(height: 75)
            
            HStack {
                title
                    .font(.system(size: 38, weight: .bold))
                    .padding(.leading)
                    .foregroundStyle(.blue)
                
                Spacer()
            }
        }
    }
    
    private var rightView: some View {
        Group {
            switch right.count {
            case 0:
                EmptyView()
            case 1:
                right.first?
                    .padding(.trailing)
            default:
                Menu {
                    ForEach(right, id: \.title) { item in
                        item
                    }
                } label: {
                    Asset.menu
                        .padding(.trailing)
                        .imageScale(.large)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Back") {
    @ObservedObject var item = NavigationItem(
        left: .back(title: "back") {},
        title: Text("Title"),
        right: [
            .back(title: "back") {},
            .down(title: "down") {}
        ]
    ) {
        Text("Body")
    }

    return VStack {
        NavigationBar(item: $item)
        
        Spacer()
    }
}

#Preview("No Back") {
    @ObservedObject var item = NavigationItem(
        title: Text("Title")
    ) {
        Text("Body")
    }

    return VStack {
        NavigationBar(item: $item)
        
        Spacer()
    }
}
