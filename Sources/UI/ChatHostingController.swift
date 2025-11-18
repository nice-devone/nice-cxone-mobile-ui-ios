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
        let compactScrollEdge: UINavigationBarAppearance?
        let tintColor: UIColor
        let isTranslucent: Bool
    }
    
    struct SegmentControlAppearance {
        let selectedSegmentTintColor: UIColor?
        let normalTitleColor: UIColor?
        let normalFont: UIFont?
        let selectedTitleColor: UIColor?
        let selectedFont: UIFont?
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
        UIColor(styleColors(for: traitCollection.userInterfaceStyle).background.default).isLight ? .darkContent : .lightContent
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
        
        updateNavigationBarAppearance(for: .light)
        updateSegmentedControlAppearance(for: .light)
        updateAlertControllerAppearance(for: .light)
        
        updateNavigationBarAppearance(for: .dark)
        updateSegmentedControlAppearance(for: .dark)
        updateAlertControllerAppearance(for: .dark)
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
        
        UINavigationBar.appearance(for: .light).resetChatAppearance(with: previousNavigationAppearance)
        UISegmentedControl.appearance(for: .light).resetChatAppearance(with: previousSegmentControlAppearance)
        UIView.resetChatAppearance(with: previousAlertControllerAppearance, for: .light)
        
        UINavigationBar.appearance(for: .dark).resetChatAppearance(with: previousNavigationAppearance)
        UISegmentedControl.appearance(for: .dark).resetChatAppearance(with: previousSegmentControlAppearance)
        UIView.resetChatAppearance(with: previousAlertControllerAppearance, for: .dark)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateNavigationBarAppearance(for: traitCollection)
            updateAlertControllerAppearance(for: traitCollection)
            updateSegmentedControlAppearance(for: traitCollection)
        }
    }
    
    // MARK: - Actions
    
    @objc private func onColorSchemeChanged() {
        LogManager.trace("Color scheme changed in a subview")
        
        let newTrait: UITraitCollection = traitCollection.userInterfaceStyle == .light ? .dark : .light
        
        updateNavigationBarAppearance(for: newTrait)
        updateAlertControllerAppearance(for: newTrait)
        updateSegmentedControlAppearance(for: newTrait)
    }
    
    @objc private func onWillEnterForeground() {
        LogManager.trace("App will enter foreground, updating appearance")

        // Get the actual system interface style
        let actualStyle = UITraitCollection.current.userInterfaceStyle
        
        if let navigationController {
            navigationController.navigationBar.chatAppearance(with: styleColors(for: actualStyle))
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
    
    func updateNavigationBarAppearance(for traitCollection: UITraitCollection) {
        guard let navigationController else {
            LogManager.error("Unable to update NavigationBar appearance")
            return
        }
        
        LogManager.trace("Updating NavigationBar appearance for \(traitCollection.userInterfaceStyle)")
        
        // Persist previous appearance to restore it when the view disappears if needed
        if let tintColor = navigationController.navigationBar.tintColor {
            previousNavigationAppearance = NavigationBarAppearance(
                standard: navigationController.navigationBar.standardAppearance,
                compact: navigationController.navigationBar.compactAppearance,
                scrollEdge: navigationController.navigationBar.scrollEdgeAppearance,
                compactScrollEdge: navigationController.navigationBar.compactScrollEdgeAppearance,
                tintColor: tintColor,
                isTranslucent: navigationController.navigationBar.isTranslucent
            )
        }
        
        // Update to chat appearance
        navigationController.navigationBar.chatAppearance(with: styleColors(for: traitCollection.userInterfaceStyle))
    }
    
    func updateAlertControllerAppearance(for traitCollection: UITraitCollection) {
        LogManager.trace("Updating UIAlertController appearance for \(traitCollection.userInterfaceStyle)")
        
        // Persist previous appearance to restore it when the view disappears if needed
        if let tintColor = UIView.appearance(for: traitCollection, whenContainedInInstancesOf: [UIAlertController.self]).tintColor {
            previousAlertControllerAppearance = AlertControllerAppearance(tintColor: tintColor)
        }
        
        // Update to chat appearance
        UIView.chatAlertAppearance(with: styleColors(for: traitCollection.userInterfaceStyle), for: traitCollection)
    }
    
    func updateSegmentedControlAppearance(for traitCollection: UITraitCollection) {
        LogManager.trace("Updating SegmentedControl appearance for \(traitCollection.userInterfaceStyle)")
        
        // Persist previous appearance to restore it when the view disappears
        let previousAppearance = UISegmentedControl.appearance(for: traitCollection)
        
        if let backgroundColor = previousAppearance.backgroundColor {
            previousSegmentControlAppearance = SegmentControlAppearance(
                selectedSegmentTintColor: previousAppearance.selectedSegmentTintColor,
                normalTitleColor: previousAppearance.attribute(.foregroundColor, for: .normal),
                normalFont: previousAppearance.attribute(.font, for: .normal),
                selectedTitleColor: previousAppearance.attribute(.foregroundColor, for: .selected),
                selectedFont: previousAppearance.attribute(.font, for: .selected),
                backgroundColor: backgroundColor
            )
        }
        
        // Update to chat appearance
        UISegmentedControl.chatAppearance(with: styleColors(for: traitCollection.userInterfaceStyle), for: traitCollection)
    }
        
    func styleColors(for userInterfaceStyle: UIUserInterfaceStyle) -> any StyleColors {
        userInterfaceStyle == .light ? chatStyle.colors.light : chatStyle.colors.dark
    }
}

// MARK: - Helpers

private extension UISegmentedControl {
    
    func attribute<T: Any>(_ attribute: NSAttributedString.Key, for state: UIControl.State) -> T? {
        titleTextAttributes(for: state)?[attribute] as? T
    }
}

private extension UIColor {
    
    var isLight: Bool {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return brightness > 0.5
    }
}
