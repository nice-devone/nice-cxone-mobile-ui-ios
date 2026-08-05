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
import UIKit

@MainActor
final class OverlayManager: ObservableObject {
    
    // MARK: - Properties
    
    private var window: UIWindow?
    
    // MARK: - Methods
    
    func show<Content: View>(@ViewBuilder content: () -> Content) {
        guard window == nil else {
            LogManager.warning("Overlay already displayed, ignoring show request")
            return
        }
        guard let scene = currentWindowScene else {
            LogManager.error("Unable to get scene")
            return
        }
        
        LogManager.trace("Show overlay")
        
        let window = UIWindow(windowScene: scene)
        let controller = UIHostingController(rootView: content())
        controller.view.backgroundColor = .clear
        
        window.layer.opacity = 0
        window.windowLevel = .statusBar + 1
        window.backgroundColor = .clear
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
        
        // Animate the show transition
        UIView.animate(withDuration: StyleGuide.animationDuration) { [weak window] in
            window?.layer.opacity = 1
        }
    }
    
    func hide() {
        guard window != nil else {
            return
        }
        
        LogManager.trace("Hide overlay")
        
        // Animate the hiding transition
        UIView.animate(withDuration: StyleGuide.animationDuration) { [weak window] in
            window?.layer.opacity = 0
        } completion: { [weak self] _ in
            self?.window?.isHidden = true
            self?.window = nil
        }
    }
}

// MARK: - Private methods

private extension OverlayManager {
    
    /// Returns the most appropriate `UIWindowScene` for presenting overlay content if one can be determined;
    /// otherwise `nil` if there are no connected window scenes.
    ///
    /// The method inspects the app's connected scenes and prefers, in order:
    /// - A scene that is currently in the `.foregroundActive` state.
    /// - A scene whose window stack contains the key window.
    /// - The first available window scene as a final fallback.
    var currentWindowScene: UIWindowScene? {
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        // Prefer the scene that is actively in the foreground.
        if let foregroundActiveScene = windowScenes.first(where: { $0.activationState == .foregroundActive }) {
            return foregroundActiveScene
        }

        // Next, try the scene that currently hosts the key window.
        if let keyWindowScene = windowScenes.first(where: { $0.windows.contains(where: \.isKeyWindow) }) {
            return keyWindowScene
        }

        // As a final fallback, return the first available window scene (if any).
        return windowScenes.first
    }
}

// MARK: - Preview

// swiftlint:disable hardcoded_strings
private struct TestView: View {
    
    // MARK: - Properties
    
    @StateObject var overlayManager = OverlayManager()
    @State var showOverlay = false
    
    // MARK: - Builder
    
    var body: some View {
        NavigationStack {
            Button {
                showOverlay = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .padding()

                    Text("Show overlay")
                }
            }
            .onChange(of: showOverlay) { show in
                if show {
                    overlayManager.show {
                        loadingContent
                    }
                } else {
                    overlayManager.hide()
                }
            }
            .onDisappear(perform: overlayManager.hide)
            .navigationTitle("Dashboard")
        }
    }
    
    var loadingContent: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .ignoresSafeArea(.all)
            
            VStack {
                ProgressView("Loading")
                
                Button("Cancel") {
                    showOverlay = false
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview("Full screen") {
    TestView()
}

#Preview("Modal") {
    NavigationStack {
        Color.clear
            .sheet(isPresented: .constant(true)) {
                TestView()
            }
            .navigationTitle("Dashboard")
    }
}
// swiftlint:enable hardcoded_strings
