//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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
    /// "Close"
    public lazy var commonClose = lookup(key: "chatui_common_close")
    /// "Delete"
    public lazy var commonDelete = lookup(key: "chatui_common_delete")
    /// "Required"
    public lazy var commonRequired = lookup(key: "chatui_common_required")
    /// "No Selection"
    public lazy var commonNoSelection = lookup(key: "chatui_common_noSelection")
    /// "Invalid Email"
    public lazy var commonInvalidEmail = lookup(key: "chatui_common_invalidEmail")
    /// "Invalid Number"
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
    /// "Automated Agent"
    public lazy var commonUnknownAgent = lookup(key: "chatui_common_unknown_agent")
    /// "Unknown Customer"
    public lazy var commonUnknownCustomer = lookup(key: "chatui_common_unknown_customer")

    // MARK: - Alert
    
    /// "Unable to create new thread"
    public lazy var alertThreadCreationFailedMessage = lookup(key: "chatui_alert_threadCreationFailed_message")
    /// "Received remote notification from unknown thread."
    public lazy var alertDeeplinkUnknownThreadMessage = lookup(key: "chatui_alert_DeeplinkUnknownThread_message")
    /// "Do you want to disconnect from the CXone services?"
    public lazy var alertDisconnectMessage = lookup(key: "chatui_alert_disconnect_message")
    /// "Disconnect"
    public lazy var alertDisconnectConfirm = lookup(key: "chatui_alert_disconnect_confirm")
    /// "Update Thread Name"
    public lazy var alertUpdateThreadNameTitle = lookup(key: "chatui_alert_updateThreadName_title")
    /// "Enter a name for this thread"
    public lazy var alertUpdateThreadNameMessage = lookup(key: "chatui_alert_updateThreadName_message")
    /// "Thread Name"
    public lazy var alertUpdateThreadNamePlaceholder = lookup(key: "chatui_alert_updateThreadName_placeholder")
    /// "Edit Custom Fields"
    public lazy var alertEditPrechatCustomFieldsTitle = lookup(key: "chatui_alert_editPrechatCustomFields_title")
    /// "Something went wrong. Try it again later or contact the CXone Mobile team"
    public lazy var alertGenericErrorMessage = lookup(key: "chatui_alert_genericError_message")
    /// "Unable to upload attachment(s). Attachment(s) size higher than %1$d MB"
    public lazy var alertInvalidFileSizeMessage = lookup(key: "chatui_alert_invalidFileSize_message")
    /// "Are you sure you want to end this conversation?"
    public lazy var alertEndConversationMessage = lookup(key: "chatui_alert_endConverastion_message")
    
    // MARK: - ChatListView
    
    /// "Threads"
    public lazy var chatListTitle = lookup(key: "chatui_chatList_title")
    /// "No Threads"
    public lazy var chatListEmpty = lookup(key: "chatui_chatList_empty")
    /// "Current"
    public lazy var chatListThreadStatusArchived = lookup(key: "chatui_chatList_threadStatus_archived")
    /// "Archived"
    public lazy var chatListThreadStatusCurrent = lookup(key: "chatui_chatList_threadStatus_current")

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

    // MARK: - Chat - Messsage Input Bar
    
    /// This conversation was archived
    public lazy var chatMessageInputArchived = lookup(key: "chatui_chat_messageInput_archived")
    /// This conversation was closed
    public lazy var chatMessageInputClosed = lookup(key: "chatui_chat_messageInput_closed")
    /// "Aa"
    public lazy var chatMessageInputPlaceholder = lookup(key: "chatui_chat_messageInput_placeholder")
    /// "Attachments Source"
    public lazy var chatMessageInputAttachmentsOptionTitle = lookup(key: "chatui_chat_messageInput_attachmentsOption_title")
    /// "Camera"
    public lazy var chatMessageInputAttachmentsOptionCamera = lookup(key: "chatui_chat_messageInput_attachmentsOption_camera")
    /// "Photo Library"
    public lazy var chatMessageInputAttachmentsOptionPhotos = lookup(key: "chatui_chat_messageInput_attachmentsOption_photos")
    /// "File Manager"
    public lazy var chatMessageInputAttachmentsOptionFiles = lookup(key: "chatui_chat_messageInput_attachmentsOption_files")
    /// "Recording"
    public lazy var chatMessageInputAudioRecorderRecording = lookup(key: "chatui_chat_messageInput_audioRecorder_recording")
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
    /// "Processing..."
    public lazy var chatAttachmentsUpload = lookup(key: "chatui_chat_attachments_upload")
    /// "The document could not be downloaded at this time. Please check your internet connection and try again."
    public lazy var chatAttachmentsDownloadFailed = lookup(key: "chatui_chat_attachments_download_failed")
    
    // MARK: - Chat - Menu Actions
    
    /// "Disconnect"
    public lazy var chatMenuOptionDisconnect = lookup(key: "chatui_chat_menuOption_disconnect")
    /// "Update conversation name"
    public lazy var chatMenuOptionUpdateName = lookup(key: "chatui_chat_menuOption_updateName")
    /// "Edit custom fields"
    public lazy var chatMenuOptionEditPrechatCustomFields = lookup(key: "chatui_chat_menuOption_editPrechatCustomFields")
    /// "End conversation"
    public lazy var chatMenuOptionEndConversation = lookup(key: "chatui_chat_menuOption_endConversation")
    
    // MARK: - LiveChat - Offline
    
    /// "We are offline"
    public lazy var liveChatOfflineTitle = lookup(key: "chatui_liveChat_offline_title")
    /// "Try again later"
    public lazy var liveChatOfflineMessage = lookup(key: "chatui_liveChat_offline_message")

    // MARK: - LiveChat - Queue
    
    /// "All agents are currently busy"
    public lazy var liveChatQueueTitle = lookup(key: "chatui_liveChat_queue_title")
    /// "You are number %1$d in the queue"
    public lazy var liveChatQueueMessage = lookup(key: "chatui_liveChat_queue_message")
    
    // MARK: - LiveChat - End Conversation
    
    /// "You chatted with"
    public lazy var liveChatEndConversationAssignedAgent = lookup(key: "chatui_liveChat_endConverastion_assignedAgent")
    /// "Start a new chat"
    public lazy var liveChatEndConversationNew = lookup(key: "chatui_liveChat_endConverastion_new")
    /// "Back to conversation"
    public lazy var liveChatEndConversationBack = lookup(key: "chatui_liveChat_endConverastion_back")
    /// "Close the chat"
    public lazy var liveChatEndConversationClose = lookup(key: "chatui_liveChat_endConverastion_close")
    
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
