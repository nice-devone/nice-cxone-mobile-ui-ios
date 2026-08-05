# Case Study: Accessibility String Overrides

The CXone Chat UI module exposes a flexible accessibility override system, allowing you to customize VoiceOver labels and hints, correct grammar for your brand voice, or provide full localization in languages beyond the SDK's built-in English.

> **Important:** The SDK ships with built-in accessibility strings for English only. To support other languages, you must provide your own `Accessibility.strings` file in your app bundle with translations for every key you want to localize.


## How It Works

The `ChatAccessibility` class is passed to `ChatCoordinator` before the chat UI is presented. Every time the SDK resolves an accessibility string, it walks the following chain and returns the first match:

| Priority | Source | When to use |
|---|---|---|
| 1 (highest) | `ChatAccessibility.provider` | Targeted overrides in code — no files needed |
| 2 | `ChatAccessibility.bundle` | Full localization via `.lproj/Accessibility.strings` |
| 3 (lowest) | SDK's own `Bundle.module` | Built-in English defaults |

String keys follow the pattern `section.subsection.element.attribute`, e.g.:

```
"chat_container.navigation_bar.button_close.hint" = "Double-tap to close the chat session";
"message_input.button_send.hint_enabled" = "Double-tap to send a message";
"thread_list.navigation_bar.button_new.hint" = "Double-tap to start a new conversation";
```

All available keys are listed in the SDK's `en.lproj/Accessibility.strings` file.


## Setup

Pass a `ChatAccessibility` instance when creating your coordinator:

```swift
let coordinator = ChatCoordinator(
    chatAccessibility: ChatAccessibility(
        bundle: .main,        // your bundle (for .lproj support)
        provider: myProvider  // optional: programmatic overrides
    )
)
```

Both parameters are optional. Note that `ChatAccessibility()` with no arguments uses `Bundle.main` as the bundle lookup source — meaning any keys present in the host app's own `Accessibility.strings` file will take precedence over the SDK defaults. This is intentional and useful when you want whole-app overrides without extra configuration, but be aware of it if unexpected values appear. Pass a bundle that contains no `Accessibility.strings` (or use a `provider` only) if you want the SDK defaults to be the true fallback.


## Option 1: Programmatic Overrides

Use this approach when you need to change a small number of specific strings in code, without adding any files to your project.

### 1. Implement `AccessibilityStringProvider`

```swift
import CXoneChatUI

final class BrandAccessibilityProvider: AccessibilityStringProvider {

    func accessibilityString(forKey key: String) -> String? {
        switch key {
        case "chat_container.navigation_bar.button_close.hint":
            return "Double-tap to end support session"
        case "message_input.button_send.hint_enabled":
            return "Double-tap to send"
        case "message_input.button_send.hint_disabled":
            return "Message is empty"
        default:
            return nil  // fall through to bundle or SDK default
        }
    }
}
```

### 2. Pass the provider to `ChatCoordinator`

```swift
class MyChatCoordinator: ChatCoordinator {

    init() {
        super.init(
            chatAccessibility: ChatAccessibility(provider: BrandAccessibilityProvider())
        )
    }
}
```

Only the keys you return a non-nil value for are overridden. All others fall through to the SDK's built-in strings automatically.


## Option 2: Bundle-Based Overrides (Recommended for Multiple Languages)

Use this approach when you want to localize accessibility strings into multiple languages or manage overrides as resource files rather than code.

### 1. Create `Accessibility.strings` in your app target

In Xcode:
- **File → New → File → Strings File**
- Name it `Accessibility.strings`
- Make sure it is added to your app target

### 2. Add your overrides

Copy only the keys you want to customize from the SDK's `en.lproj/Accessibility.strings`:

```
// en.lproj/Accessibility.strings (in your app target)

"chat_container.navigation_bar.button_close.hint" = "Double-tap to end support session";
"message_input.button_send.hint_enabled" = "Double-tap to send";
"thread_list.navigation_bar.button_new.hint" = "Double-tap to start a new chat";
```

You do not need to include every key — the SDK fills in anything you omit.

### 3. Configure `ChatCoordinator`

```swift
class MyChatCoordinator: ChatCoordinator {

    init() {
        super.init(
            chatAccessibility: ChatAccessibility(bundle: .main)
        )
    }
}
```


## Option 3: Full Multi-Language Support

Extend Option 2 to support multiple languages using standard `.lproj` localization.

### 1. Localize your `Accessibility.strings` file

In Xcode, select `Accessibility.strings` in the Project Navigator, open the **File Inspector**, and click **Localize...**. Add each language you want to support (e.g. English, Spanish, French).

### 2. Add translations for each language

**en.lproj/Accessibility.strings:**
```
"chat_container.navigation_bar.button_close.hint" = "Double-tap to end support session";
"message_input.button_send.hint_enabled" = "Double-tap to send";
```

**es.lproj/Accessibility.strings:**
```
"chat_container.navigation_bar.button_close.hint" = "Doble toque para cerrar";
"message_input.button_send.hint_enabled" = "Doble toque para enviar";
```

**fr.lproj/Accessibility.strings:**
```
"chat_container.navigation_bar.button_close.hint" = "Double-appui pour fermer";
"message_input.button_send.hint_enabled" = "Double-appui pour envoyer";
```

### 3. Configure `ChatCoordinator`

No change needed — `bundle: .main` already picks the correct `.lproj` based on the device locale automatically.

```swift
class MyChatCoordinator: ChatCoordinator {

    init() {
        super.init(
            chatAccessibility: ChatAccessibility(bundle: .main)
        )
    }
}
```


## Option 4: Combining Both Approaches

The provider and the bundle can be used together. The provider is always consulted first, so you can use it for dynamic or context-specific strings while relying on the bundle for everything else.

```swift
final class DynamicAccessibilityProvider: AccessibilityStringProvider {

    var agentName: String?

    func accessibilityString(forKey key: String) -> String? {
        // Personalize the close hint when we know the agent's name
        if key == "chat_container.navigation_bar.button_close.hint", let name = agentName {
            return "Double-tap to end your session with \(name)"
        }
        return nil
    }
}

class MyChatCoordinator: ChatCoordinator {

    private let a11yProvider = DynamicAccessibilityProvider()

    init() {
        super.init(
            chatAccessibility: ChatAccessibility(
                bundle: .main,
                provider: a11yProvider
            )
        )
    }

    func agentAssigned(_ name: String) {
        a11yProvider.agentName = name
    }
}
```


## Integration in a Separate Framework

If your integration code lives in a separate framework bundle (not the app target directly), pass that framework's bundle instead of `.main`:

```swift
class MyChatCoordinator: ChatCoordinator {

    init() {
        super.init(
            chatAccessibility: ChatAccessibility(bundle: Bundle(for: MyChatCoordinator.self))
        )
    }
}
```

Add `Accessibility.strings` to that framework's target, and Xcode will include it inside the framework bundle automatically.


## Troubleshooting

**My overridden strings are not appearing:**
- Verify that your `Accessibility.strings` file is added to the correct app/framework target (check **Target Membership** in the File Inspector).
- Confirm you are passing `bundle: .main` (or your framework bundle) to `ChatAccessibility`.
- Check that the string key matches exactly — keys are case-sensitive.
- Run a quick test by adding the key to your `provider` and returning a hardcoded string; if that works, the issue is in the strings file or bundle setup.

**Strings show the raw key instead of any value:**
- The key was not found in any source (provider, your bundle, or the SDK). Double-check the spelling against `en.lproj/Accessibility.strings` in the SDK.

**Wrong language is shown:**
- Verify the device/simulator language setting.
- Confirm the `.lproj` folder name matches the language code exactly (e.g. `fr.lproj`, not `fr-FR.lproj`, unless you want region-specific variants).
- Ensure the file is localized in Xcode's File Inspector and the translation is saved.

**Parameterized strings look wrong:**
- Some strings contain positional format specifiers such as `%1$@`. Your override must use the same specifiers in the same positions.
  ```
  // SDK default
  "thread_list.cell.label" = "%1$@, %2$@, %3$@";

  // Correct override — preserve the specifiers
  "thread_list.cell.label" = "Thread: %1$@, Agent: %2$@, Date: %3$@";
  ```
