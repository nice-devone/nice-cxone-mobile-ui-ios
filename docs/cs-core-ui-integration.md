# Case Study: Core UI Integration

The CXone Chat UI module provides a complete, production-ready chat interface for iOS applications. It handles all aspects of the chat experience, from thread management to message composition and rich content rendering. The UI module is built on top of the CXone Chat SDK and leverages SwiftUI for modern, declarative interface design.

This case study demonstrates how to integrate the CXone Chat UI module into your iOS application using the `ChatCoordinator` class, which simplifies navigation and presentation of chat-related views.


## Prerequisites

Before integrating the UI module, ensure you have:

1. Added the CXone Chat UI package to your project
2. Configured and initialized the CXone Chat SDK
3. Properly set up your CXone brand and channel configuration


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
import CXoneChatUI
import SwiftUI
import UIKit

class MyChatCoordinator: ChatCoordinator {

    // MARK: - Init
    
    init() {
        // Configure localization
        var localization = ChatLocalization()
        localization.commonConfirm = "OK" // Override default strings
        
        // Configure styling
        let chatStyle = ChatStyle() // Use default or customize
        
        // Configure additional settings
        let chatConfiguration = ChatConfiguration()
        
        super.init(
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
class AppCoordinator {
    let chatCoordinator: MyChatCoordinator
    
    init() {
        chatCoordinator = MyChatCoordinator()
    }
}
```

### 3. Present the Chat Interface

There are two main ways to present the chat interface:

#### Option A: Using the `start()` Method (UIKit)

The `start()` method handles view controller creation and presentation:

```swift
// Present modally
chatCoordinator.start(
    threadId: nil, // Optional: specify a thread ID for deep linking
    in: navigationController,
    presentModally: true,
    onFinish: {
        // Called when the chat is dismissed
        print("Chat session ended")
    }
)

// Present in navigation stack (full screen)
chatCoordinator.start(
    threadId: nil,
    in: navigationController,
    presentModally: false,
    onFinish: {
        print("Chat session ended")
    }
)
```

#### Option B: Using the `content()` Method (SwiftUI)

For SwiftUI-based apps, use the `content()` method to get a SwiftUI view:

```swift
struct ContentView: View {
    let chatCoordinator: MyChatCoordinator
    
    var body: some View {
        NavigationView {
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

### 4. Handle Deep Linking (Optional)

To open a specific chat thread (e.g., from a push notification), pass the thread ID:

```swift
// Open a specific thread
let threadId = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")
chatCoordinator.start(
    threadId: threadId,
    in: navigationController,
    presentModally: true,
    onFinish: nil
)
```

> **Note:** The `threadId` parameter is only applicable for multi-threaded channel configurations. For single-threaded or live chat configurations, the SDK automatically manages the conversation thread.


## Complete Integration Example

Here's a complete example showing integration in a UIKit-based app:

```swift
import CXoneChatUI
import UIKit

class StoreCoordinator {
    
    // MARK: - Properties
    
    let chatCoordinator: MyChatCoordinator
    let navigationController: UINavigationController
    
    // MARK: - Init
    
    init(navigationController: UINavigationController) {
        self.chatCoordinator = MyChatCoordinator()
        self.navigationController = navigationController
    }
    
    // MARK: - Methods
    
    func openChat(modally: Bool = true, threadId: UUID? = nil) {
        chatCoordinator.start(
            threadId: threadId,
            in: navigationController,
            presentModally: modally
        ) { [weak self] in
            // Reset navigation bar appearance after chat closes
            self?.navigationController.navigationBar.defaultAppearance()
        }
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

2. **Configuration Before Presentation**: Update any configuration (custom fields, styling) before calling `start()` or `content()`.

3. **Handle onFinish Callback**: Always provide an `onFinish` callback to clean up UI state when the chat is dismissed.

4. **Deep Link Support**: If your app supports push notifications or deep linking, ensure you pass the correct `threadId` when opening specific conversations.

5. **Appearance Restoration**: If you customize the navigation bar or other UI elements for chat, restore them in the `onFinish` callback.


## Troubleshooting

### Chat doesn't appear

- Ensure the CXone Chat SDK is properly initialized before presenting the chat
- Verify your channel configuration in the CXone admin portal
- Check the console for any error messages

### Custom styling not applied

- Verify you're setting `chatStyle` before calling `start()` or `content()`
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
