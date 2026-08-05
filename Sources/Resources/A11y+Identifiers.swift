//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

// MARK: - Chat Container

// MARK: Navigation Bar

extension A11y.ChatContainer.NavigationBar.ButtonClose {
    /// `chat_container.navigation_bar.button_close`
    static let identifier = "chat_container.navigation_bar.button_close"
}

extension A11y.ChatContainer.NavigationBar.ButtonMenu {
    /// `chat_container.navigation_bar.button_menu`
    static let identifier = "chat_container.navigation_bar.button_menu"
}

extension A11y.ChatContainer.NavigationBar.ButtonMenu.Option {
    /// `chat_container.navigation_bar.button_menu.option.\(param)`
    static func identifier(_ param: String) -> String {
        "chat_container.navigation_bar.button_menu.option.\(param)"
    }
}

// MARK: Alert

extension A11y.ChatContainer.Alert.ButtonCancel {
    /// `chat_container.alert.button_cancel`
    static let identifier = "chat_container.alert.button_cancel"
}

extension A11y.ChatContainer.Alert.GenericError.ButtonCancel {
    /// `chat_container.alert.generic_error.button_cancel`
    static let identifier = "chat_container.alert.generic_error.button_cancel"
}

extension A11y.ChatContainer.Alert.CameraPermissionDenied.ButtonSettings {
    /// `chat_container.alert.camera_permission_denied.button_settings`
    static let identifier = "chat_container.alert.camera_permission_denied.button_settings"
}

extension A11y.ChatContainer.Alert.MicrophonePermissionDenied.ButtonSettings {
    /// `chat_container.alert.microphone_permission_denied.button_settings`
    static let identifier = "chat_container.alert.microphone_permission_denied.button_settings"
}

extension A11y.ChatContainer.Alert.ConnectionError.ButtonDisconnect {
    /// `chat_container.alert.connection_error.button_disconnect`
    static let identifier = "chat_container.alert.connection_error.button_disconnect"
}

extension A11y.ChatContainer.Alert.FeatureUnavailable.ButtonDisconnect {
    /// `chat_container.alert.feature_unavailable.button_disconnect`
    static let identifier = "chat_container.alert.feature_unavailable.button_disconnect"
}

extension A11y.ChatContainer.Alert.EndConversation.ButtonConfirm {
    /// `chat_container.alert.end_conversation.button_confirm`
    static let identifier = "chat_container.alert.end_conversation.button_confirm"
}

// MARK: - Chat Overlay

extension A11y.ChatOverlay.Loading.ButtonDelay {
    /// `chat_overlay.loading.button_delay`
    static let identifier = "chat_overlay.loading.button_delay"
}

// MARK: - Offline View

extension A11y.OfflineView.ButtonClose {
    /// `offline_view.button_close`
    static let identifier = "offline_view.button_close"
}

// MARK: - Thread List

extension A11y.ThreadList.NavigationBar.ButtonNew {
    /// `thread_list.navigation_bar.button_new`
    static let identifier = "thread_list.navigation_bar.button_new"
}

extension A11y.ThreadList.EmptyState {
    /// `thread_list.empty_state`
    static let identifier = "thread_list.empty_state"
}

// MARK: Cell

extension A11y.ThreadList.Cell {
    /// `thread_list.cell`
    static let identifier = "thread_list.cell"

    /// `thread_list.cell.\(threadId)`
    static func identifier(_ threadId: String) -> String {
        "thread_list.cell.\(threadId)"
    }
}

extension A11y.ThreadList.Cell.UnreadIndicator {
    /// `thread_list.cell.unread_indicator`
    static let identifier = "thread_list.cell.unread_indicator"
}

extension A11y.ThreadList.Cell.ButtonArchive {
    /// `thread_list.cell.button_archive`
    static let identifier = "thread_list.cell.button_archive"
}

extension A11y.ThreadList.Cell.ButtonRename {
    /// `thread_list.cell.button_rename`
    static let identifier = "thread_list.cell.button_rename"
}

// MARK: - Alert

extension A11y {

    // Hand-declared namespace (no backing accessibility strings). Shared by the "update thread name"
    // alert text field, which is presented from both the thread list and an open thread.
    enum Alert {

        enum UpdateThreadName {
            /// `alert.update_thread_name.text_field`
            static let identifier = "alert.update_thread_name.text_field"
        }
    }
}

// MARK: - Form

extension A11y.Form {

    enum Header {
        /// `form.header.title`
        static let titleIdentifier = "form.header.title"
        /// `form.header.subtitle`
        static let subtitleIdentifier = "form.header.subtitle"
    }

    // Hand-declared namespace (no backing `form.text_field_view.*` accessibility strings) so the
    // field identifier survives independently of SwiftGen output. The label/value/hint for these
    // fields are provided by the inner `ValidatedTextField` on the editable `TextField` element.
    enum TextFieldView {
        /// `form.text_field_view.\(param)`
        static func identifier(_ param: String) -> String {
            "form.text_field_view.\(param)"
        }
    }
}

extension A11y.Form.ButtonCancel {
    /// `form.button_cancel`
    static let identifier = "form.button_cancel"
}

extension A11y.Form.ButtonConfirm {
    /// `form.button_confirm`
    static let identifier = "form.button_confirm"
}

// MARK: - Form+TreeFieldView

extension A11y.Form.TreeFieldView.Title {
    /// `form.tree_field_view.title.\(param)`
    static func identifier(_ param: String) -> String {
        "form.tree_field_view.title.\(param)"
    }
}

extension A11y.Form.TreeFieldView.Content {
    enum Parent {
        /// `form.tree_field_view.content.parent.\(param)`
        static func identifier(_ param: String) -> String {
            "form.tree_field_view.content.parent.\(param)"
        }
    }
}

extension A11y.Form.TreeFieldView.Content.Leaf {
    /// `form.tree_field_view.content.leaf.\(param)`
    static func identifier(_ param: String) -> String {
        "form.tree_field_view.content.leaf.\(param)"
    }
}

// MARK: - Form+ListFieldView

extension A11y.Form.ListFieldView.Content {
    static func identifier(_ param: String) -> String {
        "form.list_field_view.content.\(param)"
    }
}

extension A11y.Form.ListFieldView.Sheet.Option {
    /// `form.list_field_view.sheet.option.\(param)`
    static func identifier(_ param: String) -> String {
        "form.list_field_view.sheet.option.\(param)"
    }
}

extension A11y.Form.ListFieldView.Sheet.Option.Cancel {
    /// `form.list_field_view.sheet.option.cancel`
    static let identifier = "form.list_field_view.sheet.option.cancel"
}

// MARK: - Image Viewer

extension A11y.ImageViewer.ButtonClose {
    /// `image_viewer.button_close`
    static let identifier = "image_viewer.button_close"
}

extension A11y.ImageViewer.Content {
    /// `image_viewer.content`
    static let identifier = "image_viewer.content"
}

// MARK: - Conversation

// MARK: AI Authorship Indicator

extension A11y.Conversation.AiAssistantBadge {
    /// `conversation.ai_assistant_badge`
    static let identifier = "conversation.ai_assistant_badge"
}

// MARK: Typing Indicator

extension A11y.Conversation.TypingIndicator {
    /// `conversation.typing_indicator`
    static let identifier = "conversation.typing_indicator"
}

// MARK: Message

extension A11y.Conversation.MessageCell {
    /// `conversation.message_cell`
    static let identifier = "conversation.message_cell"
}

extension A11y.Conversation.MessageCell.Status {
    /// `conversation.message_cell.status`
    static let identifier = "conversation.message_cell.status"
}

// MARK: Message+RichContent

extension A11y.Conversation.MessageCell {

    enum PressToOpen {
        /// `conversation.message_cell.press_to_open`
        static let identifier = "conversation.message_cell.press_to_open"
    }
}

extension A11y.Conversation.MessageCell.OptionSelected {
    /// `conversation.message_cell.option_selected`
    static let identifier = "conversation.message_cell.option_selected"
}

// MARK: Message+Tooltip

extension A11y.Conversation.MessageCell.Tooltip {
    /// `conversation.message_cell.tooltip`
    static let identifier = "conversation.message_cell.tooltip"

    enum Content {
        /// `conversation.message_cell.tooltip.content`
        static let identifier = "conversation.message_cell.tooltip.content"
    }
}

// MARK: Message+Audio

extension A11y.Conversation.MessageCell.Audio.SeekBar {
    /// `conversation.message_cell.audio.seek_bar`
    static let identifier = "conversation.message_cell.audio.seek_bar"
}

extension A11y.Conversation.MessageCell.Audio.ButtonRewind {
    /// `conversation.message_cell.audio.button_rewind`
    static let identifier = "conversation.message_cell.audio.button_rewind"
}

extension A11y.Conversation.MessageCell.Audio.ButtonPlay {
    /// `conversation.message_cell.audio.button_play`
    static let identifier = "conversation.message_cell.audio.button_play"
}

extension A11y.Conversation.MessageCell.Audio.ButtonPause {
    /// `conversation.message_cell.audio.button_pause`
    static let identifier = "conversation.message_cell.audio.button_pause"
}

extension A11y.Conversation.MessageCell.Audio.ButtonAdvance {
    /// `conversation.message_cell.audio.button_advance`
    static let identifier = "conversation.message_cell.audio.button_advance"
}

// MARK: Message+RichLink

extension A11y.Conversation.MessageCell.RichLink {
    enum Title {
        /// `conversation.message_cell.rich_link.title`
        static let identifier = "conversation.message_cell.rich_link.title"
    }
    enum Host {
        /// `conversation.message_cell.rich_link.host`
        static let identifier = "conversation.message_cell.rich_link.host"
    }
}

extension A11y.Conversation.MessageCell.RichLink.ContextMenu.ButtonShare {
    /// `conversation.message_cell.rich_link.context_menu.button_share`
    static let identifier = "conversation.message_cell.rich_link.context_menu.button_share"
}

extension A11y.Conversation.MessageCell.RichLink.ContextMenu.ButtonCopy {
    /// `conversation.message_cell.rich_link.context_menu.button_copy`
    static let identifier = "conversation.message_cell.rich_link.context_menu.button_copy"
}

// MARK: Message+List Picker

extension A11y.Conversation.MessageCell.ListPicker {
    /// `conversation.message_cell.list_picker`
    static let identifier = "conversation.message_cell.list_picker"

    enum Title {
        /// `conversation.message_cell.list_picker.title`
        static let identifier = "conversation.message_cell.list_picker.title"
    }
    enum Message {
        /// `conversation.message_cell.list_picker.message`
        static let identifier = "conversation.message_cell.list_picker.message"
    }
}

extension A11y.Conversation.MessageCell.ListPicker.Sheet {
    enum Title {
        /// `conversation.message_cell.list_picker.sheet.title`
        static let identifier = "conversation.message_cell.list_picker.sheet.title"
    }
    enum Message {
        /// `conversation.message_cell.list_picker.sheet.message`
        static let identifier = "conversation.message_cell.list_picker.sheet.message"
    }
}

extension A11y.Conversation.MessageCell.ListPicker.Sheet.Cell {
    /// `conversation.message_cell.list_picker.sheet.cell.\(param)`
    static func identifier(_ param: String) -> String {
        "conversation.message_cell.list_picker.sheet.cell.\(param)"
    }
}

extension A11y.Conversation.MessageCell.ListPicker.Sheet.Cell.Check {
    /// `conversation.message_cell.list_picker.sheet.cell.check`
    static let identifier = "conversation.message_cell.list_picker.sheet.cell.check"
}

extension A11y.Conversation.MessageCell.ListPicker.Sheet.ButtonCancel {
    /// `conversation.message_cell.list_picker.sheet.button_cancel`
    static let identifier = "conversation.message_cell.list_picker.sheet.button_cancel"
}

extension A11y.Conversation.MessageCell.ListPicker.Sheet.ButtonConfirm {
    /// `conversation.message_cell.list_picker.sheet.button_confirm`
    static let identifier = "conversation.message_cell.list_picker.sheet.button_confirm"
}

// MARK: Message+TimePicker

extension A11y.Conversation.MessageCell.TimePicker {
    /// `conversation.message_cell.time_picker`
    static let identifier = "conversation.message_cell.time_picker"

    enum Title {
        /// `conversation.message_cell.time_picker.title`
        static let identifier = "conversation.message_cell.time_picker.title"
    }
}

extension A11y.Conversation.MessageCell.TimePicker.Sheet {
    enum Title {
        /// `conversation.message_cell.time_picker.sheet.title`
        static let identifier = "conversation.message_cell.time_picker.sheet.title"
    }
    enum Message {
        /// `conversation.message_cell.time_picker.sheet.message`
        static let identifier = "conversation.message_cell.time_picker.sheet.message"
    }
    enum TimeSlots {
        /// `conversation.message_cell.time_picker.sheet.time_slots.\(day)`
        static func identifier(day: String) -> String {
            "conversation.message_cell.time_picker.sheet.time_slots.\(day)"
        }

        enum Slot {
            static func identifier(id: String) -> String {
                "conversation.message_cell.time_picker.sheet.time_slots.option.\(id)"
            }
        }
    }
}

// MARK: Message+Quick Replies

extension A11y.Conversation.MessageCell.QuickReplies {
    enum Title {
        /// `conversation.message_cell.quick_replies.title`
        static let identifier = "conversation.message_cell.quick_replies.title"
    }
    enum InstructionText {
        /// `conversation.message_cell.quick_replies.instruction_text`
        static let identifier = "conversation.message_cell.quick_replies.instruction_text"
    }
}

extension A11y.Conversation.MessageCell.QuickReplies.Option {
    /// `conversation.message_cell.quick_replies.option.\(param)`
    static func identifier(_ param: String) -> String {
        "conversation.message_cell.quick_replies.option.\(param)"
    }
}

// MARK: Attachment(s)

extension A11y.Conversation.MessageCell.Attachment {
    /// `conversation.message_cell.attachment.\(type)` (image | video | document)
    static func identifier(type: String) -> String {
        "conversation.message_cell.attachment.\(type)"
    }
}

extension A11y.Conversation.MessageCell.Attachment.Video.Failed {
    /// `conversation.message_cell.attachment.video.failed`
    static let identifier = "conversation.message_cell.attachment.video.failed"
}

extension A11y.Conversation.MessageCell.Attachment.Video.Loading {
    /// `conversation.message_cell.attachment.video.loading`
    static let identifier = "conversation.message_cell.attachment.video.loading"
}

extension A11y.Conversation.MessageCell.Attachment.ButtonShare {
    /// `conversation.message_cell.attachment.button_share`
    static let identifier = "conversation.message_cell.attachment.button_share"
}

extension A11y.Conversation.MessageCell.Attachment.Failed {
    /// `conversation.message_cell.attachment.failed`
    static let identifier = "conversation.message_cell.attachment.failed"
}

extension A11y.Conversation.MessageCell.Attachment.Audio {
    /// `conversation.message_cell.attachment.audio`
    static let identifier = "conversation.message_cell.attachment.audio"
}

extension A11y.Conversation.MessageCell.Attachment.Audio.ProgressBar {
    /// `conversation.message_cell.attachment.audio.progress_bar`
    static let identifier = "conversation.message_cell.attachment.audio.progress_bar"
}

extension A11y.Conversation.MessageCell.Attachment.Audio.ButtonRewind {
    /// `conversation.message_cell.attachment.audio.button_rewind`
    static let identifier = "conversation.message_cell.attachment.audio.button_rewind"
}

extension A11y.Conversation.MessageCell.Attachment.Audio.ButtonPlay {
    /// `conversation.message_cell.attachment.audio.button_play`
    static let identifier = "conversation.message_cell.attachment.audio.button_play"
}

extension A11y.Conversation.MessageCell.Attachment.Audio.ButtonPause {
    /// `conversation.message_cell.attachment.audio.button_pause`
    static let identifier = "conversation.message_cell.attachment.audio.button_pause"
}

extension A11y.Conversation.MessageCell.Attachment.Audio.ButtonAdvance {
    /// `conversation.message_cell.attachment.audio.button_advance`
    static let identifier = "conversation.message_cell.attachment.audio.button_advance"
}

extension A11y.Conversation.MessageCell.MultipleAttachments.Container {
    /// `conversation.message_cell.multiple_attachments.container`
    static let identifier = "conversation.message_cell.multiple_attachments.container"
}

extension A11y.Conversation.MessageCell.MultipleAttachments.MoreIndicator {
    /// `conversation.message_cell.multiple_attachments.more_indicator`
    static let identifier = "conversation.message_cell.multiple_attachments.more_indicator"
}

extension A11y.Conversation.MessageCell.MultipleAttachments.ButtonShare {
    /// `conversation.message_cell.multiple_attachments.button_share`
    static let identifier = "conversation.message_cell.multiple_attachments.button_share"
}

// MARK: Unsupported Message

extension A11y.Conversation.MessageCell {
    enum Unsupported {
        /// `conversation.message_cell.unsupported_message`
        static let identifier = "conversation.message_cell.unsupported_message"
    }
}

// MARK: - Attachments View

extension A11y.AttachmentsView.Title {
    /// `attachments_view.title`
    static let identifier = "attachments_view.title"
}

extension A11y.AttachmentsView.ButtonSelect {
    /// `attachments_view.button_select`
    static let identifier = "attachments_view.button_select"
}

extension A11y.AttachmentsView.ButtonCancel {
    /// `attachments_view.button_cancel`
    static let identifier = "attachments_view.button_cancel"
}

extension A11y.AttachmentsView.Item.Image {
    /// `attachments_view.item.image`
    static let identifier: String = "attachments_view.item.image"
}

extension A11y.AttachmentsView.Item.Document {
    /// `attachments_view.item.document`
    static let identifier: String = "attachments_view.item.document"
}

extension A11y.AttachmentsView.Item.Video {
    /// `attachments_view.item.video`
    static let identifier: String = "attachments_view.item.video"
}

extension A11y.AttachmentsView.ButtonSelectAll {
    /// `attachments_view.button_select_all`
    static let identifier = "attachments_view.button_select_all"
}

extension A11y.AttachmentsView.ButtonDeselect {
    /// `attachments_view.button_deselect`
    static let identifier = "attachments_view.button_deselect"
}

extension A11y.AttachmentsView.ButtonShare {
    /// `attachments_view.button_share`
    static let identifier = "attachments_view.button_share"
}

extension A11y.AttachmentsView.Status {
    /// `attachments_view.status.\(param)` (selection_mode|selected_count)
    static func identifier(_ param: String) -> String {
        "attachments_view.status.\(param)"
    }
}

// MARK: - Message Input

// MARK: Textfield

extension A11y.MessageInput.TextField {
    /// `message_input.text_field`
    static let identifier = "message_input.text_field"
}

// MARK: Send

extension A11y.MessageInput.ButtonSend {
    /// `message_input.button_send`
    static let identifier = "message_input.button_send"
}

// MARK: Attachment Source

extension A11y.MessageInput.ButtonAttachmentSource {
    /// `message_input.button_attachment_source`
    static let identifier = "message_input.button_attachment_source"
}

extension A11y.MessageInput.ButtonAttachmentSource.Files {
    /// `message_input.button_attachment_source.files`
    static let identifier = "message_input.button_attachment_source.files"
}

extension A11y.MessageInput.ButtonAttachmentSource.Photos {
    /// `message_input.button_attachment_source.photos`
    static let identifier = "message_input.button_attachment_source.photos"
}

extension A11y.MessageInput.ButtonAttachmentSource.Camera {
    /// `message_input.button_attachment_source.camera`
    static let identifier = "message_input.button_attachment_source.camera"
}

// MARK: Attachment(s) Preview

extension A11y.MessageInput.AttachmentPreview.Thumbnail.Image {
    /// `message_input.attachment_preview.thumbnail.image`
    static let identifier = "message_input.attachment_preview.thumbnail.image"
}

extension A11y.MessageInput.AttachmentPreview.Thumbnail.Video {
    /// `message_input.attachment_preview.thumbnail.video`
    static let identifier = "message_input.attachment_preview.thumbnail.video"
}

extension A11y.MessageInput.AttachmentPreview.Thumbnail.Document {
    /// `message_input.attachment_preview.thumbnail.document`
    static let identifier = "message_input.attachment_preview.thumbnail.document"
}

extension A11y.MessageInput.AttachmentPreview.ButtonRemove {
    /// `message_input.attachment_preview.button_remove`
    static let identifier = "message_input.attachment_preview.button_remove"
}

extension A11y.MessageInput.AttachmentPreview.Loading {
    /// `message_input.attachment_preview.loading`
    static let identifier = "message_input.attachment_preview.loading"
}

// MARK: VoiceMessage

extension A11y.MessageInput.VoiceMessage {
    /// `message_input.voice_message`
    static let identifier = "message_input.voice_message"
}

extension A11y.MessageInput.VoiceMessage.Delete {
    /// `message_input.voice_message.delete`
    static let identifier = "message_input.voice_message.delete"
}

extension A11y.MessageInput.VoiceMessage.Stop {
    /// `message_input.voice_message.stop`
    static let identifier = "message_input.voice_message.stop"
}

extension A11y.MessageInput.VoiceMessage.Play {
    /// `message_input.voice_message.play`
    static let identifier = "message_input.voice_message.play"
}

extension A11y.MessageInput.VoiceMessage.Pause {
    /// `message_input.voice_message.pause`
    static let identifier = "message_input.voice_message.pause"
}

extension A11y.MessageInput.VoiceMessage.Recording {
    /// `message_input.voice_message.recording`
    static let identifier = "message_input.voice_message.recording"
}

extension A11y.MessageInput.VoiceMessage.Recorded {
    /// `message_input.voice_message.recorded`
    static let identifier = "message_input.voice_message.recorded"
}

extension A11y.MessageInput.VoiceMessage.Playing {
    /// `message_input.voice_message.playing`
    static let identifier = "message_input.voice_message.playing"
}

extension A11y.MessageInput.VoiceMessage.Length {
    /// `message_input.voice_message.length`
    static let identifier = "message_input.voice_message.length"
}

// MARK: - Popups

// MARK: Inactivity Popup

extension A11y.InactivityPopup.Header.Active {
    /// `inactivity_popup.header.active`
    static let identifier = "inactivity_popup.header.active"
}

extension A11y.InactivityPopup.Header.TimedOut {
    /// `inactivity_popup.header.timed_out`
    static let identifier = "inactivity_popup.header.timed_out"
}

extension A11y.InactivityPopup.ButtonRefresh {
    /// `inactivity_popup.button_refresh`
    static let identifier = "inactivity_popup.button_refresh"
}

extension A11y.InactivityPopup.ButtonExpire {
    /// `inactivity_popup.button_expire`
    static let identifier = "inactivity_popup.button_expire"
}

// MARK: End Conversation Popup

extension A11y.EndConversationPopup.Header {
    enum Title {
        /// `end_conversation_popup.header.title`
        static let identifier = "end_conversation_popup.header.title"
    }
}

extension A11y.EndConversationPopup.Header.AgentInfo {
    /// `end_conversation_popup.header.agent_info`
    static let identifier = "end_conversation_popup.header.agent_info"
}

extension A11y.EndConversationPopup.ButtonNewChat {
    /// `end_conversation_popup.button_new_chat`
    static let identifier = "end_conversation_popup.button_new_chat"
}

extension A11y.EndConversationPopup.ButtonBack {
    /// `end_conversation_popup.button_back`
    static let identifier = "end_conversation_popup.button_back"
}

extension A11y.EndConversationPopup.ButtonSendTranscript {
    /// `end_conversation_popup.button_send_transcript`
    static let identifier = "end_conversation_popup.button_send_transcript"
}

extension A11y.EndConversationPopup.ButtonClose {
    /// `end_conversation_popup.button_close`
    static let identifier = "end_conversation_popup.button_close"
}

// MARK: - Validated Text Field

extension A11y.ValidatedTextField {
    /// `validated_text_field.\(param)`
    static func identifier(_ param: String) -> String {
        "validated_text_field.\(param)"
    }
}
