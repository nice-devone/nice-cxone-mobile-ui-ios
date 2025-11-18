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

[Unreleased]: https://github.com/nice-devone/nice-cxone-mobile-ui-ios/compare/3.1.0...HEAD
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
