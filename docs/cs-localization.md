# Case Study: Localization

The CXone Chat UI module provides full localization support, allowing you to customize all user-facing strings in the chat interface. This enables you to either translate the interface into different languages or customize the default English strings to match your brand voice.

> **Important:** The UI module currently includes built-in strings for English only. To support other languages, you must provide your own custom `CXOneChatUI.strings` file in your app bundle with translations for your target languages.

## How Localization Works

All strings shown by the chat UI are configured through a `ChatLocalization` instance that you pass to `ChatCoordinator(chatProvider:chatLocalization:)`. `ChatLocalization(bundle:tablename:provider:)` exposes two complementary override mechanisms:

- **`LocalizationStringProvider`** — a protocol you implement to override individual strings in code.
- **Custom strings file** — your own `CXOneChatUI.strings` file (optionally localized into multiple languages) in your app bundle.

Both mechanisms share the same override chain, and every string key not covered by your overrides falls back to the SDK's built-in English default.


## How String Resolution Works

Every string resolves through the following chain — the first match wins:

| Priority | Source | When to use |
|---|---|---|
| 1 (highest) | `LocalizationStringProvider` (programmatic) | Targeted code overrides — no files needed |
| 2 | Integrator's bundle (`CXOneChatUI.strings`) | Full localization via `.lproj` files |
| 3 (lowest) | SDK's own `Bundle.module` | Built-in English defaults |

The provider and bundle are set on `ChatLocalization`; `ChatCoordinator` applies them to the whole chat UI when `content(threadId:presentModally:onFinish:)` is called.


## Option 1: Programmatic Provider

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


## Option 2: Custom Strings File

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

   `ChatLocalization` will use the appropriate language based on the user's device settings.


---

## Deprecated Approaches

The following approaches are superseded by the options above.

### ⚠️ Deprecated — Direct Property Assignment

> **No longer has any effect.** The UI resolves every string through the provider and strings-file chain described above, so values assigned to a `ChatLocalization` property are never displayed. Move each override to a [`LocalizationStringProvider`](#option-1-programmatic-provider) or a [custom strings file](#option-2-custom-strings-file), keyed by the string key (e.g. `common.confirm`).

Older integrations assigned directly to a `lazy var` on a `ChatLocalization` instance:

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

The assigned values are only stored on the instance; replace them with the equivalent provider entries, e.g. `"common.confirm": "OK"`, `"chat_list.title": "My Chats"`, `"common.cancel": "Go Back"`.

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
