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
import SwiftUIIntrospect

extension View {
    
    func onRefresh(onValueChanged: @escaping UIScrollView.ValueChangedAction) -> some View {
        self.modifier(OnListRefreshModifier(onValueChanged: onValueChanged))
    }
}

// MARK: - Helpers

extension UIScrollView {
    
    struct Keys {
        static var onValueChanged: UInt8 = 0
    }
    
    typealias ValueChangedAction = ((_ refreshControl: UIRefreshControl) -> Void)
    
    var onValueChanged: ValueChangedAction? {
        get { objc_getAssociatedObject(self, &Keys.onValueChanged) as? ValueChangedAction }
        set { objc_setAssociatedObject(self, &Keys.onValueChanged, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func onRefresh(_ onValueChanged: @escaping ValueChangedAction) {
        if refreshControl == nil {
            let refreshControl = UIRefreshControl()
            
            refreshControl.addTarget(self, action: #selector(self.onValueChangedAction), for: .valueChanged)
            
            self.refreshControl = refreshControl
        }
        
        self.onValueChanged = onValueChanged
    }
    
    @objc func onValueChangedAction(sender: UIRefreshControl) {
        self.onValueChanged?(sender)
    }
}

private struct OnListRefreshModifier: ViewModifier {
    
    let onValueChanged: UIScrollView.ValueChangedAction
    
    func body(content: Content) -> some View {
        content
            .introspect(.scrollView, on: .iOS(.v14, .v15, .v16, .v17), scope: .ancestor) { scrollView in
                scrollView.onRefresh(onValueChanged)
            }
    }
}

private struct RefreshAction {
    
    let action: () -> Void
    
    func callAsFunction() {
        action()
    }
}

private struct RefreshActionKey: EnvironmentKey {
    
    static let defaultValue: RefreshAction? = nil
}

private extension EnvironmentValues {
    
    var refresh: RefreshAction? {
        get { self[RefreshActionKey.self] }
        set { self[RefreshActionKey.self] = newValue }
    }
}
