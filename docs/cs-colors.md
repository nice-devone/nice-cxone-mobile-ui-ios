# Case Study: Colors

The CXoneChatUI module allows you to customize the color scheme of the chat interface to match your brand or application's design guidelines. By default, the UI module uses a built-in color system that provides light and dark theme support with sensible defaults for backgrounds, content, borders, status, and brand colors.

### How to Update Colors

To override the default color system, you can provide your own color configuration using the `ChatStyle` class. This class accepts a `StyleColorsManager` instance, which lets you specify custom colors for both light and dark modes. You can define colors for various UI elements, such as backgrounds, text, borders, and status indicators.

#### Example

```swift
let customColors = StyleColorsManager(
    light: StyleColorsImpl(
        // Provide your custom Color values for light mode
    ),
    dark: StyleColorsImpl(
        // Provide your custom Color values for dark mode
    )
)
let chatStyle = ChatStyle(colorsManager: customColors)

class MyChatCoordinator: ChatCoordinator {

    // MARK: - Init
    
    init() {
        super.init(chatStyle: chatStyle)
    }

    ...
}
```

If you do not provide a custom color configuration, the UI module will automatically use its default color system for all chat views.
