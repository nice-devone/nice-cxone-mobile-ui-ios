<a name="Unreleased"></a>
# [Unreleased]


<a name="4.1.0"></a>
# [4.1.0] - 2026-11-04

## Features
- Satisfaction Survey plugin events are now presented by the standard UI in a blocking in-app WebView with restricted navigation and explicit dismissal. In multithread channels, a survey for a conversation the customer is not viewing is held until they open that conversation, and a local notification that opens it is scheduled. Its title can be localized with the `chat.satisfaction_survey.notification_title` key, exposed as `ChatLocalization.chatSatisfactionSurveyNotificationTitle`.
- Tapping anywhere in the conversation now dismisses the keyboard, in addition to the existing swipe-to-dismiss gesture. Tapping inside the message input bar keeps the keyboard up.
- The thread list's Current/Archived segmented control no longer stretches to the full screen width in landscape.
- Added `ChatCoordinator.onSessionExpired`, called instead of the generic connection-error alert when an explicit OAuth (PKCE) session's refresh-grant recovery fails during connect (`CXoneChatError.invalidRefreshToken`) and no further automatic recovery is possible. Integrators should set it before calling `content(...)` to route the customer to a new authorization flow rather than let them retry a rejected credential against the same connection-error alert. A refresh-grant rejection during a message send surfaces as a regular send error, not through this handler. If it is not set, the connection-error alert is shown as before.
- The live chat position-in-queue view and the loading overlay before it are no longer shown while the conversation is handled by a bot (`ChatThread.contactHandler` is `.cognigy` or an unrecognized handler). They return as usual once the bot hands the conversation over to CXone routing.

## Changes
- **Migration required:** The attachments overview's accessibility identifiers and `Accessibility.strings` keys now use the `attachment_gallery_view.*` prefix instead of `attachments_view.*` (e.g. `attachments_view.title` → `attachment_gallery_view.title`, `attachments_view.button_select` → `attachment_gallery_view.button_select`), matching the view's name. UI tests referencing the old identifiers, and custom `Accessibility.strings` files or a `ChatAccessibility.provider` keyed on the old strings, need the new prefix; an override keyed on the old prefix no longer applies. See [Accessibility customization](docs/cs-accessibility.md).
- The closed/archived thread banner's divider now spans the full width of the screen in landscape instead of stopping at the safe-area inset, with the banner's background filling the same width, and adjusted spacing around it. The decorative archive icon next to the status text is now hidden from VoiceOver.
- Removed the targeted alert previously shown when a connection attempt failed with `CXoneChatError.featureUnavailable(_:)`. That case is now deprecated and never thrown by the SDK; a failed connection surfaces through the existing generic disconnect alert instead. `ChatLocalization.alertFeatureUnavailableMessage` is deprecated for the same reason.
- The `Mockable` dependency is now pinned to exactly `0.6.2`. Mockable `0.6.3` and later restrict `xctest-dynamic-overlay` to versions before `1.10.0`, which cannot be resolved alongside packages that depend on `swift-issue-reporting` (for example `swift-snapshot-testing` or `swift-custom-dump`) when building with Swift 6. Swift Package Manager reported this as duplicate `IssueReporting` targets. If your app depends on Mockable directly, use a version requirement that allows `0.6.2`.

## Fixes
- Picking a non-PDF document (such as a `.docx`, `.xlsx` or `.mp3` file) through "Choose from files" no longer shows a generic error alert. The composer, message and attachments-overview thumbnails tried to render every document as a PDF; they now do so only for PDFs. Files picked this way are also read with the access the Files picker grants, so a picked PDF no longer logs an "Operation not permitted" error.
- An image picked from iCloud Drive or another location outside the app through "Choose from files" now shows its thumbnail in the message input. Previously the thumbnail kept showing a loading indicator indefinitely; a thumbnail that cannot be loaded now shows the failed-attachment placeholder instead.
- An optional e-mail field left empty in the pre-chat survey no longer blocks submitting the form. Its format is now validated only when a value is entered; required fields are still enforced as before.
- Received attachments are now classified as image, video or audio by the top-level part of their MIME type (`image/…`, `video/…`, `audio/…`), the rule the message input preview already used. Previously a MIME type merely containing one of those words elsewhere could be shown as media.
- In the attachment gallery, the VoiceOver hint on the Share button now describes what Share actually shares. Outside selection mode it previously announced that no attachments were selected, although the button shares all of them.
- A document attachment is now recognised as a PDF the same way in the message bubble, the message input preview and the attachment gallery (file name, then URL, then MIME type). Previously the bubble and the input preview looked only at the MIME type, so a file whose name and MIME type disagreed could render as a PDF in one place and as a generic document in another.
- The VoiceOver announcement when an agent is assigned to a thread now uses the agent's nickname when one is set, matching the thread title, instead of always using the full name.
- An agent nickname made only of whitespace now counts as not set, so the agent's full name is shown instead of a blank thread title, avatar name and VoiceOver announcement. A nickname with surrounding whitespace is shown trimmed.
- The send button's VoiceOver hint now reports the button as disabled while a message is being sent.
- In pre-chat and edit pre-chat forms, VoiceOver no longer reads "Double-tap to select an option from the list" on a hierarchical field's title. The title is a heading, not a control; the options below it keep their own hints. The `form.tree_field_view.title.hint` key has been removed from `Accessibility.strings`, along with the unused `form.list_field_view.sheet.option.*` keys, which the system option sheet never read. An override of these keys in a custom `Accessibility.strings` file or `ChatAccessibility.provider` can be deleted.
- An open attachment preview — image, video, PDF or other document — is no longer dismissed when the device is rotated or when the conversation reflows. Previews are now presented above the conversation and the attachments overview rather than by the individual message cell, which the list discards as it scrolls. A document preview could also re-open by itself once the cell it belonged to came back on screen; it no longer does. The PDF preview now has its own close button, and document previews open full screen on iPad instead of as a centered card.
- Rotating the device now updates the whole conversation, not just the parts of it that happened to be redrawn for another reason. Message bubble widths, attachment thumbnail sizes, the attachment grid inside a bubble, quick reply and rich link card widths, form margins and the message input's insets previously kept the dimensions of the orientation that was active when they were last laid out — most visibly when rotating with a conversation already on screen. Message tooltips were sized for whichever orientation the first tooltip in the session was opened in and never changed afterwards.
- The navigation title no longer disappears in landscape light mode, on the thread list and in a conversation (including one with an AI Assistant).
- Focusing the message input with attachments selected no longer leaves a gap above the input bar and slides it behind the keyboard; the attachment strip now follows keyboard avoidance like the rest of the input.
- On a landscape phone, the attachment strip now shrinks to a compact layout — smaller thumbnails, no filename labels — while the keyboard is open, so the message input stays visible and you can see what you type. The strip returns to its full size once the keyboard closes, and portrait is unchanged.
- The attachment strip no longer clips the spacing below the filename labels, and the button that removes a staged attachment now has a full-size touch target.
- The conversation now scrolls to show the agent's typing indicator, both when the agent starts typing and when you open a conversation while they are already typing. Previously the view could stay where it was and leave the indicator off screen.
- Image and video attachment viewers now open full screen on iPad instead of a small centered card.
- Video playback now stops when its full-screen viewer is closed, so audio no longer keeps playing over the conversation.
- Opening a thread no longer shows an error alert when a video attachment fails to load in the background; the error is surfaced only when you tap the attachment to retry.
- A video opened from the attachments overview now uses the same viewer as the conversation, with a close button, the attachment name as title, and a share action — previously it presented a bare player with no controls.
- Toggling selection in the attachments overview no longer discards the loading state of the visible attachments and restarts their downloads.
- The attachments overview no longer loses the current selection when the conversation behind it updates.
- The elapsed-time label of a voice message no longer freezes when playback is resumed after a pause; it keeps counting until the clip ends. Replaying a clip also restarts the label from zero instead of continuing from the previous playthrough.
- Received audio attachments now load and play in the iOS Simulator. The cell skipped its whole preparation step there, so it showed `00:00 / 00:00` and never played; only builds on a physical device worked.
- An audio attachment scrolling into view no longer interrupts a voice message that is being recorded. The audio session is now claimed when playback actually starts instead of when the cell appears.
- Playing an audio message while a voice message is being recorded no longer discards the recording. The recording is finalized instead, so the customer keeps what they captured and can still send it. Starting a recording likewise stops any audio message that is playing, and playing a second audio message stops the first.
- A voice message interrupted by the system — an incoming call, Siri, or another app taking over audio — is now kept and remains ready to send, instead of being deleted with a generic error.
- An in-progress voice message is no longer discarded when the conversation around the input bar updates, for example when a new agent message arrives while the customer is still recording.
- Leaving a conversation while a voice message is being recorded now releases the microphone and the audio session instead of leaving them active. A voice message that has already been captured is kept, so it is still there if the input bar comes back.
- The message input bar drops its horizontal inset in landscape so it lines up with the edge-to-edge message list, and now updates on rotation instead of keeping the previous orientation's inset.
- An audio attachment that cannot be downloaded no longer pops an error alert on its own while the customer scrolls through the conversation. The error is reported when they tap play, and an attachment that failed to load no longer interrupts audio playing in other apps.
- Tapping play while an audio attachment is still downloading now starts playback as soon as the download finishes, instead of reporting an error for a request that had not failed. Scrolling the message away cancels that pending playback rather than starting it unprompted later.
- Audio playing in other apps now resumes as soon as a voice message or an audio attachment finishes playing, instead of staying interrupted until the customer paused it or left the conversation.
- Playing a captured voice message after an interruption — or after another audio message was played — now produces sound. The audio session is reactivated and reclaimed for the voice message first.
- Moving between conversations no longer stops audio-message playback from finalizing an in-progress voice message, so the recording survives in the newly opened conversation too.
- Voice messages captured but never sent are no longer kept indefinitely. They are written to a dedicated cache directory and swept a day later, once no conversation can reach them.
- The play and pause icons for audio message playback and voice message recording now use flat symbols instead of circled ones.
- A selected list picker option's background no longer bleeds into the horizontal safe-area insets in landscape.
- Quick reply options no longer stretch to the full screen width in landscape; they are now constrained to the same maximum width as other message bubbles.
- A time picker message bubble no longer stretches to nearly the full screen width in landscape; it is now capped at 60% of the screen width like other message bubbles.
- An image or video attachment that is still loading, or failed to load, in a conversation now matches the rounded-corner shape of its position within the message group, instead of always showing a plain uniform-corner placeholder.
- Image and video attachments waiting to be sent now show a border around their thumbnail in the message input, matching document attachments.
- A video attachment in a conversation now shows a border around its thumbnail once it finishes loading, matching image and document attachments.
- A video attachment could briefly show a mismatched border shape while its preview frame was still being generated, even after the video itself had already downloaded. It now matches the same rounded-corner shape as the rest of the attachment.
- A video attachment whose preview frame can never be generated (an unsupported codec, a truncated file) no longer shows a spinner indefinitely; it now settles on the same failed-attachment placeholder used elsewhere.
- A standalone (non-PDF) document attachment sent or received in a conversation now shows a border around its thumbnail, matching PDF, image, and video attachments.
- Image and video attachments in the attachments overview now show a border around their thumbnail, matching document attachments in the same view.
- A document attachment that is still loading, or failed to load, in a conversation now matches the rounded-corner shape of its position within the message group, instead of always showing a plain uniform-corner placeholder.
- An image attachment waiting to be sent no longer loses its solid background while it's still loading, so content behind the message input can no longer show through the placeholder.
- A non-PDF document attachment shown as part of multiple attachments in one message now shows the same sender-tinted background as a standalone document attachment.
- A non-PDF document thumbnail in the attachments overview had a slightly different border width than image, video, and PDF thumbnails in the same grid; it now matches.
- A PDF attachment that is still loading, or failed to load, in a conversation could show a second, wrongly-shaped border underneath its actual bubble border. It now shows a single, correctly-shaped border, matching image, video, and non-PDF document attachments.
- An image attachment waiting to be sent could show a second border stroked on top of itself while still loading. It now shows a single border.
- A non-PDF document attachment in the attachments overview that failed to load showed no border, unlike an image, video, or PDF attachment failing at the same grid position. It now shows the same border as its siblings.
- Backgrounding the app while `ChatCoordinator.content(...)` was still connecting no longer shows a connection-error alert on the next foreground. The in-flight connect is now cancelled when the app enters the background, and a cancelled connect is no longer treated as a real failure.
- A bottom sheet overlay (inactivity popup, end-conversation confirmation) could show its dimmed background at the wrong opacity right after appearing, before settling to its final look a moment later. It now shows the correct dimmed background immediately.
- Leading and trailing whitespace is now ignored when the pre-chat survey and the send-transcript form are validated and submitted. An e-mail address with a trailing space — commonly added when it is picked from the keyboard suggestions — is no longer rejected as invalid, a required field containing only spaces is no longer accepted as filled in, and the submitted values no longer carry the surrounding whitespace.
- On iOS 26, the inactivity popup's countdown no longer stays frozen at its starting value. The popup still closed when the time ran out, but the remaining seconds were not redrawn while it was shown; the end-conversation sheet was affected in the same way.
- Tapping just outside an image, video, or PDF thumbnail, or the image of a rich link, no longer opens it. A thumbnail is cropped to fill its frame, and the cropped-off part — invisible, but still extending past the thumbnail — kept responding to taps. This applied in the conversation, the attachments overview, and the message input, where the overflow of one attachment could block the remove button of the attachment next to it.


<a name="4.0.0"></a>
# [4.0.0] - 2026-08-05

## Breaking Changes
- Raised `swift-tools-version` from 5.7 to 6.0 (requires Xcode 16 or later)
- Raised minimum supported platform to iOS 16.0 (previously iOS 15.0)
- `ChatCoordinator.init` now requires a `chatProvider: ChatProvider` parameter. The UI module no longer reads `CXoneChat.shared` internally — construct a `CXoneChat()` instance in your app and pass it: `ChatCoordinator(chatProvider: chatProvider, …)`. `ChatCoordinator` subclasses must accept `chatProvider` in their own init and forward it via `super.init(chatProvider:…)`. See the [SDK Migration Guide](https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/docs/migration-from-singleton.md) for the full pattern.
- `ChatStyle`, `ChatLocalization`, `ChatCoordinator`, and `FormViewModel` are now `@MainActor`. Integrators accessing these types from non-`@MainActor` contexts must annotate those sites with `@MainActor` or wrap access in `await MainActor.run { }`.
- Removed the `ChatDelegate` protocol and `ChatCoordinator.delegate`. Implicit OAuth token refresh is now handled by the SDK — register `CustomerProvider.setTokenDelegateListener(_:)` (required for the implicit flow) instead of implementing `onConnectionTokenExpired()`.
- `RichMessageTimeSlot.formattedDescription(localization:)` is now `@MainActor`. Calls from non-`@MainActor` contexts require `await MainActor.run { }`.
- Localization string keys have been renamed from the flat `chatui_` prefix format (e.g. `chatui_common_ok`) to dot-notation (e.g. `common.ok`). If you supply a custom `CXOneChatUI.strings` file, you must migrate your keys to the new format — otherwise strings will silently fall back to SDK defaults. See the [Localization migration table](docs/cs-localization.md#deprecated-approaches) for a full key mapping.

## Features
- Add VoiceOver and accessibility support across all UI components
- Allow customization of accessibility labels and hints via `ChatAccessibility`
- Allow customization of localization strings via a `LocalizationStringProvider` protocol
- Adopt Swift strict-concurrency (internal refactor; no public API change)
- Show an "AI Assistant" indicator in the chat navigation bar while the conversation is handled by an AI agent; it disappears once a human agent takes over. The label is localizable via the `common.ai_assistant` key.
- Add localized fallbacks when an agent's personal information is hidden by the backend: the conversation title and the end-of-conversation header fall back to a generic "Agent" label, and the agent avatar falls back to initials or a placeholder icon

## Fixes
- On iOS 16, the chat log now scrolls to reveal newly arriving messages and the agent typing indicator, instead of leaving them hidden behind the message input bar. iOS 17+ was unaffected.
- On iOS 16, the chat and thread-list navigation bars now keep their themed background visible at all times. Previously the bar turned transparent when the chat log or thread list was scrolled to the top, so message content showed through behind the title and toolbar buttons.
- The position-in-queue overlay now stays hidden once the customer has been engaged by an agent, including after the agent unassigns and the contact waits for a new one, and when a thread is recovered with an existing case owner. This aligns the behavior with the Web Chat SDK.
- When a connection attempt fails with `CXoneChatError.featureUnavailable(_:)`, the chat now presents a targeted alert identifying the unavailable feature (for example, "The chat is not available because the 'Explicit OAuth' feature is not implemented. Check the documentation for more information.") and closes the chat when the alert is dismissed. Previously the failure surfaced as the generic disconnect alert.


<a name="3.3.1"></a>
# [3.3.1] - 2026-06-24

## Fixes
- make `BorderStyleColorsImpl`' s `defaultLight` and `defaultDark` publicly available
- Fix retain cycle for loading overlay


<a name="3.3.0"></a>
# [3.3.0] - 2026-05-07


## Features
- Add contextual loading indicators for attachments with failed state handling
- Update thread menu option icons and labels
- Add Time Picker UI integration

## Fixes
- Fix green and yellow highlight bars appearing on the conversations list on iOS 15
- Fix send button spinner visibility during attachment upload
- Fix visual gap at the bottom of the offline view where the message input was showing through
- Open chat URLs in an in-app browser to prevent app backgrounding during live chat
- Fix AudioCell Xcode preview crash
- Correctly reset Overlayable window
- Correct sending message view size


<a name="3.2.0"></a>
# [3.2.0] - 2026-02-26

## Features
- Support for Send Transcript
- Use an agent's `nickname` instead of `fullName` for conversation title if it's available

## Fixes 
- Migrate from UUID to String
- Resolve occasional UI module's crash for AudioPlayer
- Safely calculate audio message progress width
- Chat log no longer appears behind conversation's title
- Edit custom fields available in Singlethread na Livechat


<a name="3.1.3"></a>
# [3.1.3] - 2026-01-19

## Fixes
- Migrate from UUID to String

## Dependencies
- Update CXoneChatSDK to 3.1.3


<a name="3.1.2"></a>
# [3.1.2] - 2025-12-08

## Fixes
- Correct record voice message button visibility


<a name="3.1.1"></a>
# [3.1.1] - 2025-11-18

## Dependencies
- Update CXoneChatSDK to 3.1.1


<a name="3.1.0"></a>
# [3.1.0] - 2025-11-18

## Features
- Refactor constants to enum pattern
- Extend thread list cell of unread message state
- Disable the selection of the Quick Replies options if the message is not the last one.
- Prepare unsupported message cell with fallback text and tooltip for SDK's unsupported message types
- Dynamic attachment sizes
- Add accessibility identifiers for the selectable circle in AttachmentsView, the tooltip for a message, the status indicators in the message group and the cell unread indicator in the thread list
- Support for Inactivity Popup
- Add colors for new design system
- Add color customization for UI module

## Fixes
- Fix app freeze when swapping the thread list from Current to Archived
- Selecting the "Camera" attachment source incorrectly opened the photo library
- Fix voice recording state when permission is not granted
- Remove UI alerts for custom fields validation errors
- Replace documentDirectory with cachesDirectory for attachment storage to prevent clutter in Files app
- Fix remote push notification handling on iOS 15/16

## Dependencies
- Update CXoneChatSDK and CXoneGuideUtility to 3.1.0


<a name="3.0.3"></a>
# [3.0.3] - 2025-10-15

## Fixes
- Fix pre-chat survey form validation
- Fix conversation closed overlay appearing twice when rapidly tapping close chat


<a name="3.0.2"></a>
# [3.0.2] - 2025-07-31

## Fixes
- Resolved keyboard overlay issue on the Pre-contact Survey, ensuring cancel and confirm buttons remain accessible.


<a name="3.0.1"></a>
# [3.0.1] - 2025-07-11

## Fixes
- Working overlays for a pure SwiftUI application

## Dependencies
- Update CXoneChatSDK from 3.0.0 to 3.0.1


<a name="3.0.0"></a>
# [3.0.0] - 2025-06-05

## Features
- Release UI module

## Dependencies
- Update CXoneChatSDK from 2.3.2 to 3.0.0


<a name="2.3.2"></a>
# [2.3.2] - 2025-05-19

## Dependencies
- Update CXoneChatSDK from 2.3.1 to 2.3.2


<a name="2.3.1"></a>
# [2.3.1] - 2025-04-11

## Dependencies
- Update CXoneChatSDK from 2.3.0 to 2.3.1


<a name="2.3.0"></a>
# [2.3.0] - 2025-02-12

## Fixes
- MessageGroupView no longer stores group as a State property

## Features
- Update Chat Message Corner Radius
- Override default avatar image for an agent
- Update Chat Message Group Messages Spacing

## Dependencies
- Update CXoneChatSDK from 2.2.1 to 2.3.0


<a name="2.2.1"></a>
# [2.2.1] - 2024-12-06

## Dependencies
- Update CXoneChatSDK from 2.2.0 to 2.2.1


<a name="2.2.0"></a>
# [2.2.0] - 2024-11-04

## Features
- Update UI elements related to document thumbnails.
- Redesign live chat popups
- Redesign elements related to voice messages.
- Redesign Message Group Header
- Redesign Text Messages
- Redesign UI elements related to the Precontact Survey
- Redesign UI Elements related to image attachments.
- Add colors related to the UI redesign
- Removed branding for a chat
- Update Offline overlay of a disconnect button
- Update customizable and remove popup colors
- Redesign rich content message - rich link
- Redesign emoji message
- Add missing docstring
- Refactor StyleGuide constraints
- NavigationView based navigation
- Redesign Agent activity indicator
- Update UI element that displays hierarchical data on the Precontact Survey.
- Extend Agent activity indicator of the agent's avatar

## Fixes
- Send option content as a message with quick replies option selection 
- Fix load more messages
- Fixed issue where messages in the middle of a group might not be displayed.
- Add/Remove delegate correctly in onAppear/onDisappear methods 

## Dependencies
- Update CXoneChatSDK from 2.1.0 to 2.2.0


<a name="2.1.0"></a>
# [2.1.0] - 2024-07-29

## Features
- Attachments upload dialog
- Highlight text message cell content for links/phone numbers
- Minimum iOS deployment target
- Display thumbnail previews for selected attachment videos/images.
- Utilize Swift's Quicklook framework to view documents
- Refactors chat window navigation and presentation to:
    - not be dependent on host application UINavigationController
    - host application interface with chat window is greatly simplified and can be integrated into either a UIKit or SwiftUI interface as a sheet or other "presented" view controller.

## Bug Fixes
- Prefill prechat survey with customer data
- Rotation bug on iOS15
- Incorrect attachment size displayed for single attachment
- append UTType.movie for all videos

## Chore
- fix MessageGroupView preview
- Resolve SwiftLint warnings

## Dependencies
- Update CXoneChatSDK from 2.0.1 to 2.1.0


<a name="2.0.1"></a>
# [2.0.1] - 2024-07-11

## Dependencies
- Update CXoneChatSDK from 2.0.0 to 2.0.1


<a name="2.0.0"></a>
# [2.0.0] - 2024-05-22

## Bug Fixes
- Update ListFieldView behavior for iOS 14
- Exclude links from multiattachments view
- correct check for locally created thread
- Rotation bug on iOS15
- Incorrect attachment size displayed for single attachment
- append UTType.movie for all videos
- remove validation for Prechat survey
- Fix installation of SwiftGen with homebrew disabling swiftgen
- Fix Build/test break
- "properly" handle start/stopSecurelyScopedResource

## Dependency Change
- Bump peaceiris/actions-gh-pages from 3 to 4
- Bump xavierLowmiller/xcodegen-action from 1.1.3 to 1.2.0

## Features
- add Mobile SDK EU1 QA configurations
- Better welcome message handling
- Disable modification for archived thread
- Add localized strings to sdk package
- implement file restrictions parsing and publication
- update DeviceFingerprint with new expectations from web team
- Add Live chat mode
- Deprecate legacy plugins
- Attachments validation in the SDK
- Attachments Restrictions - file type
- Handle sent message via `onThreadUpdated(_:)`
- Privacy Manifest
- Implement Feature Toggles
- Create SDK's UserDefaults + Better Keychain handling
- Process large events from S3


<a name="1.3.3"></a>
# [1.3.3] - 2024-05-15

## Bug Fixes
- make assignedAgent optional for the event


<a name="1.3.2"></a>
# [1.3.2] - 2024-03-21

## Features
- Create SDK's UserDefaults + Better Keychain handling


<a name="1.3.1"></a>
# [1.3.1] - 2024-03-12

## Features
- Privacy Manifest


<a name="1.3.0"></a>
# [1.3.0] - 2024-03-12

## Bug Fixes
- Fixed deeplink format
- Correct CreateOrUpdateVisitor URL
- Resolve issue with submodules for GitHub Actions
- working Login preview
- checkout submodules for Deploy to TestFlight GH action
- Bottom offset for older devices
- Don't create customer with setting name
- duplicate SFSymbol image to SwiftUI + remove conversion from UIImage to Image
- Fix installation of SwiftGen with homebrew disabling swiftgen
- Correct API call in onAppear + adjust logging
- Handle RecoverThreadFailedEvent internally + prevent from archiving not yet existing thread
- Correct path for publishing build to TestFlight
- Working Remote Notifications
- Remove reporting viewPage for chat related
- Archive sample app for TestFlight GH Action
- edit configuration for archiving app
- Correct title when enter thread detail
- Fixed problem in hexString where wrong color was being created.
- fix UI issues related to iOS14
- Fix Deploy to TestFlight action
- Handle different thread correctly
- Fix issue when multiple messages with matching ids are received

## Features
- add login error state in case of unreachable API
- Add basic validation for brandId and channelId
- Login with Amazon SDK update + fixed Launch screen storyboard
- Trigger Analytics events with correct createdAt format
- Create tag with deploy to TestFlight
- Add GitHub action for generating IPA
- Deploy to TestFlight
- change open Chat button background color
- Re-write ThreadList from UIKit to SwiftUI
- Implementation of UI Module
- Add License
- Add section how to run Sample Application
- Integrate Crashlytics
- Enhance SDK Architecture
- Correct handling of welcome message


<a name="1.2.0"></a>
# [1.2.0] - 2023-09-22

## Bug Fixes
- working Login preview
- Remove reporting viewPage for chat related
- duplicate SFSymbol image to SwiftUI + remove conversion from UIImage to Image
- Bottom offset for older devices
- Working Remote Notifications
- Correct API call in onAppear + adjust logging
- Analytics Provider Error Handling + Connect in Login
- Cart and ProductDetail summary backgroundColor
- Replaced usage of keychain with UserDefaults
- Setting image as brand logo not working as expected
- Fixed issue where SettingsView was crashing
- Correct title when enter thread detail
- Fixed problem in hexString where wrong color was being created.

## Features
- change open Chat button background color
- Login with Amazon SDK update + fixed Launch screen storyboard
- Update version to 1.2.0
- remove deprecated API + rename uri to url in the rest of the project
- Event Type Unification
- Add basic validation for brandId and channelId
- Connect Chat flow from Store
- Use web-analytics for analytics events
- Add case studies + change jazzy output file
- Remote Push Notifications Manager
- Implement E-shop
- Create or Update Visitor via REST API
- Update decoding of ThreadRecoveredEvent
- Implement pageViewEnded
- Analytics Usage in E-shop


<a name="1.1.1"></a>
# [1.1.1] - 2023-07-10

## Features
- Update decoding of ThreadRecoveredEvent


<a name="1.1.0"></a>
# [1.1.0] - 2023-06-23

## Bug Fixes
- Remove not supported fields in ReceivedThreadRecoveredPostbackData
- Return message with attachments
- use correct EventDataType for loadThreadData and messageSeenByCustomer
- dont clear keychain with disconnect
- working action for Changelog
- use Docker image for changelog GitHub action
- use correct UUID for thread
- access file stored in Documents

## Features
- SwiftLint explicit init
- Event Type Unification
- use Codable only in valid cases + Encodable in test target
- Dependencies version update
- Message send returns Message model
- Dynamic Pre-chat Survey
- Implementation of the quick replies message type
- Implement List Picker and update previous rich message type
- Implementation of the rich link message type
- notify about close connection
- Postback for plugin messages
- Fresh Event Naming
- Add case studies + change jazzy output file


<a name="1.0.1"></a>
# [1.0.1] - 2023-03-14

### Features
- notify about close connection


<a name="1.0.0"></a>
# 1.0.0 - 2023-01-31

## Features
- Logging PoC
- Error handling
- Connection
  - Ping to ensure connection state
  - Execute trigger manually
  - Handle unexpected disconnect
- Customer
  - Save customer credentials
  - Customer authorisation
  - Customer reconnect
  - OAuth
- Customer Custom Fields
  - Save customer custom fields
- Threads
  - Update thread name
  - „Read“ flag
  - „Delivered“ flag
  - Threads load
  - Contact inbox assignee change
  - Recover thread
  - Typing indicator
  - Archive thread
  - Load thread metadada
  - Handle proactive action
    - Welcome message
    - Custom popup box
- Contact Custom Fields
  - Save contact custom fields
- Messages
  - Send/Receive attachments
    - Image
    - Video
    - Documents
  - Handle a message
    - Text
    - Plugin
      - Gallery
      - Menu
      - Text and Buttons
      - Quick Replies
      - Satisfaction Survey
      - Custom
      - Sub Elements
        - Text
        - Title
        - File
        - Button/iFrame Button
  - Previous message load
- Analytics
  - Page view
  - Chat window open
  - App visit
  - Conversion
  - Custom visitor event
  - Proactive action
    - display
    - success
    - failure
  - typing start/end


[Unreleased]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/4.1.0...HEAD
[4.1.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/4.0.0...4.1.0
[4.0.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.3.1...4.0.0
[3.3.1]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.3.0...3.3.1
[3.3.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.2.0...3.3.0
[3.2.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.1.3...3.2.0
[3.1.3]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.1.2...3.1.3
[3.1.2]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.1.1...3.1.2
[3.1.1]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.1.0...3.1.1
[3.1.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.0.3...3.1.0
[3.0.3]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.0.2...3.0.3
[3.0.2]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.0.1...3.0.2
[3.0.1]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/2.3.0...3.0.0
[2.3.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/2.2.1...2.3.0
[2.2.1]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.3.3...2.0.0
[1.3.3]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.3.2...1.3.3
[1.3.2]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.3.1...1.3.2
[1.3.1]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.3.0...1.3.1
[1.3.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.1.1...1.2.0
[1.1.1]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/releases/tag/1.0.0
