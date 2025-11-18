# Case Study: Localization

The CXone Chat UI module provides full localization support, allowing you to customize all user-facing strings in the chat interface. This enables you to either translate the interface into different languages or customize the default English strings to match your brand voice.

> **Important:** The UI module currently includes built-in strings for English only. To support other languages, you must provide your own custom `CXOneChatUI.strings` file in your app bundle with translations for your target languages.

## How Localization Works

The `ChatLocalization` class manages all localized strings used throughout the chat UI. By default, it uses the built-in strings from the SDK's `CXOneChatUI.strings` file. However, you can override these strings by providing your own localization files in your app bundle.


## Customizing Localization Strings

### Option 1: Override Individual Strings

You can override specific strings programmatically when initializing the `ChatCoordinator`:

```swift
class MyChatCoordinator: ChatCoordinator {

    // MARK: - Init
    
    init() {
        var localization = ChatLocalization()
        localization.commonConfirm = "OK"  // Override default "Confirm"
        localization.chatListTitle = "My Chats"  // Override default "Conversations"
        localization.commonCancel = "Go Back"  // Override default "Cancel"
        super.init(chatLocalization: localization)
    }

    ...
}
```

### Option 2: Provide a Custom Strings File

For comprehensive localization or multiple language support, create your own `CXOneChatUI.strings` file in your app bundle.

#### Steps:

1. **Create a Strings File**

   In your Xcode project, create a new strings file named `CXOneChatUI.strings`:
   - File → New → File → Strings File
   - Name it `CXOneChatUI.strings`

2. **Add Localized Strings**

   Copy the keys from the SDK's default strings file and customize the values:

   ```
   // MARK: - Common
   "chatui_common_ok" = "OK";
   "chatui_common_cancel" = "Cancel";
   "chatui_common_confirm" = "Confirm";
   "chatui_common_attachments" = "Attachments";
   
   // MARK: - ChatList
   "chatui_chatList_title" = "My Conversations";
   "chatui_chatList_empty" = "No conversations yet";
   "chatui_chatList_newThread" = "Start New Chat";
   
   // Add other strings as needed...
   ```

3. **Initialize ChatLocalization with Your Bundle**

   When creating the `ChatCoordinator`, pass your app's bundle to the `ChatLocalization` initializer:

   ```swift
   class MyChatCoordinator: ChatCoordinator {

        // MARK: - Init
    
        init() {
            let localization = ChatLocalization(bundle: .main, tablename: "CXOneChatUI")
            super.init(chatLocalization: localization)
        }

        ...
    }
    ```

The `ChatLocalization` class will first look for strings in your app bundle. If a string is not found, it falls back to the SDK's default strings.


## Adding Multiple Languages

To support multiple languages:

1. **Localize Your Strings File**

   In Xcode, select your `CXOneChatUI.strings` file and click "Localize..." in the File Inspector. Add the languages you want to support (e.g., Spanish, French, German).

2. **Add Translations for Each Language**

   For each language, provide the translated strings:

   **en.lproj/CXOneChatUI.strings:**
   ```
   "chatui_common_ok" = "OK";
   "chatui_chatList_title" = "Conversations";
   ```

   **es.lproj/CXOneChatUI.strings:**
   ```
   "chatui_common_ok" = "Aceptar";
   "chatui_chatList_title" = "Conversaciones";
   ```
   ```

3. **The SDK Automatically Uses the Correct Language**

   The `ChatLocalization` class will automatically use the appropriate language based on the user's device settings.


## Troubleshooting

**My custom strings aren't appearing:**
- Verify that your `CXOneChatUI.strings` file is included in your app target
- Ensure you're passing `bundle: .main` to the `ChatLocalization` initializer
- Check that the string keys match exactly (they are case-sensitive)

**Strings show the key instead of the value:**
- This means the key wasn't found in either your bundle or the SDK's bundle
- Double-check the spelling of the key
- Ensure your strings file is properly formatted

**Wrong language is displayed:**
- Check your device's language settings
- Verify that you've created the correct `.lproj` folders for your supported languages
- Ensure the strings file is localized in Xcode's File Inspector

