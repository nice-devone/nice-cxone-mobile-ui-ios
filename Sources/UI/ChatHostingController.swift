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
import UIKit

class ChatHostingController<Content>: UIHostingController<Content> where Content: View {
    
    // MARK: - Structs
    
    struct NavigationBarAppearance {
        let standard: UINavigationBarAppearance
        let compact: UINavigationBarAppearance?
        let scrollEdge: UINavigationBarAppearance?
        let tintColor: UIColor
        let isTranslucent: Bool
    }
    
    struct SegmentControlAppearance {
        let selectedSegmentTintColor: UIColor?
        let normalTitleColor: UIColor
        let selectedTitleColor: UIColor
        let backgroundColor: UIColor?
    }
    
    struct AlertControllerAppearance {
        let tintColor: UIColor
    }
    
    // MARK: - Properties
    
    let chatStyle: ChatStyle
    
    private var previousNavigationAppearance: NavigationBarAppearance?
    private var previousSegmentControlAppearance: SegmentControlAppearance?
    private var previousAlertControllerAppearance: AlertControllerAppearance?
    private var canHandleWillDisappear = false
    private var didAppear = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        UIColor(customizableColors(for: traitCollection.userInterfaceStyle).background).isLight ? .darkContent : .lightContent
    }
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(rootView: Content, chatStyle: ChatStyle) {
        self.chatStyle = chatStyle
        super.init(rootView: rootView)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onColorSchemeChanged),
            name: .colorSchemeChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .colorSchemeChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !didAppear else {
            return
        }
        
        didAppear = true
        
        updateNavigationBarAppearance(for: traitCollection, isHidden: true)
        updateAlertControllerAppearance(for: traitCollection)
        updateSegmentedControlAppearance(for: traitCollection)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        canHandleWillDisappear = parent == nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // The method is called even when the ThreadView is pushed on top of the ThreadList,
        // so it's necessary to check if the view is being removed from the navigation stack
        guard canHandleWillDisappear else {
            return
        }
        
        canHandleWillDisappear = false
        
        navigationController?.navigationBar.resetChatAppearance(with: previousNavigationAppearance)
        UISegmentedControl.appearance(for: traitCollection).resetChatAppearance(with: previousSegmentControlAppearance)
        UIView.resetChatAppearance(with: previousAlertControllerAppearance, for: traitCollection)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateNavigationBarAppearance(for: traitCollection, isHidden: false)
            updateAlertControllerAppearance(for: traitCollection)
            updateSegmentedControlAppearance(for: traitCollection)
        }
    }
    
    // MARK: - Actions
    
    @objc private func onColorSchemeChanged() {
        LogManager.trace("Color scheme changed in a subview")
        
        let newTrait = traitCollection.userInterfaceStyle == .light
            ? UITraitCollection(userInterfaceStyle: .dark)
            : UITraitCollection(userInterfaceStyle: .light)
        
        updateNavigationBarAppearance(for: newTrait, isHidden: false)
        updateAlertControllerAppearance(for: newTrait)
        updateSegmentedControlAppearance(for: newTrait)
    }
    
    @objc private func onWillEnterForeground() {
        LogManager.trace("App will enter foreground, updating appearance")

        // Get the actual system interface style
        let actualStyle = UITraitCollection.current.userInterfaceStyle
        
        if let navigationController {
            navigationController.navigationBar.chatAppearance(with: customizableColors(for: actualStyle), isHidden: false)
        } else {
            LogManager.error("Unable to update NavigationBar appearance")
        }

        // Update other appearances
        updateAlertControllerAppearance(for: UITraitCollection(userInterfaceStyle: actualStyle))
        updateSegmentedControlAppearance(for: UITraitCollection(userInterfaceStyle: actualStyle))
    }
}

// MARK: - Private methods

private extension ChatHostingController {
    
    func updateNavigationBarAppearance(for traitCollection: UITraitCollection, isHidden: Bool) {
        guard let navigationController else {
            LogManager.error("Unable to update NavigationBar appearance")
            return
        }
        
        LogManager.trace("Updating NavigationBar appearance for \(traitCollection.userInterfaceStyle)")
        
        let customizableColors = customizableColors(for: traitCollection.userInterfaceStyle)
        
        // Persist previous appearance to restore it when the view disappears if needed
        if let tintColor = navigationController.navigationBar.tintColor {
            previousNavigationAppearance = NavigationBarAppearance(
                standard: navigationController.navigationBar.standardAppearance,
                compact: navigationController.navigationBar.compactAppearance,
                scrollEdge: navigationController.navigationBar.scrollEdgeAppearance,
                tintColor: tintColor,
                isTranslucent: navigationController.navigationBar.isTranslucent
            )
        }
        
        // Update to chat appearance
        navigationController.navigationBar.chatAppearance(with: customizableColors, isHidden: isHidden)
    }
    
    func updateAlertControllerAppearance(for traitCollection: UITraitCollection) {
        LogManager.trace("Updating UIAlertController appearance for \(traitCollection.userInterfaceStyle)")
        
        // Persist previous appearance to restore it when the view disappears if needed
        if let tintColor = UIView.appearance(for: traitCollection, whenContainedInInstancesOf: [UIAlertController.self]).tintColor {
            previousAlertControllerAppearance = AlertControllerAppearance(tintColor: tintColor)
        }
        
        let customizableColors = customizableColors(for: traitCollection.userInterfaceStyle)
        
        // Update to chat appearance
        UIView.defaultAlertAppearance(with: customizableColors, for: traitCollection)
    }
    
    func updateSegmentedControlAppearance(for traitCollection: UITraitCollection) {
        LogManager.trace("Updating SegmentedControl appearance for \(traitCollection.userInterfaceStyle)")
        
        // Persist previous appearance to restore it when the view disappears
        if let backgroundColor = UISegmentedControl.appearance(for: traitCollection).backgroundColor {
            previousSegmentControlAppearance = SegmentControlAppearance(
                selectedSegmentTintColor: UISegmentedControl.appearance(for: traitCollection).selectedSegmentTintColor,
                normalTitleColor: UISegmentedControl.appearance(for: traitCollection).titleForegroundColor(for: .normal, traitCollection: traitCollection),
                selectedTitleColor: UISegmentedControl.appearance(for: traitCollection).titleForegroundColor(for: .selected, traitCollection: traitCollection),
                backgroundColor: backgroundColor
            )
        }
        
        let customizableColors = customizableColors(for: traitCollection.userInterfaceStyle)
        
        // Update to chat appearance
        UISegmentedControl.chatAppearance(with: customizableColors, for: traitCollection)
    }
        
    func customizableColors(for userInterfaceStyle: UIUserInterfaceStyle) -> any CustomizableStyleColors {
        userInterfaceStyle == .light
            ? chatStyle.colors.light.customizable
            : chatStyle.colors.dark.customizable
    }
}

// MARK: - Helpers

private extension UISegmentedControl {
    
    func titleForegroundColor(for state: UIControl.State, traitCollection: UITraitCollection) -> UIColor {
        if let attributes = titleTextAttributes(for: state)?[.foregroundColor] as? UIColor {
            return attributes
        } else {
            return traitCollection.userInterfaceStyle == .light ? .black : .white
        }
    }
}

private extension UIColor {
    
    var isLight: Bool {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return brightness > 0.5
    }
}
