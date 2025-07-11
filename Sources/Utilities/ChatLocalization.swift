//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-ui-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatSDK
import Foundation

public class ChatLocalization: ObservableObject {

    // MARK: - Properties
    
    var bundle: Bundle
    var tableName: String

    // MARK: - Common
    
    /// "OK"
    public lazy var commonOk = lookup(key: "chatui_common_ok")
    /// "Cancel"
    public lazy var commonCancel = lookup(key: "chatui_common_cancel")
    /// "Confirm"
    public lazy var commonConfirm = lookup(key: "chatui_common_confirm")
    /// "Required"
    public lazy var commonRequired = lookup(key: "chatui_common_required")
    /// "No selection"
    public lazy var commonNoSelection = lookup(key: "chatui_common_noSelection")
    /// "Invalid email"
    public lazy var commonInvalidEmail = lookup(key: "chatui_common_invalidEmail")
    /// "Invalid number"
    public lazy var commonInvalidNumber = lookup(key: "chatui_common_invalidNumber")
    /// "Select"
    public lazy var commonSelect = lookup(key: "chatui_common_select")
    /// "Attachments"
    public lazy var commonAttachments = lookup(key: "chatui_common_attachments")
    /// "Copy"
    public lazy var commonCopy = lookup(key: "chatui_common_copy")
    /// "Share"
    public lazy var commonShare = lookup(key: "chatui_common_share")
    /// "Attention"
    public lazy var commonAttention = lookup(key: "chatui_common_attention")
    /// "No Agent"
    public lazy var commonUnassignedAgent = lookup(key: "chatui_common_unassigned_agent")
    /// "Connecting..."
    public lazy var commonConnecting = lookup(key: "chatui_common_connecting")
    /// "Loading..."
    public lazy var commonLoading = lookup(key: "chatui_common_loading")
    /// "Try again"
    public lazy var commonTryAgain = lookup(key: "chatui_common_try_again")
    /// "Error"
    public lazy var commonError = lookup(key: "chatui_common_error")
    /// "Settings"
    public lazy var commonSettings = lookup(key: "chatui_common_settings")

    // MARK: - Alert
    
    /// "Disconnect"
    public lazy var alertDisconnectConfirm = lookup(key: "chatui_alert_disconnect_confirm")
    /// "Update thread name"
    public lazy var alertUpdateThreadNameTitle = lookup(key: "chatui_alert_updateThreadName_title")
    /// "Thread name"
    public lazy var alertUpdateThreadNamePlaceholder = lookup(key: "chatui_alert_updateThreadName_placeholder")
    /// "Edit custom field(s)"
    public lazy var alertEditPrechatCustomFieldsTitle = lookup(key: "chatui_alert_editPrechatCustomFields_title")
    /// "Something went wrong. Please, try again later."
    public lazy var alertGenericErrorMessage = lookup(key: "chatui_alert_genericError_message")
    /// "Oops! The chat encountered an issue and will disconnect. Please try again later."
    public lazy var alertDisconnectErrorMessage = lookup(key: "chatui_alert_disconnectError_message")
    /// "Are you sure you want to end this conversation?"
    public lazy var alertEndConversationMessage = lookup(key: "chatui_alert_endConverastion_message")
    /// "Camera access is required to take photos. Please allow camera access in Settings."
    public lazy var alertCameraPermissionMessage = lookup(key: "chatui_alert_cameraPermission_message")
    /// "Microphone access is required to record a voice message. Please allow microphone access in Settings."
    public lazy var alertMicrophonePermissionMessage = lookup(key: "chatui_alert_microphonePermission_message")
    /// "Oops!"
    public lazy var alertFileValidationTitle = lookup(key: "chatui_alert_fileValidation_title")
    /// "Unable to upload attachment(s) due to invalid file type."
    public lazy var alertInvalidFileTypeMessage = lookup(key: "chatui_alert_invalidFileType_message")
    /// "Unable to upload attachment(s). Attachment(s) size higher than %1$d MB"
    public lazy var alertInvalidFileSizeMessage = lookup(key: "chatui_alert_invalidFileSize_message")
    
    // MARK: - Overlay
    
    /// "The operation is taking longer than expected."
    public lazy var overlayLoadingDelayTitle = lookup(key: "chatui_overlay_loading_delay_title")
    /// "Close chat"
    public lazy var overlayLoadingDelayButtonTitle = lookup(key: "chatui_overlay_loading_delay_button_title")
    
    // MARK: - ChatListView
    
    /// "Threads"
    public lazy var chatListTitle = lookup(key: "chatui_chatList_title")
    /// "No threads"
    public lazy var chatListEmpty = lookup(key: "chatui_chatList_empty")
    /// "Current"
    public lazy var chatListThreadStatusArchived = lookup(key: "chatui_chatList_threadStatus_archived")
    /// "Archived"
    public lazy var chatListThreadStatusCurrent = lookup(key: "chatui_chatList_threadStatus_current")
    /// "New converstation"
    public lazy var chatListNewThread = lookup(key: "chatui_chatList_newThread")
    /// "Rename"
    public lazy var chatThreadContextMenuRename = lookup(key: "chatui_chatThread_contextMenu_rename")
    /// "Archive"
    public lazy var chatThreadContextMenuArchive = lookup(key: "chatui_chatThread_contextMenu_archive")

    // MARK: - Chat - Fallback Message
    
    /// "%1$d attachment(s)"
    public lazy var chatFallbackMessageAttachments = lookup(key: "chatui_chat_fallbackMessage_attachments")
    /// "Rich link message"
    public lazy var chatFallbackMessageTORMRichlink = lookup(key: "chatui_chat_fallbackMessage_torm_richLink")
    /// "Quick replies message"
    public lazy var chatFallbackMessageTORMQuickReplies = lookup(key: "chatui_chat_fallbackMessage_torm_quickReplies")
    /// "List picker message"
    public lazy var chatFallbackMessageTORMListPicker = lookup(key: "chatui_chat_fallbackMessage_torm_listPicker")
    /// "Unknown message"
    public lazy var chatFallbackMessageUnknown = lookup(key: "chatui_chat_fallbackMessage_unknown")
    /// "No name"
    public lazy var chatFallbackMessageNoName = lookup(key: "chatui_chat_fallbackMessage_noName")

    // MARK: - Chat - Messsage Input Bar
    
    /// This conversation was archived
    public lazy var chatMessageInputArchived = lookup(key: "chatui_chat_messageInput_archived")
    /// This conversation was closed
    public lazy var chatMessageInputClosed = lookup(key: "chatui_chat_messageInput_closed")
    /// "Aa"
    public lazy var chatMessageInputPlaceholder = lookup(key: "chatui_chat_messageInput_placeholder")
    /// "Attachment source"
    public lazy var chatMessageInputAttachmentsOptionTitle = lookup(key: "chatui_chat_messageInput_attachmentsOption_title")
    /// "Camera"
    public lazy var chatMessageInputAttachmentsOptionCamera = lookup(key: "chatui_chat_messageInput_attachmentsOption_camera")
    /// "Photo library"
    public lazy var chatMessageInputAttachmentsOptionPhotos = lookup(key: "chatui_chat_messageInput_attachmentsOption_photos")
    /// "File manager"
    public lazy var chatMessageInputAttachmentsOptionFiles = lookup(key: "chatui_chat_messageInput_attachmentsOption_files")
    /// "Recording"
    public lazy var chatMessageInputAudioRecorderRecording = lookup(key: "chatui_chat_messageInput_audioRecorder_recording")
    /// "Audio message"
    public lazy var chatMessageInputAudioRecorderRecorded = lookup(key: "chatui_chat_messageInput_audioRecorder_recorded")
    /// "Playing"
    public lazy var chatMessageInputAudioRecorderPlaying = lookup(key: "chatui_chat_messageInput_audioRecorder_playing")

    // MARK: - Chat - Attachments
    
    /// "All"
    public lazy var chatAttachmentsSelectionAll = lookup(key: "chatui_chat_attachments_selection_all")
    /// "None"
    public lazy var chatAttachmentsDeselect = lookup(key: "chatui_chat_attachments_deselect")
    /// "Select items"
    public lazy var chatAttachmentsSelectionMode = lookup(key: "chatui_chat_attachments_selectionMode")
    /// "%1$d item(s) selected"
    public lazy var chatAttachmentsSelectedCount = lookup(key: "chatui_chat_attachments_selectedCount_message")
    /// "Uploading..."
    public lazy var chatAttachmentsUpload = lookup(key: "chatui_chat_attachments_upload")
    /// "Loading document.."
    public lazy var loadingDoc = lookup(key: "chatui_chat_attachments_loading_document")
    /// "Loading video..."
    public lazy var loadingVideo = lookup(key: "chatui_chat_attachments_loading_video")
    /// "Loading document failed"
    public lazy var loadingDocError = lookup(key: "chatui_chat_attachments_loading_document_error")
    /// "Downloading document failed"
    public lazy var downloadingDocumentFailed = lookup(key: "chatui_chat_attachments_download_document_error")
    
    // MARK: - Chat - Menu Actions
    
    /// "Update conversation name"
    public lazy var chatMenuOptionUpdateName = lookup(key: "chatui_chat_menuOption_updateName")
    /// "End conversation"
    public lazy var chatMenuOptionEndConversation = lookup(key: "chatui_chat_menuOption_endConversation")
    
    // MARK: - Chat - TORM
    
    /// "Option selected"
    public lazy var chatMessageRichContentOptionSelected = lookup(key: "chatui_chat_message_richContent_optionSelected")
    /// "Tap to select an option"
    public lazy var chatMessageListPickerSheetOptionsTitle = lookup(key: "chatui_chat_message_listPicker_sheet_optionsTitle")
    /// "Done"
    public lazy var chatMessageListPickerSheetConfirm = lookup(key: "chatui_chat_message_listPicker_sheet_confirm")
    
    // MARK: - LiveChat - Offline
    
    /// "We are offline"
    public lazy var liveChatOfflineTitle = lookup(key: "chatui_liveChat_offline_title")
    /// "Try again later"
    public lazy var liveChatOfflineMessage = lookup(key: "chatui_liveChat_offline_message")

    // MARK: - LiveChat - Queue
    
    /// "You are number %1$d in the queue"
    public lazy var liveChatQueueTitle = lookup(key: "chatui_liveChat_queue_title")
    /// "All agents are currently busy"
    public lazy var liveChatQueueSubtitle = lookup(key: "chatui_liveChat_queue_subtitle")
    
    // MARK: - LiveChat - End Conversation
    
    /// "You chatted with"
    public lazy var liveChatEndConversationAssignedAgent = lookup(key: "chatui_liveChat_endConverastion_assignedAgent")
    /// "Start a new chat"
    public lazy var liveChatEndConversationNew = lookup(key: "chatui_liveChat_endConverastion_new")
    /// "Back to conversation"
    public lazy var liveChatEndConversationBack = lookup(key: "chatui_liveChat_endConverastion_back")
    /// "Close chat"
    public lazy var liveChatEndConversationClose = lookup(key: "chatui_liveChat_endConverastion_close")
    /// "This conversation was closed"
    public lazy var liveChatEndConversationDefaultTitle = lookup(key: "chatui_liveChat_endConversation_default_title")
    
    // MARK: - PreContactSurvey
    
    /// "Please fill out all fields and submit the form."
    public lazy var prechatSurveySubtitle = lookup(key: "chatui_preChatSurvey_subtitle")
    
	// MARK: - Init

    public init(bundle: Bundle = .main, tablename: String = "CXOneChatUI") {
        self.bundle = bundle
        self.tableName = tablename
    }

    // MARK: - Methods

    func lookup(key: String) -> String {
        let value = NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: "")

        return value != key
            ? value 
            : NSLocalizedString(key, tableName: "CXOneChatUI", bundle: Bundle.module, comment: "")
    }
}

// MARK: - Helpers

extension ChatLocalization {
    
    func string(for status: ThreadStatusType) -> String {
        switch status {
        case .current:
            return chatListThreadStatusCurrent
        case .archived:
            return chatListThreadStatusArchived
        }
    }
}
