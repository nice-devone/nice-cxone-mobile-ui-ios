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

// MARK: - Modifier

private struct LegacyPopoverViewModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    
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

// MARK: - UIViewControllerRepresentable

struct LegacyPopover<Content: View>: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    
    @ViewBuilder let content: () -> Content

    let arrowDirection: UIPopoverArrowDirection
    
    // MARK: - Init
    
    init(isPresented: Binding<Bool>, arrowEdge: Edge, content: @escaping () -> Content) {
        self._isPresented = isPresented
        self.content = content
        self.arrowDirection = switch arrowEdge {
        case .top: .up
        case .leading: .left
        case .trailing: .right
        case .bottom: .down
        }
    }

    // MARK: - Methods
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, content: self.content())
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.host.rootView = self.content()

        guard context.coordinator.lastIsPresentedValue != self.isPresented else {
            return
        }

        context.coordinator.lastIsPresentedValue = self.isPresented

        guard isPresented else {
            return
        }
        
        let host = context.coordinator.host

        if context.coordinator.viewSize == .zero {
            context.coordinator.viewSize = host.sizeThatFits(in: UIView.layoutFittingExpandedSize)
        }

        host.preferredContentSize = context.coordinator.viewSize
        host.modalPresentationStyle = .popover

        host.popoverPresentationController?.delegate = context.coordinator
        host.popoverPresentationController?.sourceView = uiViewController.view
        host.popoverPresentationController?.sourceRect = uiViewController.view.bounds
        host.popoverPresentationController?.permittedArrowDirections = [.up]

        if let presentedVC = uiViewController.presentedViewController {
            presentedVC.dismiss(animated: true) {
                uiViewController.present(host, animated: true, completion: nil)
            }
        } else {
            uiViewController.present(host, animated: true, completion: nil)
        }
    }

    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
    
        // MARK: - Properties
        
        let host: UIHostingController<Content>

        var lastIsPresentedValue: Bool = false
        var viewSize: CGSize = .zero

        private let parent: LegacyPopover
        
        // MARK: - Init
        
        init(parent: LegacyPopover, content: Content) {
            self.parent = parent
            self.host = UIHostingController(rootView: content)
        }

        // MARK: - Methods
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            parent.isPresented = false
        }

        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            .none
        }
    }
}
