![](https://img.shields.io/badge/min_iOS-15.0%2B-orange?style=flat) ![](https://img.shields.io/badge/Swift-5.7%2B-orange?style=flat) ![](https://img.shields.io/badge/Framework-SwiftUI-orange?style=flat) ![](https://img.shields.io/badge/Licence-MIT-orange?style=flat)

# CXoneChatUI

The CXoneChatUI module provides a default implementation of a Chat User Interface (UI) for the CXoneChat Sample application. This module is designed to handle all channel configurations (single- and multi-threaded or live chat), offering seamless integration into your iOS application.

> ⚠️ Warning: Customization of this module is not recommended as it may lead to incorrect usage of CXoneChatSDK or integration issues. Please note that no support will be provided for custom implementations that deviate from the standard integration patterns.


## Requirements

- iOS 15.0+
- Swift 5.7+


## Limitations

- The CXoneChatUI does not support phone landscape orientation
- Color customization is currently disabled to ensure accessibility standards and optimal user experience. This feature will be available in future releases.

## Modules

- [Utility](https://github.com/nice-devone/nice-cxone-mobile-guide-utility-ios)
- [Core](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios)
- UI
- [Sample](https://github.com/nice-devone/nice-cxone-mobile-sample-ios)


## Getting Started

To integrate the CXoneChatUI module into your project, follow these steps:

1. Open Xcode.
2. Navigate to `File > Swift Packages > Add Package Dependency...`
3. Enter the SDK repository URL to the search bar.
4. Select a **Dependency Rule** and specify where you want to save the project. Select your new Xcode project in  **Add to Project**.
5. Finish package import process with click on **Add Package**.

### Step 1: Import CXoneChatUI

Include the CXoneChatUI module in your project. You can do this by adding the following line to your project's dependencies:

```swift
import CXoneChatUI
```

### Step 2: Use ChatCoordinator

Initialize and use the `ChatCoordinator` to start the chat functionality. This coordinator simplifies the setup process and provides a quick way to integrate the chat UI into your application.
When initializing, you must specify the presentation style using the 'presentModally' parameter. This determines whether the chat interface appears as a modal overlay or in full-screen mode. The core functionality remains the same in both presentation styles, with each supporting native iOS gestures - swipe down to dismiss for modal presentation, or swipe from left edge to return to the previous screen in full-screen mode.


#### SwiftUI Integration

The SwiftUI implementation shows the chat via the method `public func content(threadId: UUID? = nil, presentModally: Bool, onFinish: (() -> Void)? = nil) -> some View`, which returns the SwiftUI `View` that can be embedded in a sheet or used as a navigation destination with the SwiftUI `NavigationLink`. Only the presentation mode is required; the rest of the parameters are optional.

```swift
...
var body: some View {
    VStack {
        ...

        Button(action: viewModel.openChat) {
            ...
        }

        ...
    }
    .sheet(isPresented: viewModel.isChatVisible) {
        viewModel.chatContentView()
    }
}
...
let chatCoordinator = ChatCoordinator()
...
func chatContentView() -> some View {
    ...
    
    return chatCoordinator.content(presentModally: true)
}
```

Additionally, this method supports custom scenarios through its optional parameters.

#### Deeplinking

The `content(presentModally:)` method supports deeplinking capabilities, allowing users to navigate directly to a specific thread in multi-threaded channel configurations.

> ⚠️ Important: Deeplinking is only relevant for multi-threaded channel configurations. For live chat or single-threaded configurations, deeplinking is unnecessary as users will always be directed to the single valid thread. 

```swift
...
chatCoordinator.content(deeplinkOption: .thread(threadIdOnExternalPlatform), presentModally: true)
```

#### Completion Handler

The `ChatCoordinator` provides a completion handler that is executed when the chat session ends. This allows you to perform any necessary cleanup or UI updates after the chat is dismissed.

In the sample application, the completion handler is used to reset the appearance of UI components. This ensures that the app's UI returns to its default state after the chat session.

```swift
chatCoordinator.content(modally: modally) { [weak self] in
    // Reset UI appearance after chat ends
    self?.navigationController.navigationBar.defaultAppearance()
    UISegmentedControl.defaultAppearance()
    UIAlertController.defaultAppearance()
}
```

#### UIKit Integration

The chat can be integrated with UIKit using the method `public func start(threadId: UUID? = nil, in parentViewController: UIViewController, presentModally: Bool, onFinish: (() -> Void)? = nil)`. This method requires a `UINavigationController` to control the navigation flow and presentation style..

```swift
let chatCoordinator = ChatCoordinator()
...
chatCoordinator.start(in: navigationController, presentModally: true)
```

Additionally, this method supports custom scenarios through its optional parameters.

#### Deeplinking

The `start(in:)` method supports deeplinking capabilities, allowing users to navigate directly to a specific thread in multi-threaded channel configurations.

> ⚠️ Important: Deeplinking is only relevant for multi-threaded channel configurations. For live chat or single-threaded configurations, deeplinking is unnecessary as users will always be directed to the single valid thread.

```swift
...
chatCoordinator.start(deeplinkOption: .thread(threadIdOnExternalPlatform), in: navigationController, presentModally: true)
```

#### Completion Handler

The `ChatCoordinator` provides a completion handler that is executed when the chat session ends. This allows you to perform any necessary cleanup or UI updates after the chat is dismissed.

In the sample application, the completion handler is used to reset the appearance of UI components. This ensures that the app's UI returns to its default state after the chat session.

```swift
chatCoordinator.start(with: deeplinkOption, modally: modally, in: navigationController) { [weak self] in
    // Reset UI appearance after chat ends
    self?.navigationController.navigationBar.defaultAppearance()
    UISegmentedControl.defaultAppearance()
    UIAlertController.defaultAppearance()
}
```


## Features

### Single-Threaded Channel Configuration

The CXoneChatUI module seamlessly supports single-threaded channel configurations. This allows users to engage in one-on-one conversations with ease.

### Multi-Threaded Channel Configuration

For scenarios involving multiple threads or group conversations, the CXoneChatUI module provides a smooth experience. Users can navigate and participate in multi-threaded discussions effortlessly.

### LiveChat Channel Configuration

The CXoneChatUI module offers robust live chat functionalities, enabling real-time communication between agents and mobile customers.

### Voice Recording

The CXoneChatUI module supports voice recording capabilities, allowing users to send audio messages during their chat sessions. This feature enhances communication and provides an alternative way to convey information.

> ⚠️ Warning: The UI module is using M4A format for voice recording. It is necessary to specify "audio/x-m4a" or "audio/\*" mimeType in the brand Settings to enable voice recording.

## Customization

The UI module supports 

> ⚠️ Warning: Color customization is currently disabled to ensure accessibility standards and optimal user experience. This feature will be available in future releases.

### Localization

The UI module comes with default English localization strings. However, you can customize these strings by providing your own `chatLocalization` parameter when initializing the `ChatCoordinator`.

```swift
let chatCoordinator: ChatCoordinator
...
let localization = ChatLocalization()
// Override `commonConfirm`
localization.commonConfirm = "👌"
        
self.chatCoordinator = ChatCoordinator(chatLocalization: localization)
```

### Additional Configuration

The `ChatCoordinator` lets you provide extra information to chat sessions through its `ChatConfiguration` parameter. This gives you two key benefits:
Personalization: Customer service agents can see relevant details about your users (like account level or history) without asking for it
System integration: You can connect chat sessions with your other systems by passing reference IDs or metadata
This feature passes along information your app already has without requiring users to enter it themselves. For information that users need to provide directly, use the pre-chat survey instead (see `cs-custom-fields.md`).

The `ChatConfiguration` struct provides two attributes:

- `additionalCustomerCustomFields`: Custom fields related to the customer (e.g., user ID, account type).
- `additionalContactCustomFields`: Custom fields related to the contact or conversation (e.g., case number, topic).

```swift
let configuration = ChatConfiguration(
    additionalCustomerCustomFields: [
        "customerId": "12345",
        "membershipLevel": "gold"
    ],
    additionalContactCustomFields: [
        "caseId": "A-98765",
        "topic": "Order Support"
    ]
)

let chatCoordinator = ChatCoordinator(chatConfiguration: configuration)
```
