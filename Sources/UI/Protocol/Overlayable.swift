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

protocol Overlayable: AnyObject {
    
    var overlay: (() -> AnyView)? { get set }
    var isOverlayDisplayed: Binding<Bool> { get }

    @MainActor
    func showOverlay<Content: View>(file: StaticString, line: UInt, @ViewBuilder _ overlay: @escaping () -> Content) async
    
    @MainActor
    func hideOverlay(file: StaticString, line: UInt) async
}

// MARK: - Default Implementation

extension Overlayable {
    
    var isOverlayDisplayed: Binding<Bool> {
        Binding(
            get: { self.overlay != nil },
            set: { _ in
                self.overlay = nil
            }
        )
    }
    
    @MainActor
    func showOverlay<Content: View>(file: StaticString = #file, line: UInt = #line, @ViewBuilder _ overlay: @escaping () -> Content) async {
        guard self.overlay == nil else {
            LogManager.error("Cannot show overlay: another overlay is already being displayed", file: file, line: line)
            return
        }
        
        self.overlay = {
            AnyView(overlay())
        }
        
        await Task.sleep(seconds: 0.5)
    }
    
    @MainActor
    func hideOverlay(file: StaticString = #file, line: UInt = #line) async {
        guard overlay != nil else {
            return
        }
        
        LogManager.trace("Hiding overlay", file: file, line: line)
        
        self.overlay = nil
        
        await Task.sleep(seconds: 0.5)
    }
}
