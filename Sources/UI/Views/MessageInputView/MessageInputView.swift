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

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct MessageInputView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization

    @SwiftUI.Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject private var audioRecorder = AudioRecorder()
    
    @Binding private var isEditing: Bool
    @Binding private var alertType: ChatAlertType?
    
    @State private var message = ""
    @State private var attachments = [AttachmentItem]()
    @State private var attachmentsPickerSheet: (visible: Bool, type: UIImagePickerController.SourceType) = (false, .camera)
    @State private var contentSizeThatFits: CGSize = .zero
    @State private var showAttachmentsSheet = false
    @State private var showDocumentPickerSheet = false
    
    private let attachmentRestrictions: AttachmentRestrictions
    
    private var messageEditorHeight: CGFloat {
        min(self.contentSizeThatFits.height, 0.25 * UIScreen.main.bounds.height)
    }
    private var isSendButtonDisabled: Bool {
        if audioRecorder.state != .idle {
            return audioRecorder.state == .playing || audioRecorder.state == .recording
        } else {
            return message.isEmpty && attachments.isEmpty
        }
    }

    private var onSend: ((ChatMessageType, [AttachmentItem]) -> Void)?
    private var attributedMessage: Binding<NSAttributedString> {
        Binding<NSAttributedString>(
            get: {
                NSAttributedString(
                    string: self.message,
                    attributes: [
                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                        NSAttributedString.Key.foregroundColor: UIColor(style.backgroundColor).inverse()
                    ]
                )
            },
            set: { message in
                Task {
                    self.message = message.string
                }
            }
        )
    }
    
    // MARK: - Init
    
    init(
        attachmentRestrictions: AttachmentRestrictions,
        isEditing: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        onSend: @escaping (ChatMessageType, [AttachmentItem]) -> Void
    ) {
        self.attachmentRestrictions = attachmentRestrictions
        self._isEditing = isEditing
        self._alertType = alertType
        self._contentSizeThatFits = State(initialValue: .zero)
        self.onSend = onSend
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: 0) {
            if !attachments.isEmpty {
                AttachmentListView(attachments: $attachments)
            }
            
            HStack(alignment: .center, spacing: 2) {
                if audioRecorder.state == .idle, attachmentRestrictions.areAttachmentsEnabled {
                    attachmentsButton
                    
                    if isAnyMimeTypeAllowed([UTType.audioPreffix]) {
                        recordVoiceMessageButton
                    }
                }
                
                inputBar
                
                if audioRecorder.state != .idle {
                    voiceMessageButtons
                }
            }
            .padding(.horizontal, StyleGuide.Message.paddingHorizontal)
            .padding(.vertical, StyleGuide.Message.paddingVertical)
        }
        .animation(.spring(duration: 0.5), value: audioRecorder.state)
    }
}

// MARK: - Subviews

private extension MessageInputView {
    
    var attachmentsButton: some View {
        Button {
            showAttachmentsSheet = true
        } label: {
            Asset.Attachment.image
                .imageScale(.large)
        }
        .foregroundColor(style.customerCellColor)
        .frame(width: StyleGuide.buttonSmallerDimension, height: StyleGuide.buttonSmallerDimension)
        .actionSheet(isPresented: $showAttachmentsSheet) {
            attachmentsSourceActionSheet
        }
        .sheet(isPresented: $attachmentsPickerSheet.visible) {
            MediaPickerView(attachmentRestrictions: attachmentRestrictions, sourceType: attachmentsPickerSheet.type) { attachment in
                Task { @MainActor in
                    if attachment.isSizeValid(allowedFileSize: attachmentRestrictions.allowedFileSize) {
                        attachments.append(attachment)
                    } else {
                        alertType = .invalidAttachmentSize(localization: localization)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showDocumentPickerSheet) {
            DocumentPickerView(attachmentRestrictions: attachmentRestrictions) { attachments in
                Task { @MainActor in
                    if attachments.contains(where: { !$0.isSizeValid(allowedFileSize: attachmentRestrictions.allowedFileSize) }) {
                        alertType = .invalidAttachmentSize(localization: localization)
                    } else {
                        self.attachments.append(contentsOf: attachments)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var recordVoiceMessageButton: some View {
        Button {
            withAnimation {
                audioRecorder.record()
            }
        } label: {
            Asset.Attachment.recordVoice
                .imageScale(.large)
        }
        .foregroundColor(style.customerCellColor)
        .frame(width: StyleGuide.buttonSmallerDimension, height: StyleGuide.buttonSmallerDimension)
    }
    
    var attachmentsSourceActionSheet: ActionSheet {
        var buttons: [Alert.Button] = [
            .default(Text(localization.chatMessageInputAttachmentsOptionFiles)) {
                showDocumentPickerSheet = true
            },
            .cancel()
        ]
        
        if isAnyMimeTypeAllowed([UTType.imagePreffix, UTType.videoPreffix]) {
            buttons.append(.default(Text(localization.chatMessageInputAttachmentsOptionPhotos)) {
                attachmentsPickerSheet = (true, .photoLibrary)
            })
        }
        // `.camera` does not allow to have only `video` MIME type, it requires also image
        if isAnyMimeTypeAllowed([UTType.imagePreffix]) {
            buttons.append(.default(Text(localization.chatMessageInputAttachmentsOptionCamera)) {
                attachmentsPickerSheet = (true, .camera)
            })
        }
        
        return ActionSheet(title: Text(localization.chatMessageInputAttachmentsOptionTitle), buttons: buttons)
    }
    
    var inputBar: some View {
        HStack(alignment: audioRecorder.state == .idle ? .bottom : .center, spacing: 0) {
            if audioRecorder.state != .idle {
                audioRecorderInputBar
            } else {
                MultilineTextField(attributedText: self.attributedMessage, isEditing: self.$isEditing)
                    .onPreferenceChange(ContentSizeThatFitsKey.self) {
                        self.contentSizeThatFits = $0
                    }
                    .frame(height: self.messageEditorHeight)
            }
            
            sendButton
        }
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.buttonDimension / 2)
                .stroke(style.formTextColor.opacity(0.25))
        )
    }
    
    var audioRecorderInputBar: some View {
        Group {
            Asset.Attachment.voiceIndicator
                .foregroundColor(style.customerCellColor)
                .padding(.leading, 8)
            
            if case .recording = audioRecorder.state {
                AnimatedDotsView(text: localization.chatMessageInputAudioRecorderRecording)
                    .padding(.leading, 4)
            } else if case .playing = audioRecorder.state {
                AnimatedDotsView(text: localization.chatMessageInputAudioRecorderPlaying)
                    .padding(.leading, 4)
            }
            
            Spacer()
            
            if audioRecorder.state == .recorded {
                Text(audioRecorder.formattedLength)
                    .foregroundColor(style.formTextColor)
            } else {
                Text(audioRecorder.formattedCurrentTime)
                    .foregroundColor(style.formTextColor)
            }
        }
    }
    
    var sendButton: some View {
        Button {
            if audioRecorder.state != .idle, let attachment = audioRecorder.attachmentItem {
                onSend?(.text(""), [attachment])
                audioRecorder.state = .idle
            } else {
                onSend?(.text(message), attachments)
                message.removeAll()
                attachments.removeAll()
            }
            
            hideKeyboard()
        } label: {
            sendButtonBackground
                .frame(width: StyleGuide.buttonSmallerDimension, height: StyleGuide.buttonSmallerDimension)
                .overlay(
                    Asset.Message.send
                        .resizable()
                        .offset(x: -1, y: 1)
                    .padding(8)
                )
        }
        .disabled(isSendButtonDisabled)
        .foregroundColor(style.backgroundColor)
        .padding(3)
    }
    
    var sendButtonBackground: some View {
        if isSendButtonDisabled {
            Circle()
                .fill(style.formTextColor.opacity(0.5))
        } else {
            Circle()
                .fill(style.customerCellColor)
        }
    }
    
    var voiceMessageButtons: some View {
        Group {
            Button {
                switch audioRecorder.state {
                case .recording:
                    audioRecorder.stop()
                case .recorded:
                    audioRecorder.play()
                default:
                    audioRecorder.pause()
                }
            } label: {
                Circle()
                    .fill(style.customerCellColor)
                    .frame(width: StyleGuide.buttonSmallerDimension, height: StyleGuide.buttonSmallerDimension)
                    .overlay(
                        recordingControlButtonOverlay
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                    )
            }
            .padding(4)
        
            Button(action: audioRecorder.delete) {
                Circle()
                    .fill(Color(.red))
                    .frame(width: StyleGuide.buttonSmallerDimension, height: StyleGuide.buttonSmallerDimension)
                    .overlay(
                        Asset.Attachment.deleteVoice
                            .foregroundColor(.white)
                    )
            }
            .padding(4)
        }
    }
    
    var recordingControlButtonOverlay: some View {
        switch audioRecorder.state {
        case .recording:
            Asset.Attachment.stop
        case .recorded:
            Asset.Attachment.play
        default:
            Asset.Attachment.pause
        }
    }
}

// MARK: - Helpers

private extension MessageInputView {

    func isAnyMimeTypeAllowed(_ mimeTypes: [String]) -> Bool {
        let allowedMimeTypes = attachmentRestrictions.allowedTypes
        
        for mimeType in mimeTypes where allowedMimeTypes.contains(where: { $0.contains(mimeType) }) {
            return true
        }
        
        return false
    }
}

private extension AttachmentItem {
    
    static var megabyte: Int32 = 1024 * 1024
    
    func isSizeValid(allowedFileSize: Int32) -> Bool {
        do {
            return try url.accessSecurelyScopedResource { url in
                let allowedFileSize = allowedFileSize * Self.megabyte
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)

                guard let fileSize = attributes[.size] as? Int32 else {
                    return false
                }

                return fileSize <= allowedFileSize
            }
        } catch {
            error.logError()
            return false
        }
    }
}

// MARK: - Preview

struct MessageInputView_Previews: PreviewProvider {
    
    static var localization = ChatLocalization()
    
    @State private static var isEditing = false
    @State private static var alertType: ChatAlertType?
    
    private static let attachmentRestrictions = AttachmentRestrictions(
        allowedFileSize: 40,
        allowedTypes: ["image/*", "video/*", "audio/*"],
        areAttachmentsEnabled: true
    )
    
    static var previews: some View {
        Group {
            VStack {
                Spacer()
                
                MessageInputView(attachmentRestrictions: attachmentRestrictions, isEditing: $isEditing, alertType: $alertType) { _, _ in }
            }
            .alert(item: $alertType, content: alertContent)
            .previewDisplayName("Light Mode")
            
            VStack {
                Spacer()
                
                MessageInputView(attachmentRestrictions: attachmentRestrictions, isEditing: $isEditing, alertType: $alertType) { _, _ in }
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatStyle())
        .environmentObject(localization)
    }
    
    static func alertContent(for alertType: ChatAlertType) -> Alert {
        Alert(
            title: Text(localization.commonAttention),
            message: Text(localization.alertGenericErrorMessage),
            dismissButton: .cancel()
        )
    }
}
