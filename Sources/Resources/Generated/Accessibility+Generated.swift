// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// MARK: - Strings

internal enum A11y {
  internal enum Announcement {
    internal enum AgentAssignment {
      /// Agent %1$@ has joined the conversation
      internal static func assigned(_ p1: Any) -> String {
        return A11y.tr("Accessibility", "announcement.agent_assignment.assigned", String(describing: p1), fallback: "Agent %1$@ has joined the conversation")
      }
      internal enum Assigned {
        /// An agent has joined the conversation
        internal static var unknown: String { return A11y.tr("Accessibility", "announcement.agent_assignment.assigned.unknown", fallback: "An agent has joined the conversation") }
      }
    }
    internal enum Attachment {
      /// %1$@ added
      internal static func added(_ p1: Any) -> String {
        return A11y.tr("Accessibility", "announcement.attachment.added", String(describing: p1), fallback: "%1$@ added")
      }
      /// %1$@ removed
      internal static func removed(_ p1: Any) -> String {
        return A11y.tr("Accessibility", "announcement.attachment.removed", String(describing: p1), fallback: "%1$@ removed")
      }
    }
    internal enum AttachmentGalleryView {
      /// %1$@ deselected
      internal static func deselected(_ p1: Any) -> String {
        return A11y.tr("Accessibility", "announcement.attachment_gallery_view.deselected", String(describing: p1), fallback: "%1$@ deselected")
      }
      /// All attachments deselected
      internal static var deselectedAll: String { return A11y.tr("Accessibility", "announcement.attachment_gallery_view.deselected_all", fallback: "All attachments deselected") }
      /// %1$@ selected
      internal static func selected(_ p1: Any) -> String {
        return A11y.tr("Accessibility", "announcement.attachment_gallery_view.selected", String(describing: p1), fallback: "%1$@ selected")
      }
      /// All attachments selected
      internal static var selectedAll: String { return A11y.tr("Accessibility", "announcement.attachment_gallery_view.selected_all", fallback: "All attachments selected") }
      internal enum SelectionMode {
        /// Selection mode disabled
        internal static var disabled: String { return A11y.tr("Accessibility", "announcement.attachment_gallery_view.selection_mode.disabled", fallback: "Selection mode disabled") }
        /// Selection mode enabled
        internal static var enabled: String { return A11y.tr("Accessibility", "announcement.attachment_gallery_view.selection_mode.enabled", fallback: "Selection mode enabled") }
      }
    }
    internal enum Conversation {
      internal enum TypingIndicator {
        /// %1$@ is typing
        internal static func started(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "announcement.conversation.typing_indicator.started", String(describing: p1), fallback: "%1$@ is typing")
        }
        internal enum Started {
          /// Agent is typing
          internal static var unknown: String { return A11y.tr("Accessibility", "announcement.conversation.typing_indicator.started.unknown", fallback: "Agent is typing") }
        }
      }
    }
    internal enum Form {
      internal enum Validation {
        internal enum Invalid {
          /// Please complete the required field(s) to continue
          internal static var argument: String { return A11y.tr("Accessibility", "announcement.form.validation.invalid.argument", fallback: "Please complete the required field(s) to continue") }
        }
      }
    }
    internal enum Message {
      /// New incoming message
      internal static var incoming: String { return A11y.tr("Accessibility", "announcement.message.incoming", fallback: "New incoming message") }
      /// Message sent
      internal static var sent: String { return A11y.tr("Accessibility", "announcement.message.sent", fallback: "Message sent") }
      internal enum Status {
        /// Message delivered
        internal static var delivered: String { return A11y.tr("Accessibility", "announcement.message.status.delivered", fallback: "Message delivered") }
        /// Message failed to send
        internal static var failed: String { return A11y.tr("Accessibility", "announcement.message.status.failed", fallback: "Message failed to send") }
        /// Message read
        internal static var seen: String { return A11y.tr("Accessibility", "announcement.message.status.seen", fallback: "Message read") }
        /// Message sent
        internal static var sent: String { return A11y.tr("Accessibility", "announcement.message.status.sent", fallback: "Message sent") }
      }
    }
  }
  internal enum AttachmentGalleryView {
    internal enum ButtonCancel {
      /// Double-tap to exit selection mode
      internal static var hint: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_cancel.hint", fallback: "Double-tap to exit selection mode") }
      /// Cancel
      internal static var label: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_cancel.label", fallback: "Cancel") }
    }
    internal enum ButtonDeselect {
      /// Double-tap to deselect all attachments
      internal static var hint: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_deselect.hint", fallback: "Double-tap to deselect all attachments") }
      /// Deselect all
      internal static var label: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_deselect.label", fallback: "Deselect all") }
    }
    internal enum ButtonSelect {
      /// Double-tap to enter selection mode
      internal static var hint: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_select.hint", fallback: "Double-tap to enter selection mode") }
      /// Select
      internal static var label: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_select.label", fallback: "Select") }
    }
    internal enum ButtonSelectAll {
      /// Double-tap to select all attachments
      internal static var hint: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_select_all.hint", fallback: "Double-tap to select all attachments") }
      /// Select all
      internal static var label: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_select_all.label", fallback: "Select all") }
    }
    internal enum ButtonShare {
      /// Share
      internal static var label: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_share.label", fallback: "Share") }
      internal enum Hint {
        /// Double-tap to share %1$@ selected attachments
        internal static func multiple(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "attachment_gallery_view.button_share.hint.multiple", String(describing: p1), fallback: "Double-tap to share %1$@ selected attachments")
        }
        /// Select attachments to share
        internal static var `none`: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_share.hint.none", fallback: "Select attachments to share") }
        /// Double-tap to share selected attachment
        internal static var single: String { return A11y.tr("Accessibility", "attachment_gallery_view.button_share.hint.single", fallback: "Double-tap to share selected attachment") }
      }
    }
    internal enum Item {
      internal enum Document {
        /// Document: %1$@
        internal static func label(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "attachment_gallery_view.item.document.label", String(describing: p1), fallback: "Document: %1$@")
        }
        internal enum Hint {
          /// Double-tap to open
          internal static var browse: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.document.hint.browse", fallback: "Double-tap to open") }
          /// Double-tap to toggle selection
          internal static var select: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.document.hint.select", fallback: "Double-tap to toggle selection") }
        }
        internal enum Value {
          /// Not selected
          internal static var notSelected: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.document.value.not_selected", fallback: "Not selected") }
          /// Selected
          internal static var selected: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.document.value.selected", fallback: "Selected") }
        }
      }
      internal enum Image {
        /// Image: %1$@
        internal static func label(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "attachment_gallery_view.item.image.label", String(describing: p1), fallback: "Image: %1$@")
        }
        internal enum Hint {
          /// Double-tap to view
          internal static var browse: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.image.hint.browse", fallback: "Double-tap to view") }
          /// Double-tap to toggle selection
          internal static var select: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.image.hint.select", fallback: "Double-tap to toggle selection") }
        }
        internal enum Value {
          /// Not selected
          internal static var notSelected: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.image.value.not_selected", fallback: "Not selected") }
          /// Selected
          internal static var selected: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.image.value.selected", fallback: "Selected") }
        }
      }
      internal enum Value {
        /// Failed to load
        internal static var failed: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.value.failed", fallback: "Failed to load") }
        /// Loading
        internal static var loading: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.value.loading", fallback: "Loading") }
      }
      internal enum Video {
        /// Video: %1$@
        internal static func label(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "attachment_gallery_view.item.video.label", String(describing: p1), fallback: "Video: %1$@")
        }
        internal enum Hint {
          /// Double-tap to play
          internal static var browse: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.video.hint.browse", fallback: "Double-tap to play") }
          /// Double-tap to toggle selection
          internal static var select: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.video.hint.select", fallback: "Double-tap to toggle selection") }
        }
        internal enum Value {
          /// Not selected
          internal static var notSelected: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.video.value.not_selected", fallback: "Not selected") }
          /// Selected
          internal static var selected: String { return A11y.tr("Accessibility", "attachment_gallery_view.item.video.value.selected", fallback: "Selected") }
        }
      }
    }
    internal enum Status {
      internal enum SelectedCount {
        /// %1$@ selected
        internal static func label(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "attachment_gallery_view.status.selected_count.label", String(describing: p1), fallback: "%1$@ selected")
        }
      }
      internal enum SelectionMode {
        /// Selection mode
        internal static var label: String { return A11y.tr("Accessibility", "attachment_gallery_view.status.selection_mode.label", fallback: "Selection mode") }
      }
    }
    internal enum Title {
      /// Attachments
      internal static var label: String { return A11y.tr("Accessibility", "attachment_gallery_view.title.label", fallback: "Attachments") }
    }
  }
  internal enum ChatContainer {
    internal enum Alert {
      internal enum ButtonCancel {
        /// Double-tap to cancel
        internal static var hint: String { return A11y.tr("Accessibility", "chat_container.alert.button_cancel.hint", fallback: "Double-tap to cancel") }
      }
      internal enum CameraPermissionDenied {
        internal enum ButtonSettings {
          /// Double-tap to navigate to system Settings
          internal static var hint: String { return A11y.tr("Accessibility", "chat_container.alert.camera_permission_denied.button_settings.hint", fallback: "Double-tap to navigate to system Settings") }
        }
      }
      internal enum ConnectionError {
        internal enum ButtonDisconnect {
          /// Double-tap to close the chat
          internal static var hint: String { return A11y.tr("Accessibility", "chat_container.alert.connection_error.button_disconnect.hint", fallback: "Double-tap to close the chat") }
        }
      }
      internal enum EndConversation {
        internal enum ButtonConfirm {
          /// Double-tap to end conversation
          internal static var hint: String { return A11y.tr("Accessibility", "chat_container.alert.end_conversation.button_confirm.hint", fallback: "Double-tap to end conversation") }
        }
      }
      internal enum GenericError {
        internal enum ButtonCancel {
          /// Double-tap to cancel
          internal static var hint: String { return A11y.tr("Accessibility", "chat_container.alert.generic_error.button_cancel.hint", fallback: "Double-tap to cancel") }
        }
      }
      internal enum MicrophonePermissionDenied {
        internal enum ButtonSettings {
          /// Double-tap to navigate to system Settings
          internal static var hint: String { return A11y.tr("Accessibility", "chat_container.alert.microphone_permission_denied.button_settings.hint", fallback: "Double-tap to navigate to system Settings") }
        }
      }
    }
    internal enum NavigationBar {
      internal enum ButtonClose {
        /// Double-tap to close the chat session
        internal static var hint: String { return A11y.tr("Accessibility", "chat_container.navigation_bar.button_close.hint", fallback: "Double-tap to close the chat session") }
        /// Close
        internal static var label: String { return A11y.tr("Accessibility", "chat_container.navigation_bar.button_close.label", fallback: "Close") }
      }
      internal enum ButtonMenu {
        /// Double-tap to show options
        internal static var hint: String { return A11y.tr("Accessibility", "chat_container.navigation_bar.button_menu.hint", fallback: "Double-tap to show options") }
        /// Menu
        internal static var label: String { return A11y.tr("Accessibility", "chat_container.navigation_bar.button_menu.label", fallback: "Menu") }
        internal enum Option {
          /// Double-tap to select
          internal static var hint: String { return A11y.tr("Accessibility", "chat_container.navigation_bar.button_menu.option.hint", fallback: "Double-tap to select") }
        }
      }
    }
  }
  internal enum ChatOverlay {
    internal enum Loading {
      internal enum ButtonDelay {
        /// Double-tap to cancel and close the chat
        internal static var hint: String { return A11y.tr("Accessibility", "chat_overlay.loading.button_delay.hint", fallback: "Double-tap to cancel and close the chat") }
      }
      internal enum ProgressView {
        /// Loading
        internal static var label: String { return A11y.tr("Accessibility", "chat_overlay.loading.progress_view.label", fallback: "Loading") }
      }
    }
  }
  internal enum Conversation {
    internal enum AiAssistantBadge {
      /// Indicates you are chatting with an AI assistant, not a human agent
      internal static var hint: String { return A11y.tr("Accessibility", "conversation.ai_assistant_badge.hint", fallback: "Indicates you are chatting with an AI assistant, not a human agent") }
    }
    internal enum MessageCell {
      internal enum AgentMessage {
        /// Message from %1$@
        internal static func value(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "conversation.message_cell.agent_message.value", String(describing: p1), fallback: "Message from %1$@")
        }
      }
      internal enum Attachment {
        internal enum Audio {
          /// Audio: %1$@
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.label", String(describing: p1), fallback: "Audio: %1$@")
          }
          internal enum ButtonAdvance {
            /// Double-tap to advance 10 seconds
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.button_advance.hint", fallback: "Double-tap to advance 10 seconds") }
            /// Advance
            internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.button_advance.label", fallback: "Advance") }
          }
          internal enum ButtonPause {
            /// Double-tap to pause audio
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.button_pause.hint", fallback: "Double-tap to pause audio") }
            /// Pause
            internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.button_pause.label", fallback: "Pause") }
          }
          internal enum ButtonPlay {
            /// Double-tap to play audio
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.button_play.hint", fallback: "Double-tap to play audio") }
            /// Play
            internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.button_play.label", fallback: "Play") }
          }
          internal enum ButtonRewind {
            /// Double-tap to rewind 10 seconds
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.button_rewind.hint", fallback: "Double-tap to rewind 10 seconds") }
            /// Rewind
            internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.button_rewind.label", fallback: "Rewind") }
          }
          internal enum ProgressBar {
            /// Audio playback progress
            internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.progress_bar.label", fallback: "Audio playback progress") }
            /// %1$@ of %2$@
            internal static func value(_ p1: Any, _ p2: Any) -> String {
              return A11y.tr("Accessibility", "conversation.message_cell.attachment.audio.progress_bar.value", String(describing: p1), String(describing: p2), fallback: "%1$@ of %2$@")
            }
          }
        }
        internal enum ButtonShare {
          /// attachment
          internal static var fallback: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.button_share.fallback", fallback: "attachment") }
          /// Double-tap to share %1$@
          internal static func hint(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.attachment.button_share.hint", String(describing: p1), fallback: "Double-tap to share %1$@")
          }
          /// Share
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.button_share.label", fallback: "Share") }
        }
        internal enum Document {
          /// Double-tap to open document
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.document.hint", fallback: "Double-tap to open document") }
          /// Document: %1$@
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.attachment.document.label", String(describing: p1), fallback: "Document: %1$@")
          }
        }
        internal enum Failed {
          /// Double-tap to retry
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.failed.hint", fallback: "Double-tap to retry") }
          /// Attachment failed to load
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.failed.label", fallback: "Attachment failed to load") }
        }
        internal enum Image {
          /// Double-tap to view full image
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.image.hint", fallback: "Double-tap to view full image") }
          /// Image: %1$@
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.attachment.image.label", String(describing: p1), fallback: "Image: %1$@")
          }
        }
        internal enum Video {
          /// Double-tap to play video
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.video.hint", fallback: "Double-tap to play video") }
          /// Video: %1$@
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.attachment.video.label", String(describing: p1), fallback: "Video: %1$@")
          }
          internal enum Failed {
            /// Double-tap to retry
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.video.failed.hint", fallback: "Double-tap to retry") }
            /// Video failed to load
            internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.video.failed.label", fallback: "Video failed to load") }
          }
          internal enum Loading {
            /// Loading video
            internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.attachment.video.loading.label", fallback: "Loading video") }
          }
        }
      }
      internal enum Audio {
        internal enum ButtonAdvance {
          /// Double-tap to fast forward the audio by %1$@ seconds
          internal static func hint(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.audio.button_advance.hint", String(describing: p1), fallback: "Double-tap to fast forward the audio by %1$@ seconds")
          }
          /// Fast forward
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.audio.button_advance.label", fallback: "Fast forward") }
        }
        internal enum ButtonPause {
          /// Double-tap to pause playback
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.audio.button_pause.hint", fallback: "Double-tap to pause playback") }
          /// Pause
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.audio.button_pause.label", fallback: "Pause") }
        }
        internal enum ButtonPlay {
          /// Double-tap to play the audio message
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.audio.button_play.hint", fallback: "Double-tap to play the audio message") }
          /// Play
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.audio.button_play.label", fallback: "Play") }
        }
        internal enum ButtonRewind {
          /// Double-tap to rewind the audio by %1$@ seconds
          internal static func hint(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.audio.button_rewind.hint", String(describing: p1), fallback: "Double-tap to rewind the audio by %1$@ seconds")
          }
          /// Rewind
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.audio.button_rewind.label", fallback: "Rewind") }
        }
        internal enum SeekBar {
          /// Current playback position in the audio recording
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.audio.seek_bar.hint", fallback: "Current playback position in the audio recording") }
          /// Playback position
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.audio.seek_bar.label", fallback: "Playback position") }
          /// %1$@ of %2$@
          internal static func value(_ p1: Any, _ p2: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.audio.seek_bar.value", String(describing: p1), String(describing: p2), fallback: "%1$@ of %2$@")
          }
        }
      }
      internal enum Avatar {
        internal enum Image {
          /// Agent's image
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.avatar.image.hint", fallback: "Agent's image") }
        }
        internal enum Initials {
          /// Agent's initials
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.avatar.initials.hint", fallback: "Agent's initials") }
        }
      }
      internal enum CustomerMessage {
        /// Message from you
        internal static var value: String { return A11y.tr("Accessibility", "conversation.message_cell.customer_message.value", fallback: "Message from you") }
      }
      internal enum ListPicker {
        /// Double-tap to open option selection
        internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.list_picker.hint", fallback: "Double-tap to open option selection") }
        internal enum Sheet {
          internal enum ButtonCancel {
            /// Double-tap to cancel option selection
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.list_picker.sheet.button_cancel.hint", fallback: "Double-tap to cancel option selection") }
          }
          internal enum ButtonConfirm {
            /// Double-tap to confirm option selection
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.list_picker.sheet.button_confirm.hint", fallback: "Double-tap to confirm option selection") }
          }
          internal enum Cell {
            /// Double-tap to toggle option
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.list_picker.sheet.cell.hint", fallback: "Double-tap to toggle option") }
            internal enum Check {
              /// Option is selected
              internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.list_picker.sheet.cell.check.label", fallback: "Option is selected") }
            }
          }
        }
      }
      internal enum MultipleAttachments {
        internal enum ButtonShare {
          /// attachments
          internal static var fallback: String { return A11y.tr("Accessibility", "conversation.message_cell.multiple_attachments.button_share.fallback", fallback: "attachments") }
          /// Double-tap to share %1$@
          internal static func hint(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.multiple_attachments.button_share.hint", String(describing: p1), fallback: "Double-tap to share %1$@")
          }
          /// Share
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.multiple_attachments.button_share.label", fallback: "Share") }
        }
        internal enum Container {
          /// %1$@ attachments
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.multiple_attachments.container.label", String(describing: p1), fallback: "%1$@ attachments")
          }
        }
        internal enum MoreIndicator {
          /// Double-tap to view all attachments
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.multiple_attachments.more_indicator.hint", fallback: "Double-tap to view all attachments") }
          /// Plus %1$@ more
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "conversation.message_cell.multiple_attachments.more_indicator.label", String(describing: p1), fallback: "Plus %1$@ more")
          }
        }
      }
      internal enum OptionSelected {
        /// Option already selected
        internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.option_selected.hint", fallback: "Option already selected") }
      }
      internal enum QuickReplies {
        /// Select an option below
        internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.quick_replies.hint", fallback: "Select an option below") }
        internal enum Option {
          /// Double-tap to select option
          internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.quick_replies.option.hint", fallback: "Double-tap to select option") }
        }
      }
      internal enum RichLink {
        /// Double-tap to open link in browser
        internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.rich_link.hint", fallback: "Double-tap to open link in browser") }
        internal enum ContextMenu {
          internal enum ButtonCopy {
            /// Double-tap to copy the link
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.rich_link.context_menu.button_copy.hint", fallback: "Double-tap to copy the link") }
          }
          internal enum ButtonShare {
            /// Double-tap to share the link
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.rich_link.context_menu.button_share.hint", fallback: "Double-tap to share the link") }
          }
        }
      }
      internal enum RichMessageSheet {
        internal enum ControlButtons {
          internal enum Cancel {
            /// Double-tap to cancel option selection
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.rich_message_sheet.control_buttons.cancel.hint", fallback: "Double-tap to cancel option selection") }
          }
          internal enum Confirm {
            /// Double-tap to confirm option selection
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.rich_message_sheet.control_buttons.confirm.hint", fallback: "Double-tap to confirm option selection") }
          }
        }
      }
      internal enum Share {
        /// Double-tap to share message content
        internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.share.hint", fallback: "Double-tap to share message content") }
        /// Share button
        internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.share.label", fallback: "Share button") }
      }
      internal enum Status {
        internal enum Delivered {
          /// Delivered
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.status.delivered.label", fallback: "Delivered") }
        }
        internal enum Failed {
          /// Failed to send
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.status.failed.label", fallback: "Failed to send") }
        }
        internal enum Seen {
          /// Seen
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.status.seen.label", fallback: "Seen") }
        }
        internal enum Sent {
          /// Sent
          internal static var label: String { return A11y.tr("Accessibility", "conversation.message_cell.status.sent.label", fallback: "Sent") }
        }
      }
      internal enum TimePicker {
        /// Double-tap to open time slot selection
        internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.time_picker.hint", fallback: "Double-tap to open time slot selection") }
        internal enum Sheet {
          internal enum Slot {
            /// Double-tap to toggle time slot
            internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.time_picker.sheet.slot.hint", fallback: "Double-tap to toggle time slot") }
            /// %@, %@ minutes
            internal static func label(_ p1: Any, _ p2: Any) -> String {
              return A11y.tr("Accessibility", "conversation.message_cell.time_picker.sheet.slot.label", String(describing: p1), String(describing: p2), fallback: "%@, %@ minutes")
            }
            internal enum Selected {
              /// %@, %@ minutes, selected
              internal static func label(_ p1: Any, _ p2: Any) -> String {
                return A11y.tr("Accessibility", "conversation.message_cell.time_picker.sheet.slot.selected.label", String(describing: p1), String(describing: p2), fallback: "%@, %@ minutes, selected")
              }
            }
          }
        }
      }
      internal enum Timestamp {
        /// Sent at %1$@
        internal static func label(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "conversation.message_cell.timestamp.label", String(describing: p1), fallback: "Sent at %1$@")
        }
      }
      internal enum Tooltip {
        /// Double-tap to show tooltip
        internal static var hint: String { return A11y.tr("Accessibility", "conversation.message_cell.tooltip.hint", fallback: "Double-tap to show tooltip") }
      }
    }
    internal enum TypingIndicator {
      /// %1$@ is typing
      internal static func label(_ p1: Any) -> String {
        return A11y.tr("Accessibility", "conversation.typing_indicator.label", String(describing: p1), fallback: "%1$@ is typing")
      }
      internal enum Label {
        /// Agent is typing
        internal static var unknown: String { return A11y.tr("Accessibility", "conversation.typing_indicator.label.unknown", fallback: "Agent is typing") }
      }
    }
  }
  internal enum DocumentViewer {
    internal enum ButtonClose {
      /// Double-tap to close document viewer
      internal static var hint: String { return A11y.tr("Accessibility", "document_viewer.button_close.hint", fallback: "Double-tap to close document viewer") }
      /// Close
      internal static var label: String { return A11y.tr("Accessibility", "document_viewer.button_close.label", fallback: "Close") }
    }
  }
  internal enum EndConversationPopup {
    internal enum ButtonBack {
      /// Double-tap to return to the current conversation
      internal static var hint: String { return A11y.tr("Accessibility", "end_conversation_popup.button_back.hint", fallback: "Double-tap to return to the current conversation") }
    }
    internal enum ButtonClose {
      /// Double-tap to close the chat session
      internal static var hint: String { return A11y.tr("Accessibility", "end_conversation_popup.button_close.hint", fallback: "Double-tap to close the chat session") }
    }
    internal enum ButtonNewChat {
      /// Double-tap to start a new conversation
      internal static var hint: String { return A11y.tr("Accessibility", "end_conversation_popup.button_new_chat.hint", fallback: "Double-tap to start a new conversation") }
    }
    internal enum ButtonSendTranscript {
      /// Double-tap to send a transcript of this conversation
      internal static var hint: String { return A11y.tr("Accessibility", "end_conversation_popup.button_send_transcript.hint", fallback: "Double-tap to send a transcript of this conversation") }
    }
    internal enum Header {
      internal enum AgentInfo {
        /// Agent: %1$@
        internal static func label(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "end_conversation_popup.header.agent_info.label", String(describing: p1), fallback: "Agent: %1$@")
        }
      }
    }
  }
  internal enum Form {
    internal enum ButtonCancel {
      /// Double-tap to cancel the form
      internal static var hint: String { return A11y.tr("Accessibility", "form.button_cancel.hint", fallback: "Double-tap to cancel the form") }
    }
    internal enum ButtonConfirm {
      internal enum Invalid {
        /// Please complete the required fields to continue
        internal static var hint: String { return A11y.tr("Accessibility", "form.button_confirm.invalid.hint", fallback: "Please complete the required fields to continue") }
      }
      internal enum Valid {
        /// Double-tap to confirm the form
        internal static var hint: String { return A11y.tr("Accessibility", "form.button_confirm.valid.hint", fallback: "Double-tap to confirm the form") }
      }
    }
    internal enum ListFieldView {
      internal enum Content {
        /// Double-tap to select an option
        internal static var hint: String { return A11y.tr("Accessibility", "form.list_field_view.content.hint", fallback: "Double-tap to select an option") }
        /// %1$@, %2$@
        internal static func label(_ p1: Any, _ p2: Any) -> String {
          return A11y.tr("Accessibility", "form.list_field_view.content.label", String(describing: p1), String(describing: p2), fallback: "%1$@, %2$@")
        }
        internal enum Value {
          /// %1$@, collapsed
          internal static func collapsed(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "form.list_field_view.content.value.collapsed", String(describing: p1), fallback: "%1$@, collapsed")
          }
          /// %1$@, expanded
          internal static func expanded(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "form.list_field_view.content.value.expanded", String(describing: p1), fallback: "%1$@, expanded")
          }
          /// %1$@, invalid
          internal static func invalid(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "form.list_field_view.content.value.invalid", String(describing: p1), fallback: "%1$@, invalid")
          }
        }
      }
    }
    internal enum TreeFieldView {
      internal enum Content {
        internal enum Leaf {
          /// Double-tap to select
          internal static var hint: String { return A11y.tr("Accessibility", "form.tree_field_view.content.leaf.hint", fallback: "Double-tap to select") }
          internal enum Selected {
            /// Double-tap to deselect
            internal static var hint: String { return A11y.tr("Accessibility", "form.tree_field_view.content.leaf.selected.hint", fallback: "Double-tap to deselect") }
          }
        }
        internal enum ParentHint {
          /// Double-tap to expand
          internal static var collapsed: String { return A11y.tr("Accessibility", "form.tree_field_view.content.parent_hint.collapsed", fallback: "Double-tap to expand") }
          /// Double-tap to collapse
          internal static var expanded: String { return A11y.tr("Accessibility", "form.tree_field_view.content.parent_hint.expanded", fallback: "Double-tap to collapse") }
        }
        internal enum ParentState {
          /// Collapsed
          internal static var collapsed: String { return A11y.tr("Accessibility", "form.tree_field_view.content.parent_state.collapsed", fallback: "Collapsed") }
          /// Collapsed, contains selection
          internal static var collapsedWithSelection: String { return A11y.tr("Accessibility", "form.tree_field_view.content.parent_state.collapsed_with_selection", fallback: "Collapsed, contains selection") }
          /// Expanded
          internal static var expanded: String { return A11y.tr("Accessibility", "form.tree_field_view.content.parent_state.expanded", fallback: "Expanded") }
          /// Expanded, contains selection
          internal static var expandedWithSelection: String { return A11y.tr("Accessibility", "form.tree_field_view.content.parent_state.expanded_with_selection", fallback: "Expanded, contains selection") }
        }
      }
      internal enum Title {
        /// %1$@, %2$@
        internal static func label(_ p1: Any, _ p2: Any) -> String {
          return A11y.tr("Accessibility", "form.tree_field_view.title.label", String(describing: p1), String(describing: p2), fallback: "%1$@, %2$@")
        }
      }
      internal enum Validation {
        internal enum Invalid {
          /// %1$@ is required
          internal static func argument(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "form.tree_field_view.validation.invalid.argument", String(describing: p1), fallback: "%1$@ is required")
          }
        }
      }
    }
  }
  internal enum ImageViewer {
    internal enum ButtonClose {
      /// Double-tap to close image viewer
      internal static var hint: String { return A11y.tr("Accessibility", "image_viewer.button_close.hint", fallback: "Double-tap to close image viewer") }
      /// Close
      internal static var label: String { return A11y.tr("Accessibility", "image_viewer.button_close.label", fallback: "Close") }
    }
    internal enum ButtonShare {
      /// Double-tap to share the image
      internal static var hint: String { return A11y.tr("Accessibility", "image_viewer.button_share.hint", fallback: "Double-tap to share the image") }
      /// Share
      internal static var label: String { return A11y.tr("Accessibility", "image_viewer.button_share.label", fallback: "Share") }
    }
    internal enum Content {
      /// Pinch to zoom
      internal static var hint: String { return A11y.tr("Accessibility", "image_viewer.content.hint", fallback: "Pinch to zoom") }
      /// Full screen image
      internal static var label: String { return A11y.tr("Accessibility", "image_viewer.content.label", fallback: "Full screen image") }
    }
  }
  internal enum InactivityPopup {
    internal enum ButtonExpire {
      /// Double-tap to end the conversation
      internal static var hint: String { return A11y.tr("Accessibility", "inactivity_popup.button_expire.hint", fallback: "Double-tap to end the conversation") }
    }
    internal enum ButtonRefresh {
      /// Double-tap to continue the conversation
      internal static var hint: String { return A11y.tr("Accessibility", "inactivity_popup.button_refresh.hint", fallback: "Double-tap to continue the conversation") }
    }
    internal enum Header {
      internal enum Active {
        /// Chat expiring soon
        internal static var label: String { return A11y.tr("Accessibility", "inactivity_popup.header.active.label", fallback: "Chat expiring soon") }
        /// %1$@ remaining
        internal static func value(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "inactivity_popup.header.active.value", String(describing: p1), fallback: "%1$@ remaining")
        }
      }
      internal enum TimedOut {
        /// Chat session expired
        internal static var label: String { return A11y.tr("Accessibility", "inactivity_popup.header.timed_out.label", fallback: "Chat session expired") }
      }
    }
  }
  internal enum MessageInput {
    internal enum AttachmentPreview {
      internal enum ButtonRemove {
        /// Double-tap to remove %1$@ from message
        internal static func hint(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "message_input.attachment_preview.button_remove.hint", String(describing: p1), fallback: "Double-tap to remove %1$@ from message")
        }
        /// Remove
        internal static var label: String { return A11y.tr("Accessibility", "message_input.attachment_preview.button_remove.label", fallback: "Remove") }
      }
      internal enum Loading {
        /// Uploading attachments
        internal static var label: String { return A11y.tr("Accessibility", "message_input.attachment_preview.loading.label", fallback: "Uploading attachments") }
        /// %1$@ percent complete
        internal static func value(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "message_input.attachment_preview.loading.value", String(describing: p1), fallback: "%1$@ percent complete")
        }
      }
      internal enum Thumbnail {
        internal enum Document {
          /// Double-tap to remove
          internal static var hint: String { return A11y.tr("Accessibility", "message_input.attachment_preview.thumbnail.document.hint", fallback: "Double-tap to remove") }
          /// Document: %1$@
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "message_input.attachment_preview.thumbnail.document.label", String(describing: p1), fallback: "Document: %1$@")
          }
        }
        internal enum Image {
          /// Double-tap to remove
          internal static var hint: String { return A11y.tr("Accessibility", "message_input.attachment_preview.thumbnail.image.hint", fallback: "Double-tap to remove") }
          /// Image: %1$@
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "message_input.attachment_preview.thumbnail.image.label", String(describing: p1), fallback: "Image: %1$@")
          }
        }
        internal enum Video {
          /// Double-tap to remove
          internal static var hint: String { return A11y.tr("Accessibility", "message_input.attachment_preview.thumbnail.video.hint", fallback: "Double-tap to remove") }
          /// Video: %1$@
          internal static func label(_ p1: Any) -> String {
            return A11y.tr("Accessibility", "message_input.attachment_preview.thumbnail.video.label", String(describing: p1), fallback: "Video: %1$@")
          }
        }
      }
    }
    internal enum ButtonAttachmentSource {
      /// Double-tap to choose an attachment source
      internal static var hint: String { return A11y.tr("Accessibility", "message_input.button_attachment_source.hint", fallback: "Double-tap to choose an attachment source") }
      /// Add attachment
      internal static var label: String { return A11y.tr("Accessibility", "message_input.button_attachment_source.label", fallback: "Add attachment") }
      internal enum Camera {
        /// Double-tap to open camera
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.button_attachment_source.camera.hint", fallback: "Double-tap to open camera") }
        /// Take photo or video
        internal static var label: String { return A11y.tr("Accessibility", "message_input.button_attachment_source.camera.label", fallback: "Take photo or video") }
      }
      internal enum Files {
        /// Double-tap to browse and select files
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.button_attachment_source.files.hint", fallback: "Double-tap to browse and select files") }
        /// Choose from files
        internal static var label: String { return A11y.tr("Accessibility", "message_input.button_attachment_source.files.label", fallback: "Choose from files") }
      }
      internal enum Photos {
        /// Double-tap to browse and select photos or videos
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.button_attachment_source.photos.hint", fallback: "Double-tap to browse and select photos or videos") }
        /// Choose from photo library
        internal static var label: String { return A11y.tr("Accessibility", "message_input.button_attachment_source.photos.label", fallback: "Choose from photo library") }
      }
    }
    internal enum ButtonSend {
      /// Enter a message to enable sending
      internal static var hintDisabled: String { return A11y.tr("Accessibility", "message_input.button_send.hint_disabled", fallback: "Enter a message to enable sending") }
      /// Double-tap to send a message
      internal static var hintEnabled: String { return A11y.tr("Accessibility", "message_input.button_send.hint_enabled", fallback: "Double-tap to send a message") }
      /// Send message
      internal static var label: String { return A11y.tr("Accessibility", "message_input.button_send.label", fallback: "Send message") }
    }
    internal enum TextField {
      /// Double-tap to edit message
      internal static var hint: String { return A11y.tr("Accessibility", "message_input.text_field.hint", fallback: "Double-tap to edit message") }
      /// Message
      internal static var label: String { return A11y.tr("Accessibility", "message_input.text_field.label", fallback: "Message") }
    }
    internal enum VoiceMessage {
      /// Double-tap to record a voice message
      internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.hint", fallback: "Double-tap to record a voice message") }
      /// Record voice message
      internal static var label: String { return A11y.tr("Accessibility", "message_input.voice_message.label", fallback: "Record voice message") }
      internal enum Delete {
        /// Double-tap to delete the voice message
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.delete.hint", fallback: "Double-tap to delete the voice message") }
        /// Delete recording
        internal static var label: String { return A11y.tr("Accessibility", "message_input.voice_message.delete.label", fallback: "Delete recording") }
      }
      internal enum Length {
        /// Current length of the voice message
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.length.hint", fallback: "Current length of the voice message") }
      }
      internal enum Pause {
        /// Double-tap to pause voice message playback
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.pause.hint", fallback: "Double-tap to pause voice message playback") }
        /// Pause playback
        internal static var label: String { return A11y.tr("Accessibility", "message_input.voice_message.pause.label", fallback: "Pause playback") }
      }
      internal enum Play {
        /// Double-tap to play voice message recording
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.play.hint", fallback: "Double-tap to play voice message recording") }
        /// Play recording
        internal static var label: String { return A11y.tr("Accessibility", "message_input.voice_message.play.label", fallback: "Play recording") }
      }
      internal enum Playing {
        /// Playing recorded voice message
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.playing.hint", fallback: "Playing recorded voice message") }
        /// Playing
        internal static var label: String { return A11y.tr("Accessibility", "message_input.voice_message.playing.label", fallback: "Playing") }
      }
      internal enum Recorded {
        /// Voice message has been recorded
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.recorded.hint", fallback: "Voice message has been recorded") }
        /// Recorded
        internal static var label: String { return A11y.tr("Accessibility", "message_input.voice_message.recorded.label", fallback: "Recorded") }
      }
      internal enum Recording {
        /// Voice message is being recorded
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.recording.hint", fallback: "Voice message is being recorded") }
        /// Recording
        internal static var label: String { return A11y.tr("Accessibility", "message_input.voice_message.recording.label", fallback: "Recording") }
      }
      internal enum Stop {
        /// Double-tap to stop voice message recording
        internal static var hint: String { return A11y.tr("Accessibility", "message_input.voice_message.stop.hint", fallback: "Double-tap to stop voice message recording") }
        /// Stop recording
        internal static var label: String { return A11y.tr("Accessibility", "message_input.voice_message.stop.label", fallback: "Stop recording") }
      }
    }
  }
  internal enum OfflineView {
    internal enum ButtonClose {
      /// Double-tap to close the chat session
      internal static var hint: String { return A11y.tr("Accessibility", "offline_view.button_close.hint", fallback: "Double-tap to close the chat session") }
    }
  }
  internal enum SatisfactionSurvey {
    internal enum ButtonClose {
      /// Double-tap to close the satisfaction survey
      internal static var hint: String { return A11y.tr("Accessibility", "satisfaction_survey.button_close.hint", fallback: "Double-tap to close the satisfaction survey") }
      /// Close satisfaction survey
      internal static var label: String { return A11y.tr("Accessibility", "satisfaction_survey.button_close.label", fallback: "Close satisfaction survey") }
    }
  }
  internal enum ThreadList {
    internal enum Cell {
      /// Double-tap to navigate to the conversation
      internal static var hint: String { return A11y.tr("Accessibility", "thread_list.cell.hint", fallback: "Double-tap to navigate to the conversation") }
      /// %1$@, %2$@, %3$@
      internal static func label(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return A11y.tr("Accessibility", "thread_list.cell.label", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "%1$@, %2$@, %3$@")
      }
      internal enum ButtonArchive {
        /// Double-tap to archive the conversation
        internal static var hint: String { return A11y.tr("Accessibility", "thread_list.cell.button_archive.hint", fallback: "Double-tap to archive the conversation") }
        /// Archive
        internal static var label: String { return A11y.tr("Accessibility", "thread_list.cell.button_archive.label", fallback: "Archive") }
      }
      internal enum ButtonRename {
        /// Double-tap to rename the conversation
        internal static var hint: String { return A11y.tr("Accessibility", "thread_list.cell.button_rename.hint", fallback: "Double-tap to rename the conversation") }
        /// Rename
        internal static var label: String { return A11y.tr("Accessibility", "thread_list.cell.button_rename.label", fallback: "Rename") }
      }
      internal enum Label {
        /// %1$@, %2$@
        internal static func noMessage(_ p1: Any, _ p2: Any) -> String {
          return A11y.tr("Accessibility", "thread_list.cell.label.no_message", String(describing: p1), String(describing: p2), fallback: "%1$@, %2$@")
        }
      }
      internal enum UnreadIndicator {
        /// Unread
        internal static var label: String { return A11y.tr("Accessibility", "thread_list.cell.unread_indicator.label", fallback: "Unread") }
      }
    }
    internal enum EmptyState {
      /// No conversations
      internal static var label: String { return A11y.tr("Accessibility", "thread_list.empty_state.label", fallback: "No conversations") }
    }
    internal enum NavigationBar {
      internal enum ButtonNew {
        /// Double-tap to start a new conversation
        internal static var hint: String { return A11y.tr("Accessibility", "thread_list.navigation_bar.button_new.hint", fallback: "Double-tap to start a new conversation") }
        /// New conversation
        internal static var label: String { return A11y.tr("Accessibility", "thread_list.navigation_bar.button_new.label", fallback: "New conversation") }
      }
    }
  }
  internal enum ValidatedTextField {
    /// Enter %1$@
    internal static func hint(_ p1: Any) -> String {
      return A11y.tr("Accessibility", "validated_text_field.hint", String(describing: p1), fallback: "Enter %1$@")
    }
    /// %1$@, %2$@
    internal static func requiredLabel(_ p1: Any, _ p2: Any) -> String {
      return A11y.tr("Accessibility", "validated_text_field.required_label", String(describing: p1), String(describing: p2), fallback: "%1$@, %2$@")
    }
    internal enum Validation {
      internal enum Invalid {
        /// %1$@, invalid
        internal static func value(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "validated_text_field.validation.invalid.value", String(describing: p1), fallback: "%1$@, invalid")
        }
        internal enum Empty {
          /// Empty, invalid
          internal static var value: String { return A11y.tr("Accessibility", "validated_text_field.validation.invalid.empty.value", fallback: "Empty, invalid") }
        }
      }
      internal enum Valid {
        /// %1$@, valid
        internal static func value(_ p1: Any) -> String {
          return A11y.tr("Accessibility", "validated_text_field.validation.valid.value", String(describing: p1), fallback: "%1$@, valid")
        }
        internal enum Empty {
          /// Empty, valid
          internal static var value: String { return A11y.tr("Accessibility", "validated_text_field.validation.valid.empty.value", fallback: "Empty, valid") }
        }
      }
    }
  }
  internal enum VideoViewer {
    internal enum ButtonClose {
      /// Double-tap to close video player
      internal static var hint: String { return A11y.tr("Accessibility", "video_viewer.button_close.hint", fallback: "Double-tap to close video player") }
      /// Close
      internal static var label: String { return A11y.tr("Accessibility", "video_viewer.button_close.label", fallback: "Close") }
    }
    internal enum ButtonShare {
      /// Double-tap to share the video
      internal static var hint: String { return A11y.tr("Accessibility", "video_viewer.button_share.hint", fallback: "Double-tap to share the video") }
      /// Share
      internal static var label: String { return A11y.tr("Accessibility", "video_viewer.button_share.label", fallback: "Share") }
    }
    internal enum Content {
      /// Use the on-screen controls to play the video
      internal static var hint: String { return A11y.tr("Accessibility", "video_viewer.content.hint", fallback: "Use the on-screen controls to play the video") }
      /// Full screen video
      internal static var label: String { return A11y.tr("Accessibility", "video_viewer.content.label", fallback: "Full screen video") }
    }
  }
}

// MARK: - Implementation Details

extension A11y {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    // 1. Programmatic provider (highest priority)
    if let override = A11y.overrideProvider?.accessibilityString(forKey: key) {
      return args.isEmpty ? override : String(format: override, locale: Locale.current, arguments: args)
    }
    // 2. Integrator's bundle (supports .lproj localization)
    if let bundle = A11y.overrideBundle {
      let fromBundle = bundle.localizedString(forKey: key, value: nil, table: table)
      if fromBundle != key {
        return args.isEmpty ? fromBundle : String(format: fromBundle, locale: Locale.current, arguments: args)
      }
    }
    // 3. SDK's own bundle (default behavior)
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return args.isEmpty ? format : String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
