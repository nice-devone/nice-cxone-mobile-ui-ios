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

extension View {
    
    /// Presents a popover view with adaptive behavior based on the iOS version.
    ///
    /// This method ensures compatibility across different iOS versions by applying a standard `.popover` on iOS 16.4 and later,
    /// while falling back to the custom `LegacyPopoverViewModifier` modifier on earlier versions.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether the popover is presented.
    ///   - content: A closure returning the content of the popover.
    ///
    /// - Returns: A view that conditionally applies a popover presentation depending on the iOS version.
    ///
    /// - Note: This method uses `AnyView` to erase the view type and unify the return type across
    ///   different branches of the availability check.
    func adaptiveTooltip<Content: View>(isPresented: Binding<Bool>, arrowEdge: Edge = .top, @ViewBuilder content: @escaping () -> Content) -> some View {
        if #available(iOS 16.4, *) {
            AnyView(
                self.popover(isPresented: isPresented, arrowEdge: arrowEdge, content: content)
            )
        } else {
            AnyView(self.modifier(LegacyPopoverViewModifier(isPresented: isPresented, arrowEdge: arrowEdge, content: content)))
        }
    }
}
