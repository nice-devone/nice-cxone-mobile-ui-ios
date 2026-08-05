# Case Study: Localization

The CXone Chat UI module provides full localization support, allowing you to customize all user-facing strings in the chat interface. This enables you to either translate the interface into different languages or customize the default English strings to match your brand voice.

> **Important:** The UI module currently includes built-in strings for English only. To support other languages, you must provide your own custom `CXOneChatUI.strings` file in your app bundle with translations for your target languages.

## How Localization Works

The SDK exposes two complementary mechanisms for accessing and overriding localized strings:

- **`L10n` enum** — a SwiftGen-generated static enum that provides type-safe access to every string. This is the recommended approach for new integrations.
- **`ChatLocalization` class** — the original instance-based API, still fully supported. Useful when you need the `@EnvironmentObject` injection model or direct property assignment.

Both mechanisms share the same underlying override chain, so whichever you use, the same integrator-supplied strings are resolved.


## How String Resolution Works

Every string resolves through the following chain — the first match wins:

| Priority | Source | When to use |
|---|---|---|
| 1 (highest) | `LocalizationStringProvider` (programmatic) | Targeted code overrides — no files needed |
| 2 | Integrator's bundle (`CXOneChatUI.strings`) | Full localization via `.lproj` files |
| 3 (lowest) | SDK's own `Bundle.module` | Built-in English defaults |

The provider and bundle are set on `ChatLocalization` and automatically propagated to the `L10n` static enum by `ChatCoordinator` before the chat UI appears.


## Option 1: `L10n` Enum (Recommended)

The `L10n` enum is generated from `CXOneChatUI.strings` by SwiftGen and provides type-safe static access to every string — the same pattern used for accessibility strings (`A11y`).

```swift
L10n.Common.ok                         // "Ok"
L10n.Common.cancel                     // "Cancel"
L10n.ChatList.title                    // "Conversations"
L10n.Alert.Disconnect.confirm          // "Disconnect"
L10n.Alert.InvalidFileSize.message(5)  // "Unable to upload... greater than 5 MB"
L10n.LiveChat.Queue.title(3)           // "You are number 3 in line"
```

To override strings, use one of the approaches below and pass a configured `ChatLocalization` to your `ChatCoordinator`. The `L10n` enum picks up the overrides automatically.


## Option 2: Programmatic Provider

Use `LocalizationStringProvider` when you need to override strings in code without creating a `.strings` file, or when strings need to be resolved dynamically at runtime.

#### 1. Implement `LocalizationStringProvider`

Return a custom string for any key you want to override, or `nil` to fall through to the bundle or SDK default.

```swift
import CXoneChatUI

final class BrandLocalizationProvider: LocalizationStringProvider {

    func localizationString(forKey key: String) -> String? {
        switch key {
        case "common.confirm":
            return "Done"
        case "chat_list.title":
            return "Support"
        case "chat.menu_option.end_conversation":
            return "End session"
        default:
            return nil
        }
    }
}
```

#### 2. Pass the provider to `ChatLocalization`

```swift
class MyChatCoordinator: ChatCoordinator {

    // MARK: - Init

    init(chatProvider: ChatProvider) {
        let localization = ChatLocalization(provider: BrandLocalizationProvider())
        super.init(chatProvider: chatProvider, chatLocalization: localization)
    }
}
```

The provider and a bundle can be combined — the provider is always consulted first:

```swift
let localization = ChatLocalization(
    bundle: .main,          // .lproj fallback for languages not covered by the provider
    provider: myProvider    // takes priority for any key it returns non-nil
)
```


## Option 3: Custom Strings File

For comprehensive localization or multiple language support, create your own `CXOneChatUI.strings` file in your app bundle.

#### Steps

1. **Create a Strings File**

   In your Xcode project, create a new strings file named `CXOneChatUI.strings`:
   - File → New → File → Strings File
   - Name it `CXOneChatUI.strings`

2. **Add Localized Strings**

   Use the dot-notation keys from the SDK's strings file and customize the values:

   ```
   // MARK: - Common
   "common.ok" = "OK";
   "common.cancel" = "Cancel";
   "common.confirm" = "Confirm";
   "common.attachments" = "Attachments";

   // MARK: - ChatList
   "chat_list.title" = "My Conversations";
   "chat_list.empty" = "No conversations yet";
   "chat_list.new_thread" = "Start New Chat";

   // Add other keys as needed...
   ```

3. **Initialize ChatLocalization with Your Bundle**

   ```swift
   class MyChatCoordinator: ChatCoordinator {

       // MARK: - Init

       init(chatProvider: ChatProvider) {
           let localization = ChatLocalization(bundle: .main, tablename: "CXOneChatUI")
           super.init(chatProvider: chatProvider, chatLocalization: localization)
       }
   }
   ```

The SDK looks for strings in your app bundle first, then falls back to its built-in defaults.


## Adding Multiple Languages

To support multiple languages:

1. **Localize Your Strings File**

   In Xcode, select your `CXOneChatUI.strings` file and click "Localize..." in the File Inspector. Add the languages you want to support (e.g., Spanish, French, German).

2. **Add Translations for Each Language**

   **en.lproj/CXOneChatUI.strings:**
   ```
   "common.ok" = "OK";
   "chat_list.title" = "Conversations";
   ```

   **es.lproj/CXOneChatUI.strings:**
   ```
   "common.ok" = "Aceptar";
   "chat_list.title" = "Conversaciones";
   ```

3. **The SDK Automatically Uses the Correct Language**

   `ChatLocalization` (and through it, `L10n`) will use the appropriate language based on the user's device settings.


---

## Deprecated Approaches

The following approaches still work and remain supported, but are superseded by the options above.

### ⚠️ Deprecated — Direct Property Assignment

You can assign directly to any `lazy var` on a `ChatLocalization` instance. This is still valid for quick one-off overrides but bypasses the type-safe `L10n` enum and does not support multi-language files.

```swift
class MyChatCoordinator: ChatCoordinator {

    init() {
        var localization = ChatLocalization()
        localization.commonConfirm = "OK"       // Override default "Confirm"
        localization.chatListTitle = "My Chats" // Override default "Conversations"
        localization.commonCancel = "Go Back"   // Override default "Cancel"
        super.init(chatLocalization: localization)
    }
}
```

**Limitation:** Values assigned this way are cached on the instance. They do not flow through the `L10n` enum's override chain and will not appear when accessing `L10n.X.y` directly.

### ⚠️ Deprecated — Old Key Format (`chatui_` prefix)

Prior to the SwiftGen migration, string keys used a flat `chatui_xxx_yyy` format. These keys no longer exist in the SDK's built-in strings file. If you have an existing `CXOneChatUI.strings` override file using old keys, migrate to the new dot-notation format:

| Old key | New key |
|---|---|
| `chatui_common_ok` | `common.ok` |
| `chatui_common_cancel` | `common.cancel` |
| `chatui_chatList_title` | `chat_list.title` |
| `chatui_chat_menuOption_endConversation` | `chat.menu_option.end_conversation` |
| `chatui_liveChat_offline_title` | `live_chat.offline.title` |

The full key reference is in `Sources/Resources/en.lproj/CXOneChatUI.strings`.


## Troubleshooting

**My custom strings aren't appearing:**
- Verify that your `CXOneChatUI.strings` file is included in your app target
- Ensure you're passing `bundle: .main` to the `ChatLocalization` initializer
- Check that the string keys use the new dot-notation format (not the old `chatui_` prefix)
- Keys are case-sensitive

**Strings show the key instead of the value:**
- This means the key wasn't found in either your bundle or the SDK's bundle
- Double-check the key spelling against `Sources/Resources/en.lproj/CXOneChatUI.strings`
- Ensure your strings file is properly formatted

**Wrong language is displayed:**
- Check your device's language settings
- Verify that you've created the correct `.lproj` folders for your supported languages
- Ensure the strings file is localized in Xcode's File Inspector
