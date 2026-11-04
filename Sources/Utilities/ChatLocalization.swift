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
// swiftlint:disable identifier_name

import CXoneChatSDK
import Foundation
import SwiftUI

public class ChatLocalization: ObservableObject {

    // MARK: - Properties

    let bundle: Bundle
    let tableName: String

    /// An optional provider for fine-grained programmatic localization string overrides.
    ///
    /// When non-nil, this is consulted first — before the bundle lookup and before the SDK default.
    /// Return `nil` from ``LocalizationStringProvider/localizationString(forKey:)`` for any key
    /// you do not want to override.
    public let provider: (any LocalizationStringProvider)?

    // MARK: - Common

    /// "Ok"
    public lazy var commonOk = lookup(key: "common.ok")
    /// "Cancel"
    public lazy var commonCancel = lookup(key: "common.cancel")
    /// "Confirm"
    public lazy var commonConfirm = lookup(key: "common.confirm")
    /// "Submit"
    public lazy var commonSubmit = lookup(key: "common.submit")
    /// "Required"
    public lazy var commonRequired = lookup(key: "common.required")
    /// "No selection"
    public lazy var commonNoSelection = lookup(key: "common.no_selection")
    /// "Invalid email"
    public lazy var commonInvalidEmail = lookup(key: "common.invalid_email")
    /// "Invalid number"
    public lazy var commonInvalidNumber = lookup(key: "common.invalid_number")
    /// "Fields do not match"
    public lazy var commonFieldsDontMatch = lookup(key: "common.fields_dont_match")
    /// "Select"
    public lazy var commonSelect = lookup(key: "common.select")
    /// "Attachments"
    public lazy var commonAttachments = lookup(key: "common.attachments")
    /// "Copy"
    public lazy var commonCopy = lookup(key: "common.copy")
    /// "Share"
    public lazy var commonShare = lookup(key: "common.share")
    /// "Attention"
    public lazy var commonAttention = lookup(key: "common.attention")
    /// "No Agent"
    public lazy var commonUnassignedAgent = lookup(key: "common.unassigned_agent")
    /// "Agent"
    public lazy var commonAgent = lookup(key: "common.agent")
    /// "AI Assistant"
    public lazy var commonAiAssistant = lookup(key: "common.ai_assistant")
    /// "Connecting..."
    @available(*, deprecated, message: "No longer used. Will be removed in a future release")
    public lazy var commonConnecting = lookup(key: "common.connecting")
    /// "Loading..."
    public lazy var commonLoading = lookup(key: "common.loading")
    /// "Try again"
    public lazy var commonTryAgain = lookup(key: "common.try_again")
    /// "Error"
    public lazy var commonError = lookup(key: "common.error")
    /// "Settings"
    public lazy var commonSettings = lookup(key: "common.settings")
    /// "Close chat"
    public lazy var commonCloseChat = lookup(key: "common.close_chat")

    // MARK: - Alert

    /// "Rename Conversation"
    public lazy var alertUpdateThreadNameTitle = lookup(key: "alert.update_thread_name.title")
    /// "Conversation name"
    public lazy var alertUpdateThreadNamePlaceholder = lookup(key: "alert.update_thread_name.placeholder")
    /// "Edit Pre-chat Form"
    public lazy var alertEditPrechatCustomFieldsTitle = lookup(key: "alert.edit_prechat_custom_fields.title")
    /// "Something went wrong. Please, try again later."
    public lazy var alertGenericErrorMessage = lookup(key: "alert.generic_error.message")
    /// "Oops! The chat encountered an issue and will disconnect. Please try again later."
    public lazy var alertDisconnectErrorMessage = lookup(key: "alert.disconnect_error.message")
    /// "The chat is not available because the '%1$@' feature could not be enabled. Check your channel configuration or contact support for more information."
    @available(
        *, deprecated,
        message: """
        The default UI no longer presents this alert now that CXoneChatError.featureUnavailable is never \
        thrown by the SDK. There is no replacement — the alert it backed was removed, and a failed \
        connection surfaces through the generic disconnect alert instead. Will be removed in 5.0.0.
        """
    )
    public lazy var alertFeatureUnavailableMessage = lookup(key: "alert.feature_unavailable.message")
    /// "Are you sure you want to end this conversation?"
    public lazy var alertEndConversationMessage = lookup(key: "alert.end_conversation.message")
    /// "Disconnect"
    @available(*, deprecated, message: "Replaced with `commonCloseChat`. Will be removed in a future major version.")
    public lazy var alertDisconnectConfirm = lookup(key: "alert.disconnect.confirm")
    /// "Camera access is required to take photos. Please allow camera access in Settings."
    public lazy var alertCameraPermissionMessage = lookup(key: "alert.camera_permission.message")
    /// "Microphone access is required to record a voice message. Please allow microphone access in Settings."
    public lazy var alertMicrophonePermissionMessage = lookup(key: "alert.microphone_permission.message")
    /// "Oops!"
    public lazy var alertFileValidationTitle = lookup(key: "alert.file_validation.title")
    /// "Unable to upload attachment(s) due to invalid file type."
    public lazy var alertInvalidFileTypeMessage = lookup(key: "alert.invalid_file_type.message")
    /// "Unable to upload attachment(s). Attachment(s) size higher than %1$d MB"
    public lazy var alertInvalidFileSizeMessage = lookup(key: "alert.invalid_file_size.message")
    /// "Send Transcript"
    public lazy var alertSendTranscriptTitle = lookup(key: "alert.send_transcript.title")
    /// "Chat transcript successfully sent"
    public lazy var alertSendTranscriptSuccessMessage = lookup(key: "alert.send_transcript.success")
    /// "Unable to send transcript. Please try again later."
    public lazy var alertSendTranscriptFailMessage = lookup(key: "alert.send_transcript.error_message")

    // MARK: - Overlay

    /// "The operation is taking longer than expected."
    public lazy var overlayLoadingDelayTitle = lookup(key: "overlay.loading_delay.title")

    // MARK: - ChatListView

    /// "Conversations"
    public lazy var chatListTitle = lookup(key: "chat_list.title")
    /// "No conversations"
    public lazy var chatListEmpty = lookup(key: "chat_list.empty")
    /// "Archived"
    public lazy var chatListThreadStatusArchived = lookup(key: "chat_list.thread_status.archived")
    /// "Current"
    public lazy var chatListThreadStatusCurrent = lookup(key: "chat_list.thread_status.current")
    /// "New conversation"
    public lazy var chatListNewThread = lookup(key: "chat_list.new_thread")
    /// "Rename"
    public lazy var chatThreadContextMenuRename = lookup(key: "chat_thread.context_menu.rename")
    /// "Archive"
    public lazy var chatThreadContextMenuArchive = lookup(key: "chat_thread.context_menu.archive")

    // MARK: - Chat - Fallback Message
    /// "Time picker message"
    public lazy var chatFallbackMessageTORMTimePicker = lookup(key: "chat.fallback_message.torm.time_picker")

    /// "%1$d attachment(s)"
    public lazy var chatFallbackMessageAttachments = lookup(key: "chat.fallback_message.attachments")
    /// "Rich link message"
    public lazy var chatFallbackMessageTORMRichlink = lookup(key: "chat.fallback_message.torm.rich_link")
    /// "Quick replies message"
    public lazy var chatFallbackMessageTORMQuickReplies = lookup(key: "chat.fallback_message.torm.quick_replies")
    /// "List picker message"
    public lazy var chatFallbackMessageTORMListPicker = lookup(key: "chat.fallback_message.torm.list_picker")
    /// "Unknown message"
    public lazy var chatFallbackMessageUnknown = lookup(key: "chat.fallback_message.unknown")
    /// "Why do I see this"
    public lazy var chatFallbackMessageUnknownTooltipText = lookup(key: "chat.fallback_message.unknown_tooltip.text")
    /// "This message could not be displayed in the chat as it uses a format that is currently unsupported."
    public lazy var chatFallbackMessageUnknownTooltipContent = lookup(key: "chat.fallback_message.unknown_tooltip.content")
    /// "No name"
    public lazy var chatFallbackMessageNoName = lookup(key: "chat.fallback_message.no_name")

    // MARK: - Chat - Message Input Bar

    /// This conversation was archived
    public lazy var chatMessageInputArchived = lookup(key: "chat.message_input.archived")
    /// This conversation was closed
    public lazy var chatMessageInputClosed = lookup(key: "chat.message_input.closed")
    /// "Aa"
    public lazy var chatMessageInputPlaceholder = lookup(key: "chat.message_input.placeholder")
    /// "Attachment source"
    public lazy var chatMessageInputAttachmentsOptionTitle = lookup(key: "chat.message_input.attachments_option.title")
    /// "Camera"
    public lazy var chatMessageInputAttachmentsOptionCamera = lookup(key: "chat.message_input.attachments_option.camera")
    /// "Photo library"
    public lazy var chatMessageInputAttachmentsOptionPhotos = lookup(key: "chat.message_input.attachments_option.photos")
    /// "File manager"
    public lazy var chatMessageInputAttachmentsOptionFiles = lookup(key: "chat.message_input.attachments_option.files")
    /// "Recording"
    public lazy var chatMessageInputAudioRecorderRecording = lookup(key: "chat.message_input.audio_recorder.recording")
    /// "Audio message"
    public lazy var chatMessageInputAudioRecorderRecorded = lookup(key: "chat.message_input.audio_recorder.recorded")
    /// "Playing"
    public lazy var chatMessageInputAudioRecorderPlaying = lookup(key: "chat.message_input.audio_recorder.playing")

    // MARK: - Chat - Attachments

    /// "All"
    public lazy var chatAttachmentsSelectionAll = lookup(key: "chat.attachments.selection.all")
    /// "None"
    public lazy var chatAttachmentsDeselect = lookup(key: "chat.attachments.deselect")
    /// "Select items"
    public lazy var chatAttachmentsSelectionMode = lookup(key: "chat.attachments.selection_mode")
    /// "%1$d item(s) selected"
    public lazy var chatAttachmentsSelectedCount = lookup(key: "chat.attachments.selected_count.message")
    /// "Uploading..."
    public lazy var chatAttachmentsUpload = lookup(key: "chat.attachments.upload")
    /// "Loading document.."
    @available(*, deprecated, message: "No longer used. Will be removed in a future major version.")
    public lazy var loadingDoc = lookup(key: "chat.attachments.loading.document")
    /// "Loading video..."
    @available(*, deprecated, message: "No longer used. Will be removed in a future major version.")
    public lazy var loadingVideo = lookup(key: "chat.attachments.loading.video")
    /// "Loading document failed"
    public lazy var loadingDocError = lookup(key: "chat.attachments.loading.document_error")
    /// "Downloading document failed"
    public lazy var downloadingDocumentFailed = lookup(key: "chat.attachments.download.document_error")

    // MARK: - Chat - Menu Actions
    /// "Rename Conversation"
    public lazy var chatMenuOptionUpdateName = lookup(key: "chat.menu_option.update_name")
    /// "End Conversation"
    public lazy var chatMenuOptionEndConversation = lookup(key: "chat.menu_option.end_conversation")
    /// "Send Transcript"
    public lazy var chatMenuOptionSendTranscript = lookup(key: "chat.menu_option.send_transcript")

    // MARK: - Chat - TORM

    /// "Option selected"
    public lazy var chatMessageRichContentOptionSelected = lookup(key: "chat.message.rich_content.option_selected")
    /// "Already answered or no longer available"
    public lazy var chatMessageRichContentOptionsDisabled = lookup(key: "chat.message.rich_content.options_disabled")
    /// "These options are no longer visible because you've already responded or the message is no longer the most recent."
    public lazy var chatMessageRichContentOptionsDisabledTooltip = lookup(key: "chatui_chat_message_richContent_optionsDisabled_tooltip")
    /// "Done"
    @available(*, deprecated, message: "Replaced with `commonSubmit`")
    public lazy var chatMessageListPickerSheetConfirm = lookup(key: "chatui_chat_message_listPicker_sheet_confirm")
    /// "Press to open"
    @available(*, deprecated, message: "Replaced with `chatMessageRichContentPressToOpen`")
    public lazy var chatMessageListPickerPressToOpen = lookup(key: "chatui_chat_message_listPicker_pressToOpen")
    /// "Press to open"
    public lazy var chatMessageRichContentPressToOpen = lookup(key: "chatui_chat_message_richContent_pressToOpen")
    /// "Select one option below"
    public lazy var chatMessageQuickRepliesSelectOneOption = lookup(key: "chat.message.quick_replies.select_one_option")
    /// "%@, %@ min"
    public lazy var chatMessageTimePickerFormatted = lookup(key: "chat.message.time_picker.formatted")
    
    // MARK: - LiveChat - Offline

    /// "We are offline"
    public lazy var liveChatOfflineTitle = lookup(key: "live_chat.offline.title")
    /// "Try again later"
    public lazy var liveChatOfflineMessage = lookup(key: "live_chat.offline.message")

    // MARK: - LiveChat - Queue

    /// "You are number %1$d in the queue"
    public lazy var liveChatQueueTitle = lookup(key: "live_chat.queue.title")
    /// "All agents are currently busy"
    public lazy var liveChatQueueSubtitle = lookup(key: "live_chat.queue.subtitle")

    // MARK: - LiveChat - End Conversation

    /// "You chatted with"
    public lazy var liveChatEndConversationAssignedAgent = lookup(key: "live_chat.end_conversation.assigned_agent")
    /// "Start a new chat"
    public lazy var liveChatEndConversationNew = lookup(key: "live_chat.end_conversation.new")
    /// "Back to conversation"
    public lazy var liveChatEndConversationBack = lookup(key: "live_chat.end_conversation.back")
    /// "This conversation was closed"
    public lazy var liveChatEndConversationDefaultTitle = lookup(key: "live_chat.end_conversation.default_title")

    // MARK: - LiveChat - Inactivity Popup

    /// "Time is up"
    public lazy var liveChatInactivityTimeoutTitle = lookup(key: "live_chat.inactivity_popup.session_timeout.title")
    /// "This conversation will now end due to inactivity"
    public lazy var liveChatInactivityTimeoutText = lookup(key: "live_chat.inactivity_popup.session_timeout.text")

    // MARK: - Chat - Satisfaction Survey

    /// "Satisfaction survey"
    public lazy var chatSatisfactionSurveyNotificationTitle = lookup(key: "chat.satisfaction_survey.notification_title")

    // MARK: - Form

    /// "%@ *"
    public lazy var formRequiredLabel = lookup(key: "form.required_label")
    /// "%1$@, %2$@"
    public lazy var formFieldError = lookup(key: "form.field_error")

    // MARK: - Form - Pre-contact Survey

    /// "Please fill out all fields and submit the form."
    public lazy var prechatSurveySubtitle = lookup(key: "pre_chat_survey.subtitle")
    /// "Fields marked with * are required."
    public lazy var prechatSurveyRequiredFieldsLegend = lookup(key: "pre_chat_survey.required_fields_legend")
    /// "%1$@ %2$@"
    public lazy var prechatSurveySubtitleWithRequiredFieldsLegend = lookup(key: "pre_chat_survey.subtitle_with_required_fields_legend")

    // MARK: - Form - Send Transcript

    /// "Chat Transcript"
    public lazy var sendTranscriptTitle = lookup(key: "send_transcript.title")
    /// "We do not share submitted emails with any 3rd party affiliate marketing or offer programs"
    public lazy var sendTranscriptSubtitle = lookup(key: "send_transcript.subtitle")
    /// "E-mail"
    public lazy var sendTranscriptEmailLabel = lookup(key: "send_transcript.email.label")
    /// "Enter your email address"
    public lazy var sendTranscriptEmailPlaceholder = lookup(key: "send_transcript.email.placeholder")
    /// "Confirm e-mail"
    public lazy var sendTranscriptConfirmEmailLabel = lookup(key: "send_transcript.confirm_email.label")
    /// "Confirm your email address"
    public lazy var sendTranscriptConfirmEmailPlaceholder = lookup(key: "send_transcript.confirm_email.placeholder")

    // MARK: - Form - Time Picker
    
    /// "Please select a preferred time slot"
    public lazy var formTimePickerSubtitle = lookup(key: "form.time_picker.subtitle")
    /// "%d min"
    public lazy var formTimePickerTimeSlotDuration = lookup(key: "form.time_picker.time_slot.duration")
    
    // MARK: - Init

    /// Creates a new `ChatLocalization` instance.
    ///
    /// - Parameters:
    ///   - bundle: The bundle to search for `CXOneChatUI.strings` overrides. Defaults to `Bundle.main`.
    ///   - tablename: The name of the strings table in the bundle. Defaults to `"CXOneChatUI"`.
    ///   - provider: An optional ``LocalizationStringProvider`` for programmatic overrides. Defaults to `nil`.
    public init(bundle: Bundle = .main, tablename: String = "CXOneChatUI", provider: (any LocalizationStringProvider)? = nil) {
        self.bundle = bundle
        self.tableName = tablename
        self.provider = provider
    }

    // MARK: - Methods

    func lookup(key: String) -> String {
        // 1. Programmatic provider (highest priority)
        if let override = provider?.localizationString(forKey: key) {
            return override
        }
        // 2. Integrator's bundle
        let value = NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: "")
        if value != key {
            return value
        }
        // 3. SDK's own bundle (default behavior)
        return NSLocalizedString(key, tableName: "CXOneChatUI", bundle: Bundle.module, comment: "")
    }
}
// swiftlint:enable identifier_name

// MARK: - Preview

// swiftlint:disable hardcoded_strings
/// A demo provider that overrides a handful of strings to illustrate the programmatic approach.
private struct DemoLocalizationProvider: LocalizationStringProvider {

    func localizationString(forKey key: String) -> String? {
        switch key {
        case "common.confirm":   return "Got it!"
        case "common.cancel":    return "Never mind"
        case "chat_list.title":  return "My Chats"
        default:                 return nil
        }
    }
}

@available(iOS 16.0, *)
#Preview("ChatLocalization") {
    let sdkDefault = ChatLocalization()
    let withProvider = ChatLocalization(provider: DemoLocalizationProvider())

    List {
        Section("Option 1 — SDK Defaults") {
            LabeledContent("common.confirm", value: sdkDefault.commonConfirm)
            LabeledContent("common.cancel", value: sdkDefault.commonCancel)
            LabeledContent("chat_list.title", value: sdkDefault.chatListTitle)
        }

        Section("Option 2 — Programmatic Provider") {
            LabeledContent("common.confirm", value: withProvider.commonConfirm)
            LabeledContent("common.cancel", value: withProvider.commonCancel)
            LabeledContent("chat_list.title", value: withProvider.chatListTitle)
        }
    }
}

@available(iOS 16.0, *)
#Preview("L10n with Provider Override") {
    // ChatCoordinator sets L10n.overrideProvider before presenting the chat UI.
    // Setting it here mirrors that behaviour exactly, so all L10n calls below resolve
    // through DemoLocalizationProvider first, then fall back to the SDK bundle for
    // any key the provider returns nil for.
    L10n.overrideProvider = DemoLocalizationProvider()

    return List {
        Section("Overridden keys") {
            LabeledContent("common.confirm", value: L10n.Common.confirm)
            LabeledContent("common.cancel", value: L10n.Common.cancel)
            LabeledContent("chat_list.title", value: L10n.ChatList.title)
        }
        
        Section {
            LabeledContent("common.ok", value: L10n.Common.ok)
            LabeledContent("common.submit", value: L10n.Common.submit)
        } header: {
            Text("Unhandled keys — fall back to SDK defaults")
        } footer: {
            Text("`common.ok` and `common.submit` are not overridden, as they do not exist in the DemoLocalizationProvider")
        }
    }
}
// swiftlint:enable hardcoded_strings
