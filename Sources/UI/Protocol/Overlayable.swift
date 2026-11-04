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

@MainActor
protocol Overlayable: AnyObject {
    
    var sheet: (() -> AnyView)? { get set }
    var overlay: (() -> AnyView)? { get set }
    /// `true` from the moment a sheet starts closing until its dismissal wait has ended.
    var isSheetDismissing: Bool { get set }
    var isSheetDisplayed: Binding<Bool> { get }
    var isOverlayDisplayed: Binding<Bool> { get }

    @MainActor
    func showOverlay<Content: View>(@ViewBuilder _ overlay: @escaping () -> Content, file: StaticString, line: UInt) async
    
    @MainActor
    func hideOverlay(file: StaticString, line: UInt) async
    
    @MainActor
    func showSheet<Content: View>(@ViewBuilder _ overlay: @escaping () -> Content, file: StaticString, line: UInt) async
    
    @MainActor
    func hideSheet(file: StaticString, line: UInt) async
}

extension Overlayable {
    
    var sheet: (() -> AnyView)? {
        get { nil }
        set { } // swiftlint:disable:this unused_setter_value
    }
    
    var overlay: (() -> AnyView)? {
        get { nil }
        set { } // swiftlint:disable:this unused_setter_value
    }

    var isSheetDismissing: Bool {
        get { false }
        set { } // swiftlint:disable:this unused_setter_value
    }
}

// MARK: - Default Implementation

extension Overlayable {
    
    var isOverlayDisplayed: Binding<Bool> {
        Binding(
            get: { [weak self] in
                guard let self else {
                    return false
                }
                
                return self.overlay != nil
            },
            set: { [weak self] _ in
                guard let self else {
                    return
                }
                
                self.overlay = nil
            }
        )
    }
    
    var isSheetDisplayed: Binding<Bool> {
        Binding(
            get: { [weak self] in
                guard let self else {
                    return false
                }
                
                return self.sheet != nil
            },
            set: { [weak self] _ in
                guard let self else {
                    return
                }
                
                self.sheet = nil
            }
        )
    }
    
    @MainActor
    func showOverlay<Content: View>(@ViewBuilder _ overlay: @escaping () -> Content, file: StaticString = #file, line: UInt = #line) async {
        await show(.overlay, overlay, file: file, line: line)
    }
    
    @MainActor
    func hideOverlay(file: StaticString = #file, line: UInt = #line) async {
        await hide(.overlay, file: file, line: line)
    }
    
    @MainActor
    func showSheet<Content: View>(@ViewBuilder _ sheet: @escaping () -> Content, file: StaticString = #file, line: UInt = #line) async {
        await show(.sheet, sheet, file: file, line: line)
    }
    
    @MainActor
    func hideSheet(file: StaticString = #file, line: UInt = #line) async {
        await hide(.sheet, file: file, line: line)
    }
}

// MARK: - Helpers

private enum ContentType {
    case sheet
    case overlay
}

private extension Overlayable {
    
    @MainActor
    func show<Content: View>(_ type: ContentType, @ViewBuilder _ content: @escaping () -> Content, file: StaticString = #file, line: UInt = #line) async {
        let isOverlay = type == .overlay
        
        guard isOverlay ? overlay == nil : sheet == nil else {
            LogManager.warning("Cannot show \(isOverlay ? "overlay" : "sheet"): another one is already being displayed", file: file, line: line)
            return
        }
        
        switch type {
        case .overlay:
            self.overlay = {
                AnyView(content())
            }
        case .sheet:
            self.sheet = {
                AnyView(content())
            }
        }
        
        await Task.sleep(seconds: 0.5)
    }
    
    @MainActor
    func hide(_ type: ContentType, file: StaticString = #file, line: UInt = #line) async {
        let isOverlay = type == .overlay
        
        guard isOverlay ? overlay != nil : sheet != nil else {
            return
        }
        
        LogManager.trace("Hiding \(isOverlay ? "overlay" : "sheet")", file: file, line: line)
        
        switch type {
        case .overlay:
            self.overlay = nil
        case .sheet:
            // Raised before `sheet` clears, so a reader never sees `sheet == nil` without it
            self.isSheetDismissing = true
            self.sheet = nil
        }

        await Task.sleep(seconds: 0.5)

        if !isOverlay {
            self.isSheetDismissing = false
        }
    }
}
