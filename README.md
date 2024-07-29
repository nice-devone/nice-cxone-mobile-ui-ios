![](https://img.shields.io/badge/min_iOS-14.0%2B-orange?style=flat) ![](https://img.shields.io/badge/Framework-SwiftUI-orange?style=flat) ![](https://img.shields.io/badge/Licence-MIT-orange?style=flat)

# CXoneChatUI

The CXoneChatUI module provides a default implementation of a Chat User Interface (UI) for the CXoneChat Sample application. This module is designed to handle both single- and multi-threaded channel configurations, offering seamless integration into your iOS application.


## Requirements

- iOS 15.0+
- Swift 5+


## Installation

### Swift Package Manager

You can use Swift Package Manager to add CXoneChatUI to your Xcode project. Simply follow these steps:

1. Open your Xcode.
2. Navigate to `File > Swift Packages > Add Package Dependency...`
3. Enter the SDK repository URL https://github.com/nice-devone/nice-cxone-mobile-ui-ios in the search bar.
4. Select the version or branch you want to use.


## Getting Started

To integrate the CXoneChatUI module into your project, follow these steps:

### Step 1: Import CXoneChatUI

Include the CXoneChatUI module in your project. You can do this by adding the following line to your project's dependencies:

```swift
import CXoneChatUI
```

### Step 2: Use DefaultChatCoordinator

Initialize and use the `DefaultChatCoordinator` to start the chat functionality. This coordinator simplifies the setup process and provides a quick way to integrate the chat UI into your application.

```swift
let chatCoordinator = DefaultChatCoordinator()
// (optional) Specify Chat Style of colors or brand logo in the chat navigation bar
chatCoordinator.style = ChatStyle(backgroundColor: .accentColor)
...
chatCoordinator.start()
```

Also, it is possible to setup deeplinking for the Chat to enter specifinc thread for multi-threaded channel configuration.
```swift
chatCoordinator.start(deeplinkOption: .thread(threadIdOnExternalPlatform))
```


## Features

### Single-Threaded Channel Configuration

The CXoneChatUI module seamlessly supports single-threaded channel configurations. This allows users to engage in one-on-one conversations with ease.

### Multi-Threaded Channel Configuration

For scenarios involving multiple threads or group conversations, the CXoneChatUI module provides a smooth experience. Users can navigate and participate in multi-threaded discussions effortlessly.

### LiveChat Channel Configuration

The CXoneChatUI module offers robust live chat functionalities, enabling real-time communication between agents and mobile customers.


## Customization

The UI module currently allows to customize online colors and set the brand logo in the navigation bar. By default, the color scheme is predefined and it is not necessary to take care of that.


## License

CXoneChatUI is released under the [MIT License](LICENSE.md). Feel free to use, modify, and distribute it according to the terms of this license.
