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

/// Extension providing a convenience method for setting the background color of presented views.
extension View {
    
    /// Applies a custom background color to a presented view
    /// - Parameter color: The color to set as the presentation background
    ///
    /// - Returns: A view with the modified presentation background color
    func presentationWithBackgroundColor(_ color: Color) -> some View {
        modifier(PresentationBackgroundColorModifier(backgroundColor: color))
    }
}

// MARK: - PresentationBackgroundColorModifier

/// A view modifier that applies a custom background color to presented views
private struct PresentationBackgroundColorModifier: ViewModifier {
    
    /// The background color to apply to the presentation
    var backgroundColor: Color = .clear
    
    /// Applies the background color to the presented content
    /// - Parameter content: The content being presented
    ///
    /// - Returns: The modified view with the custom background
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content
                .presentationBackground(backgroundColor)
        } else {
            ZStack {
                UIKitIntrospectionView { hostingController in
                    hostingController.view.backgroundColor = UIColor(backgroundColor)
                }
                
                content
            }
        }
    }
}

// MARK: - UIKitIntrospectionView

/// A UIKit introspection view for accessing the underlying UIKit view hierarchy
private struct UIKitIntrospectionView: UIViewControllerRepresentable {
    
    /// Closure called when the hosting view controller is resolved
    let onResolve: (UIViewController) -> Void

    /// Creates the underlying view controller for introspection
    /// - Parameter context: The context in which this view controller is created
    /// - Returns: A new introspection view controller
    func makeUIViewController(context: Context) -> IntrospectionViewController {
        let controller = IntrospectionViewController()
        controller.onResolve = onResolve
        
        return controller
    }

    func updateUIViewController(_ uiViewController: IntrospectionViewController, context: Context) {
        // No update needed
    }
}

// MARK: - IntrospectionViewController

/// A custom view controller that provides access to its parent for introspection
private final class IntrospectionViewController: UIViewController {
    
    /// Closure called when the parent view controller is available
    var onResolve: ((UIViewController) -> Void)?

    /// Called when this view controller is moved to a parent
    /// - Parameter parent: The parent view controller
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if let parent {
            onResolve?(parent)
        }
    }
}
