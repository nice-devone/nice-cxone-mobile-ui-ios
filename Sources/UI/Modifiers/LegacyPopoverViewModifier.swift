//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import SwiftUI

struct LegacyPopoverViewModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    
    let content: () -> PopoverContent
    let arrowEdge: Edge

    // MARK: - Init
    
    init(isPresented: Binding<Bool>, arrowEdge: Edge, content: @escaping () -> PopoverContent) {
        self._isPresented = isPresented
        self.content = content
        self.arrowEdge = arrowEdge
    }

    // MARK: - Builder
    
    func body(content: Content) -> some View {
        content
            .background(LegacyPopover(isPresented: self.$isPresented, arrowEdge: arrowEdge, content: self.content))
    }
}
