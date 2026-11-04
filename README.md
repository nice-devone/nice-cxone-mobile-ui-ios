![](https://img.shields.io/badge/min_iOS-16.0%2B-orange?style=flat) ![](https://img.shields.io/badge/Swift-6.0%2B-orange?style=flat) ![](https://img.shields.io/badge/Framework-SwiftUI-orange?style=flat) ![](https://img.shields.io/badge/Licence-NICE-orange?style=flat)

# CXoneChatUI

The CXoneChatUI module provides a default implementation of a Chat User Interface (UI) for the CXoneChat Sample application. This module is designed to handle all channel configurations (single- and multi-threaded or live chat), offering seamless integration into your iOS application.

> ⚠️ Warning: Customization of this module is not recommended as it may lead to incorrect usage of CXoneChatSDK or integration issues. Please note that no support will be provided for custom implementations that deviate from the standard integration patterns.


## Requirements

- iOS 16.0+
- Swift 6.0+ (Xcode 16 or later)


## Modules

- [Utility](https://github.com/nice-devone/nice-cxone-mobile-guide-utility-ios)
- [Core](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios)
- UI
- [Sample](https://github.com/nice-devone/nice-cxone-mobile-sample-ios)


## Getting Started

To integrate the CXoneChatUI module into your project, follow these steps:

1. Open Xcode.
2. Navigate to `File > Add Package Dependencies...`
3. Enter the SDK repository URL to the search bar.
4. Select a **Dependency Rule** and specify where you want to save the project. Select your new Xcode project in  **Add to Project**.
5. Finish package import process with click on **Add Package**.

### Step 1: Import CXoneChatUI

Include the CXoneChatUI module in your project. You can do this by adding the following line to your project's dependencies:

```swift
import CXoneChatUI
```

### Step 2: Construct the SDK provider and hand it to `ChatCoordinator`

`ChatCoordinator` requires a `ChatProvider` (your `CXoneChat` instance) so it can drive the SDK on your behalf. Construct **one** `CXoneChat()` at app start, hold the reference for the lifetime of the chat experience, and pass it into every `ChatCoordinator` you create.

```swift
import CXoneChatSDK
import CXoneChatUI

let chatProvider = CXoneChat()                          // hold this for app lifetime
let chatCoordinator = ChatCoordinator(chatProvider: chatProvider)
```

> 📖 **Upgrading from an earlier version that used `CXoneChat.shared` + `CXoneChatDelegate`?** The SDK [Migration Guide](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/migration-from-singleton.md) walks through every breaking change, including a delegate-method → `ChatEvent`-case mapping table, `signOut()` semantics, and `@MainActor` rules. UI-module integrators are affected too — the snippets below all assume the singleton-free pattern.

When initializing, you must specify the presentation style using the 'presentModally' parameter. This determines whether the chat interface appears as a modal overlay or in full-screen mode. The core functionality remains the same in both presentation styles, with each supporting native iOS gestures - swipe down to dismiss for modal presentation, or swipe from left edge to return to the previous screen in full-screen mode.


#### SwiftUI Integration

The SwiftUI implementation shows the chat via the method `public func content(threadId: String? = nil, presentModally: Bool, onFinish: (() -> Void)? = nil) -> some View`, which returns the SwiftUI `View` that can be embedded in a sheet or used as a navigation destination with the SwiftUI `NavigationLink`. Only the presentation mode is required; the rest of the parameters are optional.

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
    .sheet(isPresented: $viewModel.isChatVisible) {
        viewModel.chatContentView()
    }
}
...
let chatCoordinator = ChatCoordinator(chatProvider: chatProvider)
@Published var isChatVisible = false
...
func chatContentView() -> some View {
    ...
    
    // The chat never dismisses its own host — close the sheet when it finishes
    return chatCoordinator.content(presentModally: true) { [weak self] in
        self?.isChatVisible = false
    }
}
```

Additionally, this method supports custom scenarios through its optional parameters.

#### Deeplinking

The `content(threadId:presentModally:onFinish:)` method supports deeplinking capabilities, allowing users to navigate directly to a specific thread in multi-threaded channel configurations.

> ⚠️ Important: Deeplinking is only relevant for multi-threaded channel configurations. For live chat or single-threaded configurations, deeplinking is unnecessary as users will always be directed to the single valid thread. 

```swift
...
chatCoordinator.content(threadId: threadIdOnExternalPlatform, presentModally: true)
```

#### Completion Handler

The `ChatCoordinator` provides a completion handler that is executed when the chat session ends. This allows you to perform any necessary cleanup or UI updates after the chat is dismissed.

The chat never dismisses its own host, so use the completion handler to close it — the sample application passes its presenter's `dismiss` here.

```swift
// In a SwiftUI view that presents the chat with `.sheet(isPresented: $isChatPresented)`
chatCoordinator.content(threadId: nil, presentModally: true) {
    // Close the chat and restore any app state changed while it was shown
    isChatPresented = false
}
```

#### Explicit OAuth Session Expiry

Set `ChatCoordinator.onSessionExpired` before calling `content(...)` to be notified when an explicit OAuth (PKCE) session's refresh-grant recovery fails during connect (`CXoneChatError.invalidRefreshToken`) and no further automatic recovery is possible. It is called instead of the generic connection-error alert, so you can route the customer to a new authorization flow rather than let them retry a rejected credential. A refresh-grant rejection during a message send surfaces as a regular send error, not through this handler. If you don't set it, the connection-error alert is shown as before.

```swift
chatCoordinator.onSessionExpired = { [weak self] in
    self?.startNewAuthorizationFlow()
}
```

#### UIKit Integration

There is no UIKit-specific entry point — host the SwiftUI view returned by `content(threadId:presentModally:onFinish:)` in a `UIHostingController`. The chat does not dismiss its own host, so dismiss it from the `onFinish` closure. `ChatCoordinator` is `@MainActor`, so call it from the main actor (for example, from a view controller).

```swift
let chatCoordinator = ChatCoordinator(chatProvider: chatProvider)
...
func openChat(threadId: String? = nil) {
    let content = chatCoordinator.content(threadId: threadId, presentModally: true) { [weak self] in
        // Chat session ended - dismiss the hosting controller
        self?.dismiss(animated: true)
    }

    present(UIHostingController(rootView: content), animated: true)
}
```

> ⚠️ Important: With `presentModally: true` the chat provides its own navigation stack and close button. With `presentModally: false` the chat expects to be pushed onto an existing SwiftUI `NavigationStack`, so prefer modal presentation when hosting the chat from UIKit.

Deeplinking works the same way as in SwiftUI — pass `threadId` to `content(threadId:presentModally:onFinish:)`.


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

The UI module supports color customization, localization, and additional chat configuration.

### Colors

You can customize the color scheme of the chat interface to match your brand. See [CS: Colors](docs/cs-colors.md) for details.

### Localization

The UI module comes with default English localization strings. You can override them by passing a `ChatLocalization` built with your own `LocalizationStringProvider` (or a custom strings file) when initializing the `ChatCoordinator`.

```swift
struct MyStrings: LocalizationStringProvider {
    func localizationString(forKey key: String) -> String? {
        switch key {
        case "common.confirm":
            return "👌"
        default:
            return nil // Fall back to the SDK default
        }
    }
}

let localization = ChatLocalization(provider: MyStrings())

self.chatCoordinator = ChatCoordinator(chatProvider: chatProvider, chatLocalization: localization)
```

See [CS: Localization](docs/cs-localization.md) for the custom strings file option and multiple languages. Every key and its default value is listed in [`CXOneChatUI.strings`](Sources/Resources/en.lproj/CXOneChatUI.strings). Assigning to `ChatLocalization` properties directly (e.g. `localization.commonConfirm = "OK"`) no longer changes what the UI displays.

### Additional Configuration

The `ChatCoordinator` lets you provide extra information to chat sessions through its `ChatConfiguration` parameter. This gives you two key benefits:

- **Personalization**: Customer service agents can see relevant details about your users (like account level or history) without asking for it.
- **System integration**: You can connect chat sessions with your other systems by passing reference IDs or metadata.

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

let chatCoordinator = ChatCoordinator(chatProvider: chatProvider, chatConfiguration: configuration)
```
