// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Alert {
    internal enum CameraPermission {
      /// Camera access is required to take photos or record videos. Please allow camera access in Settings.
      internal static let message = L10n.tr("CXOneChatUI", "alert.camera_permission.message", fallback: "Camera access is required to take photos or record videos. Please allow camera access in Settings.")
    }
    internal enum Disconnect {
      /// Disconnect
      internal static let confirm = L10n.tr("CXOneChatUI", "alert.disconnect.confirm", fallback: "Disconnect")
    }
    internal enum DisconnectError {
      /// Oops! The chat encountered an issue and will disconnect. Please try again later.
      internal static let message = L10n.tr("CXOneChatUI", "alert.disconnect_error.message", fallback: "Oops! The chat encountered an issue and will disconnect. Please try again later.")
    }
    internal enum EditPrechatCustomFields {
      /// Edit Pre-chat Form
      internal static let title = L10n.tr("CXOneChatUI", "alert.edit_prechat_custom_fields.title", fallback: "Edit Pre-chat Form")
    }
    internal enum EndConversation {
      /// Are you sure you want to end this conversation?
      internal static let message = L10n.tr("CXOneChatUI", "alert.end_conversation.message", fallback: "Are you sure you want to end this conversation?")
    }
    internal enum FeatureUnavailable {
      /// The chat is not available because the '%1$@' feature is not implemented. Check the documentation for more information.
      internal static func message(_ p1: Any) -> String {
        return L10n.tr("CXOneChatUI", "alert.feature_unavailable.message", String(describing: p1), fallback: "The chat is not available because the '%1$@' feature is not implemented. Check the documentation for more information.")
      }
    }
    internal enum FileValidation {
      /// Oops!
      internal static let title = L10n.tr("CXOneChatUI", "alert.file_validation.title", fallback: "Oops!")
    }
    internal enum GenericError {
      /// Something went wrong. Please, try again later.
      internal static let message = L10n.tr("CXOneChatUI", "alert.generic_error.message", fallback: "Something went wrong. Please, try again later.")
    }
    internal enum InvalidFileSize {
      /// Unable to upload attachment(s). Attachment(s) size greater than %1$d MB
      internal static func message(_ p1: Int) -> String {
        return L10n.tr("CXOneChatUI", "alert.invalid_file_size.message", p1, fallback: "Unable to upload attachment(s). Attachment(s) size greater than %1$d MB")
      }
    }
    internal enum InvalidFileType {
      /// Unable to upload attachment(s) due to invalid file type.
      internal static let message = L10n.tr("CXOneChatUI", "alert.invalid_file_type.message", fallback: "Unable to upload attachment(s) due to invalid file type.")
    }
    internal enum MicrophonePermission {
      /// Microphone access is required to record a voice message. Please allow microphone access in Settings.
      internal static let message = L10n.tr("CXOneChatUI", "alert.microphone_permission.message", fallback: "Microphone access is required to record a voice message. Please allow microphone access in Settings.")
    }
    internal enum SendTranscript {
      /// Unable to send transcript. Please try again later.
      internal static let errorMessage = L10n.tr("CXOneChatUI", "alert.send_transcript.error_message", fallback: "Unable to send transcript. Please try again later.")
      /// Chat transcript successfully sent
      internal static let success = L10n.tr("CXOneChatUI", "alert.send_transcript.success", fallback: "Chat transcript successfully sent")
      /// Send Transcript
      internal static let title = L10n.tr("CXOneChatUI", "alert.send_transcript.title", fallback: "Send Transcript")
    }
    internal enum UpdateThreadName {
      /// Conversation name
      internal static let placeholder = L10n.tr("CXOneChatUI", "alert.update_thread_name.placeholder", fallback: "Conversation name")
      /// Rename Conversation
      internal static let title = L10n.tr("CXOneChatUI", "alert.update_thread_name.title", fallback: "Rename Conversation")
    }
  }
  internal enum Chat {
    internal enum Attachments {
      /// None
      internal static let deselect = L10n.tr("CXOneChatUI", "chat.attachments.deselect", fallback: "None")
      /// Select items
      internal static let selectionMode = L10n.tr("CXOneChatUI", "chat.attachments.selection_mode", fallback: "Select items")
      /// Uploading...
      internal static let upload = L10n.tr("CXOneChatUI", "chat.attachments.upload", fallback: "Uploading...")
      internal enum Download {
        /// Error downloading file
        internal static let documentError = L10n.tr("CXOneChatUI", "chat.attachments.download.document_error", fallback: "Error downloading file")
      }
      internal enum Loading {
        /// Loading document...
        internal static let document = L10n.tr("CXOneChatUI", "chat.attachments.loading.document", fallback: "Loading document...")
        /// Loading document failed
        internal static let documentError = L10n.tr("CXOneChatUI", "chat.attachments.loading.document_error", fallback: "Loading document failed")
        /// Loading video...
        internal static let video = L10n.tr("CXOneChatUI", "chat.attachments.loading.video", fallback: "Loading video...")
      }
      internal enum SelectedCount {
        /// %1$d item(s) selected
        internal static func message(_ p1: Int) -> String {
          return L10n.tr("CXOneChatUI", "chat.attachments.selected_count.message", p1, fallback: "%1$d item(s) selected")
        }
      }
      internal enum Selection {
        /// All
        internal static let all = L10n.tr("CXOneChatUI", "chat.attachments.selection.all", fallback: "All")
      }
    }
    internal enum FallbackMessage {
      /// %1$d attachment(s)
      internal static func attachments(_ p1: Int) -> String {
        return L10n.tr("CXOneChatUI", "chat.fallback_message.attachments", p1, fallback: "%1$d attachment(s)")
      }
      /// No name
      internal static let noName = L10n.tr("CXOneChatUI", "chat.fallback_message.no_name", fallback: "No name")
      /// Unknown message
      internal static let unknown = L10n.tr("CXOneChatUI", "chat.fallback_message.unknown", fallback: "Unknown message")
      internal enum Torm {
        /// List picker message
        internal static let listPicker = L10n.tr("CXOneChatUI", "chat.fallback_message.torm.list_picker", fallback: "List picker message")
        /// Quick replies message
        internal static let quickReplies = L10n.tr("CXOneChatUI", "chat.fallback_message.torm.quick_replies", fallback: "Quick replies message")
        /// Rich link message
        internal static let richLink = L10n.tr("CXOneChatUI", "chat.fallback_message.torm.rich_link", fallback: "Rich link message")
        /// Time picker message
        internal static let timePicker = L10n.tr("CXOneChatUI", "chat.fallback_message.torm.time_picker", fallback: "Time picker message")
      }
      internal enum UnknownTooltip {
        /// This message could not be displayed in the chat as it uses a format that is currently unsupported.
        internal static let content = L10n.tr("CXOneChatUI", "chat.fallback_message.unknown_tooltip.content", fallback: "This message could not be displayed in the chat as it uses a format that is currently unsupported.")
        /// Why do I see this
        internal static let text = L10n.tr("CXOneChatUI", "chat.fallback_message.unknown_tooltip.text", fallback: "Why do I see this")
      }
    }
    internal enum MenuOption {
      /// Edit Pre-chat Form
      internal static let editCustomFields = L10n.tr("CXOneChatUI", "chat.menu_option.edit_custom_fields", fallback: "Edit Pre-chat Form")
      /// End conversation
      internal static let endConversation = L10n.tr("CXOneChatUI", "chat.menu_option.end_conversation", fallback: "End conversation")
      /// Send Transcript
      internal static let sendTranscript = L10n.tr("CXOneChatUI", "chat.menu_option.send_transcript", fallback: "Send Transcript")
      /// Rename Conversation
      internal static let updateName = L10n.tr("CXOneChatUI", "chat.menu_option.update_name", fallback: "Rename Conversation")
    }
    internal enum Message {
      internal enum ListPicker {
        /// Done
        internal static let sheetConfirm = L10n.tr("CXOneChatUI", "chat.message.list_picker.sheet_confirm", fallback: "Done")
      }
      internal enum QuickReplies {
        /// Select one option below
        internal static let selectOneOption = L10n.tr("CXOneChatUI", "chat.message.quick_replies.select_one_option", fallback: "Select one option below")
      }
      internal enum RichContent {
        /// Option selected
        internal static let optionSelected = L10n.tr("CXOneChatUI", "chat.message.rich_content.option_selected", fallback: "Option selected")
        /// Options unavailable
        internal static let optionsDisabled = L10n.tr("CXOneChatUI", "chat.message.rich_content.options_disabled", fallback: "Options unavailable")
        /// These options are no longer visible because you've already responded or the message is no longer the most recent.
        internal static let optionsDisabledTooltip = L10n.tr("CXOneChatUI", "chat.message.rich_content.options_disabled_tooltip", fallback: "These options are no longer visible because you've already responded or the message is no longer the most recent.")
        /// Press to open
        internal static let pressToOpen = L10n.tr("CXOneChatUI", "chat.message.rich_content.press_to_open", fallback: "Press to open")
      }
      internal enum TimePicker {
        /// %@, %@ min
        internal static func formatted(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("CXOneChatUI", "chat.message.time_picker.formatted", String(describing: p1), String(describing: p2), fallback: "%@, %@ min")
        }
      }
    }
    internal enum MessageInput {
      /// This conversation was archived.
      internal static let archived = L10n.tr("CXOneChatUI", "chat.message_input.archived", fallback: "This conversation was archived.")
      /// This conversation was closed.
      internal static let closed = L10n.tr("CXOneChatUI", "chat.message_input.closed", fallback: "This conversation was closed.")
      /// Aa
      internal static let placeholder = L10n.tr("CXOneChatUI", "chat.message_input.placeholder", fallback: "Aa")
      internal enum AttachmentsOption {
        /// Camera
        internal static let camera = L10n.tr("CXOneChatUI", "chat.message_input.attachments_option.camera", fallback: "Camera")
        /// File manager
        internal static let files = L10n.tr("CXOneChatUI", "chat.message_input.attachments_option.files", fallback: "File manager")
        /// Photo library
        internal static let photos = L10n.tr("CXOneChatUI", "chat.message_input.attachments_option.photos", fallback: "Photo library")
        /// Attachment source
        internal static let title = L10n.tr("CXOneChatUI", "chat.message_input.attachments_option.title", fallback: "Attachment source")
      }
      internal enum AudioRecorder {
        /// Playing
        internal static let playing = L10n.tr("CXOneChatUI", "chat.message_input.audio_recorder.playing", fallback: "Playing")
        /// Audio message
        internal static let recorded = L10n.tr("CXOneChatUI", "chat.message_input.audio_recorder.recorded", fallback: "Audio message")
        /// Recording
        internal static let recording = L10n.tr("CXOneChatUI", "chat.message_input.audio_recorder.recording", fallback: "Recording")
      }
    }
  }
  internal enum ChatList {
    /// No conversations
    internal static let empty = L10n.tr("CXOneChatUI", "chat_list.empty", fallback: "No conversations")
    /// New conversation
    internal static let newThread = L10n.tr("CXOneChatUI", "chat_list.new_thread", fallback: "New conversation")
    /// Conversations
    internal static let title = L10n.tr("CXOneChatUI", "chat_list.title", fallback: "Conversations")
    internal enum ThreadStatus {
      /// Archived
      internal static let archived = L10n.tr("CXOneChatUI", "chat_list.thread_status.archived", fallback: "Archived")
      /// Current
      internal static let current = L10n.tr("CXOneChatUI", "chat_list.thread_status.current", fallback: "Current")
    }
  }
  internal enum ChatThread {
    internal enum ContextMenu {
      /// Archive
      internal static let archive = L10n.tr("CXOneChatUI", "chat_thread.context_menu.archive", fallback: "Archive")
      /// Rename
      internal static let rename = L10n.tr("CXOneChatUI", "chat_thread.context_menu.rename", fallback: "Rename")
    }
  }
  internal enum Common {
    /// Agent
    internal static let agent = L10n.tr("CXOneChatUI", "common.agent", fallback: "Agent")
    /// AI Assistant
    internal static let aiAssistant = L10n.tr("CXOneChatUI", "common.ai_assistant", fallback: "AI Assistant")
    /// Attachments
    internal static let attachments = L10n.tr("CXOneChatUI", "common.attachments", fallback: "Attachments")
    /// Attention
    internal static let attention = L10n.tr("CXOneChatUI", "common.attention", fallback: "Attention")
    /// Cancel
    internal static let cancel = L10n.tr("CXOneChatUI", "common.cancel", fallback: "Cancel")
    /// Close chat
    internal static let closeChat = L10n.tr("CXOneChatUI", "common.close_chat", fallback: "Close chat")
    /// Confirm
    internal static let confirm = L10n.tr("CXOneChatUI", "common.confirm", fallback: "Confirm")
    /// Connecting...
    internal static let connecting = L10n.tr("CXOneChatUI", "common.connecting", fallback: "Connecting...")
    /// Copy
    internal static let copy = L10n.tr("CXOneChatUI", "common.copy", fallback: "Copy")
    /// Error
    internal static let error = L10n.tr("CXOneChatUI", "common.error", fallback: "Error")
    /// Fields do not match
    internal static let fieldsDontMatch = L10n.tr("CXOneChatUI", "common.fields_dont_match", fallback: "Fields do not match")
    /// Invalid email
    internal static let invalidEmail = L10n.tr("CXOneChatUI", "common.invalid_email", fallback: "Invalid email")
    /// Invalid number
    internal static let invalidNumber = L10n.tr("CXOneChatUI", "common.invalid_number", fallback: "Invalid number")
    /// Loading...
    internal static let loading = L10n.tr("CXOneChatUI", "common.loading", fallback: "Loading...")
    /// No selection
    internal static let noSelection = L10n.tr("CXOneChatUI", "common.no_selection", fallback: "No selection")
    /// Ok
    internal static let ok = L10n.tr("CXOneChatUI", "common.ok", fallback: "Ok")
    /// Required field
    internal static let `required` = L10n.tr("CXOneChatUI", "common.required", fallback: "Required field")
    /// Select
    internal static let select = L10n.tr("CXOneChatUI", "common.select", fallback: "Select")
    /// Settings
    internal static let settings = L10n.tr("CXOneChatUI", "common.settings", fallback: "Settings")
    /// Share
    internal static let share = L10n.tr("CXOneChatUI", "common.share", fallback: "Share")
    /// Submit
    internal static let submit = L10n.tr("CXOneChatUI", "common.submit", fallback: "Submit")
    /// Try again
    internal static let tryAgain = L10n.tr("CXOneChatUI", "common.try_again", fallback: "Try again")
    /// No agent
    internal static let unassignedAgent = L10n.tr("CXOneChatUI", "common.unassigned_agent", fallback: "No agent")
  }
  internal enum Form {
    /// %@ *
    internal static func requiredLabel(_ p1: Any) -> String {
      return L10n.tr("CXOneChatUI", "form.required_label", String(describing: p1), fallback: "%@ *")
    }
    internal enum TimePicker {
      /// Please select a preferred time slot
      internal static let subtitle = L10n.tr("CXOneChatUI", "form.time_picker.subtitle", fallback: "Please select a preferred time slot")
      internal enum TimeSlot {
        /// %d min
        internal static func duration(_ p1: Int) -> String {
          return L10n.tr("CXOneChatUI", "form.time_picker.time_slot.duration", p1, fallback: "%d min")
        }
      }
    }
  }
  internal enum LiveChat {
    internal enum EndConversation {
      /// You chatted with
      internal static let assignedAgent = L10n.tr("CXOneChatUI", "live_chat.end_conversation.assigned_agent", fallback: "You chatted with")
      /// Back to conversation
      internal static let back = L10n.tr("CXOneChatUI", "live_chat.end_conversation.back", fallback: "Back to conversation")
      /// This conversation was closed
      internal static let defaultTitle = L10n.tr("CXOneChatUI", "live_chat.end_conversation.default_title", fallback: "This conversation was closed")
      /// Start a new chat
      internal static let new = L10n.tr("CXOneChatUI", "live_chat.end_conversation.new", fallback: "Start a new chat")
    }
    internal enum InactivityPopup {
      internal enum SessionTimeout {
        /// This conversation will now end due to inactivity
        internal static let text = L10n.tr("CXOneChatUI", "live_chat.inactivity_popup.session_timeout.text", fallback: "This conversation will now end due to inactivity")
        /// Time is up
        internal static let title = L10n.tr("CXOneChatUI", "live_chat.inactivity_popup.session_timeout.title", fallback: "Time is up")
      }
    }
    internal enum Offline {
      /// Please check back soon.
      internal static let message = L10n.tr("CXOneChatUI", "live_chat.offline.message", fallback: "Please check back soon.")
      /// We are currently offline
      internal static let title = L10n.tr("CXOneChatUI", "live_chat.offline.title", fallback: "We are currently offline")
    }
    internal enum Queue {
      /// Please hold, we'll be with you shortly. Your patience is appreciated!
      internal static let subtitle = L10n.tr("CXOneChatUI", "live_chat.queue.subtitle", fallback: "Please hold, we'll be with you shortly. Your patience is appreciated!")
      /// You are number %1$d in line
      internal static func title(_ p1: Int) -> String {
        return L10n.tr("CXOneChatUI", "live_chat.queue.title", p1, fallback: "You are number %1$d in line")
      }
    }
  }
  internal enum Overlay {
    internal enum LoadingDelay {
      /// The operation is taking longer than expected.
      internal static let title = L10n.tr("CXOneChatUI", "overlay.loading_delay.title", fallback: "The operation is taking longer than expected.")
    }
  }
  internal enum PreChatSurvey {
    /// Please fill out all fields and submit the form.
    internal static let subtitle = L10n.tr("CXOneChatUI", "pre_chat_survey.subtitle", fallback: "Please fill out all fields and submit the form.")
  }
  internal enum SendTranscript {
    /// We do not share submitted emails with any 3rd party affiliate marketing or offer programs
    internal static let subtitle = L10n.tr("CXOneChatUI", "send_transcript.subtitle", fallback: "We do not share submitted emails with any 3rd party affiliate marketing or offer programs")
    /// Chat Transcript
    internal static let title = L10n.tr("CXOneChatUI", "send_transcript.title", fallback: "Chat Transcript")
    internal enum ConfirmEmail {
      /// Confirm e-mail
      internal static let label = L10n.tr("CXOneChatUI", "send_transcript.confirm_email.label", fallback: "Confirm e-mail")
      /// Confirm your e-mail address
      internal static let placeholder = L10n.tr("CXOneChatUI", "send_transcript.confirm_email.placeholder", fallback: "Confirm your e-mail address")
    }
    internal enum Email {
      /// E-mail
      internal static let label = L10n.tr("CXOneChatUI", "send_transcript.email.label", fallback: "E-mail")
      /// Enter your e-mail address
      internal static let placeholder = L10n.tr("CXOneChatUI", "send_transcript.email.placeholder", fallback: "Enter your e-mail address")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  internal static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    // 1. Programmatic provider (highest priority)
    if let override = L10n.overrideProvider?.localizationString(forKey: key) {
      return String(format: override, locale: Locale.current, arguments: args)
    }
    // 2. Integrator's bundle (supports .lproj localization)
    if let bundle = L10n.overrideBundle {
      let fromBundle = bundle.localizedString(forKey: key, value: nil, table: table)
      if fromBundle != key {
        return String(format: fromBundle, locale: Locale.current, arguments: args)
      }
    }
    // 3. SDK's own bundle (default behavior)
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
