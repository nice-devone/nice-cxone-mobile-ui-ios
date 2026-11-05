# Case Study: Core UI Integration

The CXone Chat UI module provides a complete, production-ready chat interface for iOS applications. It handles all aspects of the chat experience, from thread management to message composition and rich content rendering. The UI module is built on top of the CXone Chat SDK and leverages SwiftUI for modern, declarative interface design.

This case study demonstrates how to integrate the CXone Chat UI module into your iOS application using the `ChatCoordinator` class, which simplifies navigation and presentation of chat-related views.


## Prerequisites

Before integrating the UI module, ensure you have:

1. Added the CXone Chat UI package to your project
2. Constructed and held a `CXoneChat` instance (`let chatProvider = CXoneChat()`) for the lifetime of your chat experience — the UI module is built on top of the SDK and needs a `ChatProvider` to drive it. See the [SDK README](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/README.md) for the lifecycle rules.
3. Properly set up your CXone brand and channel configuration

> 📖 **Upgrading from an earlier version that used `CXoneChat.shared` + `CXoneChatDelegate`?** See the [SDK Migration Guide](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/migration-from-singleton.md) — UI integrators are affected too, because `ChatCoordinator` now requires a `chatProvider:` parameter.


## Integration Approach

The recommended approach for integrating the chat UI is to create a custom coordinator that subclasses `ChatCoordinator`. This provides:

- **Centralized Configuration**: All chat styling, localization, and configuration in one place
- **Customization**: Easy override of default behaviors and settings
- **Reusability**: A single coordinator instance can be reused throughout your app
- **Deep Linking**: Support for opening specific threads via thread IDs


## Step-by-Step Integration

### 1. Create a Custom Chat Coordinator

Create a subclass of `ChatCoordinator` to encapsulate your chat configuration:

```swift
import CXoneChatSDK
import CXoneChatUI
import SwiftUI
import UIKit

class MyChatCoordinator: ChatCoordinator {

    // MARK: - Init

    init(chatProvider: ChatProvider) {
        // Configure localization
        // Override default strings with a `LocalizationStringProvider` —
        // `BrandLocalizationProvider` is the example from CS: Localization
        let localization = ChatLocalization(provider: BrandLocalizationProvider())

        // Configure styling
        let chatStyle = ChatStyle() // Use default or customize

        // Configure additional settings
        let chatConfiguration = ChatConfiguration()

        super.init(
            chatProvider: chatProvider,
            chatStyle: chatStyle,
            chatLocalization: localization,
            chatConfiguration: chatConfiguration
        )
    }
}
```

### 2. Initialize the Coordinator

Create an instance of your custom coordinator, typically in your app coordinator or main view controller:

```swift
@MainActor
class AppCoordinator {
    let chatProvider: ChatProvider
    let chatCoordinator: MyChatCoordinator

    init() {
        let chatProvider = CXoneChat()
        self.chatProvider = chatProvider
        self.chatCoordinator = MyChatCoordinator(chatProvider: chatProvider)
    }
}
```

> Warning: If you are using OAuth (implicit flow), hand the SDK a connection token before connecting — `chatProvider.customer.setConnectionToken(_:expiresAt:)` — and register a token-delegate listener via `chatProvider.customer.setTokenDelegateListener(_:)` so the SDK refreshes the token silently before it expires; no UI-level callback is involved. Without a listener, an expired or rejected token surfaces as `CXoneChatError.invalidAccessToken` from the failing call — obtain a fresh token, set it again, and retry. See the [OAuth case study](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/cs-oauth.md) for the full flow.

If you are using explicit OAuth (PKCE), set `chatCoordinator.onSessionExpired` before presenting the chat. It is called instead of the generic connection-error alert when refresh-grant recovery fails during connect (`CXoneChatError.invalidRefreshToken`), so you can route the customer to a new authorization flow:

```swift
chatCoordinator.onSessionExpired = { [weak self] in
    self?.startNewAuthorizationFlow()
}
```


### 3. Present the Chat Interface

Use the `content(threadId:presentModally:onFinish:)` method to get the SwiftUI view for the chat. The chat does not dismiss itself, so hide or dismiss it from the `onFinish` callback.

#### Option A: SwiftUI

```swift
struct ContentView: View {
    let chatCoordinator: MyChatCoordinator

    @State private var showingChat = false
    
    var body: some View {
        NavigationStack {
            Button("Open Chat") {
                showingChat = true
            }
            .sheet(isPresented: $showingChat) {
                chatCoordinator.content(
                    threadId: nil,
                    presentModally: true,
                    onFinish: {
                        showingChat = false
                    }
                )
            }
        }
    }
}
```

With `presentModally: false`, the chat expects to be pushed onto an existing `NavigationStack` (for example, as a `navigationDestination`) and is closed with the system back navigation.

#### Option B: UIKit

Host the same view in a `UIHostingController` and present it modally:

```swift
// Inside a UIViewController
let content = chatCoordinator.content(
    threadId: nil, // Optional: specify a thread ID for deep linking
    presentModally: true,
    onFinish: { [weak self] in
        // Called when the chat is dismissed
        self?.dismiss(animated: true)
    }
)

present(UIHostingController(rootView: content), animated: true)
```

### 4. Handle Deep Linking (Optional)

To open a specific chat thread (e.g., from a push notification), pass the thread ID:

```swift
// Open a specific thread
chatCoordinator.content(
    threadId: "123e4567-e89b-12d3-a456-426614174000",
    presentModally: true,
    onFinish: nil
)
```

> **Note:** The `threadId` parameter is only applicable for multi-threaded channel configurations. For single-threaded or live chat configurations, the SDK automatically manages the conversation thread.


## Complete Integration Example

Here's a complete example showing integration in a UIKit-based app:

```swift
import CXoneChatSDK
import CXoneChatUI
import SwiftUI
import UIKit

@MainActor
class StoreCoordinator {

    // MARK: - Properties

    let chatProvider: ChatProvider
    let chatCoordinator: MyChatCoordinator
    let navigationController: UINavigationController

    // MARK: - Init

    init(navigationController: UINavigationController) {
        let chatProvider = CXoneChat()
        self.chatProvider = chatProvider
        self.chatCoordinator = MyChatCoordinator(chatProvider: chatProvider)
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    
    func openChat(threadId: String? = nil) {
        let content = chatCoordinator.content(
            threadId: threadId,
            presentModally: true
        ) { [weak self] in
            // Dismiss the hosting controller after chat closes
            self?.navigationController.dismiss(animated: true)
        }

        navigationController.present(UIHostingController(rootView: content), animated: true)
    }
}
```


## Advanced Configuration

### Providing Additional Custom Fields

You can dynamically provide custom fields before starting the chat.  See [CS: Chat Configuration](cs-chat-configuration.md) for more details.

## Customization Options

The `ChatCoordinator` provides several customization options through its initialization parameters:

### Chat Style

Control the visual appearance of the chat interface. See [CS: Colors](cs-colors.md) for detailed color customization.

### Chat Localization

Customize or translate all user-facing strings. See [CS: Localization](cs-localization.md) for complete localization options.

### Logging

Configure logging to help with debugging and monitoring. See [CS: Logging](cs-logging.md) for comprehensive logging options.

## Best Practices

1. **Single Coordinator Instance**: Create one coordinator instance and reuse it throughout your app to maintain consistent configuration.

2. **Configuration Before Presentation**: Update any configuration (custom fields, styling) before calling `content()`.

3. **Handle onFinish Callback**: Always provide an `onFinish` callback to clean up UI state when the chat is dismissed.

4. **Deep Link Support**: If your app supports push notifications or deep linking, ensure you pass the correct `threadId` when opening specific conversations.

5. **Appearance Restoration**: If you customize the navigation bar or other UI elements for chat, restore them in the `onFinish` callback.


## Troubleshooting

### Chat doesn't appear

- Ensure the CXone Chat SDK is properly initialized before presenting the chat
- Verify your channel configuration in the CXone admin portal
- Check the console for any error messages

### Custom styling not applied

- Verify you're setting `chatStyle` before calling `content()`
- Ensure your `StyleColorsManager` is properly configured
- Check that colors are being applied to both light and dark modes
- See the [CS: Colors](cs-colors.md) for detailed troubleshooting based on the integration details

### Localization strings not showing

- Verify your `ChatLocalization` configuration
- Ensure custom strings files are included in your app bundle
- See the [CS: Localization](cs-localization.md) for detailed troubleshooting based on the integration details

### Custom fields not appearing to agents

- Verify the field keys match those configured in your CXone brand settings
- Ensure you're setting the configuration before starting the chat
- Check the [CS: Chat Configuration](cs-chat-configuration.md) for detailed troubleshooting based on the integration details
