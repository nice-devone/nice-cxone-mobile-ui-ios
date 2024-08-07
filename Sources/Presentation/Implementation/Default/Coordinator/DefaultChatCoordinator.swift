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

import CXoneChatSDK
import SwiftUI
import UIKit

/// Class responsible for coordinating and managing chat related views navigation
///
/// This class is designed to simplify the management of chat related views navigation,
/// such as thread list, form or transcript, allowing you to initialize and present chat interfaces with customizable visual styles,
/// specify threads to open, and present dynamic forms. 
/// It offers flexibility in creating and managing chat-related content within your application.
public class DefaultChatCoordinator {

    // MARK: - Properties

    private let navigationController: UINavigationController
    
    var onFinished: (() -> Void)?
    
    public var style = ChatStyle()

    public var chatLocalization = ChatLocalization()
    
    private var appViewsStack = [UIViewController]()
    
    // MARK: - Init
    
    /// Initialization of the DefaultChatCoordinator
    ///
    /// - Parameter navigationController: A container view controller that defines a stack-based scheme for navigating chat related content.
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    
    /// A function that initiates and presents a default chat interface implementation
    ///
    /// This function is designed to initialize and present a chat interface with a specified visual style,
    /// optionally specifying a thread to open and a completion callback.
    /// It enables you to create and customize chat interactions and provides flexibility in managing the chat's appearance and behavior.
    public func start(threadIdToOpen: UUID? = nil, onFinished: (() -> Void)?) {
        self.onFinished = onFinished
        self.appViewsStack = navigationController.viewControllers
        
        showCoordinator(threadIdToOpen: threadIdToOpen)
    }
    
    /// A function that presents a form view with custom fields to collect user input.
    ///
    /// This function is designed to simplify the presentation of a dynamic form with custom fields,
    /// allowing you to specify the form's title and structure.
    /// Once the user completes the form, the `onFinished` closure is invoked, providing access to the collected data for further processing.
    ///
    /// - Parameters:
    ///   - title: The title of the form.
    ///   - customFields: An array of custom form field types (conforming to `FormCustomFieldType`) to define the form's structure.
    ///   - onFinished: A closure that is called when the user completes the form, passing a dictionary of collected data.
    ///
    /// ## Example
    /// ```
    /// let customFields = [
    ///     FormCustomFieldType(label: "Email", isRequired: false, ident: "emailField", value: "john.doe@gmail.com"),
    ///     FormCustomFieldType(label: "First Name", isRequired: true, ident: "firstName", value: "John"),
    ///     FormCustomFieldType(label: "Last Name", isRequired: true, ident: "lastName", value: "Doe")
    /// ]
    ///
    /// chatCoordinator.presentForm(title: "User Details", customFields: customFields) {
    ///     ...
    /// }
    /// ```
    public func presentForm(
        title: String,
        customFields: [FormCustomFieldType],
        onFinished: @escaping ([String: String]) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        LogManager.trace("Presenting \(title) form")
        
        let view = FormView(
            title: title,
            viewModel: FormViewModel(customFields: customFields),
            onFinished: { [weak self] customFields in
                self?.navigationController.dismiss(animated: true)
                onFinished(customFields)
        }, onCancel: {
            self.navigationController.dismiss(animated: true)
            
            onCancel?()
        })
        .environmentObject(style)
        .environmentObject(chatLocalization)

        let controller = UIHostingController(rootView: view)
        controller.isModalInPresentation = true
        navigationController.present(controller, animated: true)
    }
}

// MARK: - Navigation

extension DefaultChatCoordinator {
    
    func dismiss(animated: Bool) {
        navigationController.setViewControllers(appViewsStack, animated: animated)
    }
    
    func showCoordinator(threadIdToOpen: UUID? = nil) {
        let viewModel = DefaultChatCoordinatorViewModel(coordinator: self)
        viewModel.initializeViewModels(localization: chatLocalization)
        let view = DefaultChatCoordinatorView(viewModel: viewModel, threadIdToOpen: threadIdToOpen, localization: chatLocalization)
            .environmentObject(style)
            .environmentObject(chatLocalization)
        
        var stack = appViewsStack
        stack.append(UIHostingController(rootView: view))
        
        navigationController.setViewControllers(stack, animated: true)
    }
    
    func showThread(_ thread: ChatThread) {
        let view = DefaultChatView(viewModel: DefaultChatViewModel(thread: thread, coordinator: self, localization: chatLocalization))
            .environmentObject(style)
            .environmentObject(chatLocalization)

        navigationController.show(UIHostingController(rootView: view), sender: self)
    }
    
    func presentUpdateThreadNameAlert(completion: @escaping (String) -> Void) {
        let controller = UIAlertController(
            title: chatLocalization.alertUpdateThreadNameTitle,
            message: chatLocalization.alertUpdateThreadNameMessage,
            preferredStyle: .alert
        )
        controller.addTextField { textField in
            textField.placeholder = self.chatLocalization.alertUpdateThreadNamePlaceholder
        }
        
        let saveAction = UIAlertAction(title: chatLocalization.commonConfirm, style: .default) { _ in
            LogManager.trace("Confirm update thread name did tap")
            
            guard let title = (controller.textFields?[safe: 0] as? UITextField)?.text else {
                LogManager.error(CommonError.unableToParse("title", from: controller.textFields?[safe: 0]))
                return
            }
            
            completion(title)
        }
        
        let cancel = UIAlertAction(title: chatLocalization.commonCancel, style: .cancel)
        controller.addAction(saveAction)
        controller.addAction(cancel)
        
        navigationController.present(controller, animated: true)
    }
}

// MARK: - Methods

extension DefaultChatCoordinator {
 
    func showLocalNotificationForDifferentThreadMessage(_ message: Message) async throws {
        let content = UNMutableNotificationContent()
        content.title = message.senderInfo.fullName
        content.subtitle = message.getLocalizedContentOrFallbackText(basedOn: chatLocalization, useFallback: true) ?? ""
        content.userInfo = ["messageFromDifferentThread": true]
        content.sound = .default
        
        try await UNUserNotificationCenter
            .current()
            .add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}
