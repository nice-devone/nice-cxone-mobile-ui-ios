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

import AVFoundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct MessageInputView: View, Themed {
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    @ObservedObject private var audioRecorder: AudioRecorder
    
    @Binding private var isEditing: Bool
    @Binding private var isInputEnabled: Bool
    @Binding private var alertType: ChatAlertType?
    
    @State private var message = ""
    @State private var attachments = [AttachmentItem]()
    @State private var attachmentsPickerSheet: (visible: Bool, type: UIImagePickerController.SourceType) = (false, .camera)
    @State private var contentSizeThatFits: CGSize = .zero
    @State private var showAttachmentsSheet = false
    @State private var showDocumentPickerSheet = false
    
    private static let textFieldLineLimit: Int = 6
    private static let textFieldAudioStateLineLimit: Int = 1
    private static let inputBarPaddingHorizontal: CGFloat = 12
    private static let inputBarPaddingVertical: CGFloat = 4
    private static let inputBarElementsSpacing: CGFloat = 8
    private static let inputBarTextFieldPaddingLeading: CGFloat = 4
    private static let voiceIndicatorLeadingPadding: CGFloat = 8
    private static let animatedDotsHorizontalPadding: CGFloat = 4
    private static let animatedDotsVerticalPadding: CGFloat = 10
    private static let paddingTrailingTimeLapsedText: CGFloat = 8
    
    private let localization: ChatLocalization
    private let attachmentRestrictions: AttachmentRestrictions
    
    private var isSendButtonDisabled: Bool {
        guard isInputEnabled else {
            return true
        }
        
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
                        NSAttributedString.Key.foregroundColor: UIColor(colors.customizable.onBackground)
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
    private var isVoiceRecordVisible: Bool {
        guard isInputEnabled else {
            return false
        }
        
        return message.isEmpty && attachments.isEmpty && attachmentRestrictions.areVoiceMessagesEnabled
    }
    
    // MARK: - Init
    
    init(
        attachmentRestrictions: AttachmentRestrictions,
        isEditing: Binding<Bool>,
        isInputEnabled: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        localization: ChatLocalization,
        onSend: @escaping (ChatMessageType, [AttachmentItem]) -> Void
    ) {
        self.attachmentRestrictions = attachmentRestrictions
        self._isEditing = isEditing
        self._isInputEnabled = isInputEnabled
        self._alertType = alertType
        self.localization = localization
        self._contentSizeThatFits = State(initialValue: .zero)
        self.onSend = onSend
        self.audioRecorder = AudioRecorder(alertType: alertType, localization: localization)
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: 0) {
            if !attachments.isEmpty {
                MessageInputAttachmentListView(attachments: $attachments, alertType: $alertType)
            }
            
            HStack(alignment: .bottom, spacing: Self.inputBarElementsSpacing) {
                if audioRecorder.state == .idle, attachmentRestrictions.areAttachmentsEnabled {
                    attachmentsButton
                } else if audioRecorder.state != .idle {
                    deleteVoiceMessageButton
                    
                    voiceMessageControlButton
                }
                
                inputBar
                    .padding(.leading, Self.inputBarTextFieldPaddingLeading)
            }
            .padding(.horizontal, Self.inputBarPaddingHorizontal)
            .padding(.vertical, Self.inputBarPaddingVertical)
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
            Asset.List.new
        }
        .font(.title2)
        .disabled(!isInputEnabled)
        .foregroundColor(isInputEnabled ? colors.customizable.primary : colors.foreground.disabled)
        .frame(width: StyleGuide.buttonDimension, height: StyleGuide.buttonDimension)
        .confirmationDialog(localization.chatMessageInputAttachmentsOptionTitle, isPresented: $showAttachmentsSheet) {
            Button(localization.chatMessageInputAttachmentsOptionFiles) {
                showDocumentPickerSheet = true
            }
            
            if isAnyMimeTypeAllowed([UTType.imagePreffix, UTType.videoPreffix]) {
                Button(localization.chatMessageInputAttachmentsOptionPhotos) {
                    attachmentsPickerSheet = (true, .photoLibrary)
                }
            }
            // `.camera` does not allow to have only `video` MIME type, it requires also image
            if isAnyMimeTypeAllowed([UTType.imagePreffix]) {
                Button(localization.chatMessageInputAttachmentsOptionCamera) {
                    checkCameraPermissionAndShowPicker()
                }
            }
            
            Button(localization.commonCancel, role: .cancel) {
                showDocumentPickerSheet = false
            }
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
        }
        .font(.largeTitle)
        .foregroundStyle(colors.customizable.onPrimary, colors.customizable.primary)
    }
    
    var inputBar: some View {
        HStack(alignment: audioRecorder.state == .idle ? .bottom : .center, spacing: 0) {
            if audioRecorder.state != .idle {
                audioRecorderInputBar
            } else {
                if #available(iOS 16.0, *) {
                    MultilineTextField(text: $message, isEditing: $isEditing)
                        .disabled(!isInputEnabled)
                } else {
                    LegacyMultilineTextField(attributedText: attributedMessage, isEditing: $isEditing, isInputEnabled: $isInputEnabled)
                }
            }
            
            if isVoiceRecordVisible, audioRecorder.state == .idle {
                recordVoiceMessageButton
            } else {
                sendButton
            }
        }
        .lineLimit(audioRecorder.state == .idle ? Self.textFieldLineLimit : Self.textFieldAudioStateLineLimit)
        .animation(.easeInOut, value: isVoiceRecordVisible)
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.buttonDimension / 2)
                .stroke(colors.customizable.onBackground.opacity(0.1))
        )
    }
    
    var audioRecorderInputBar: some View {
        Group {
            Asset.Attachment.voiceIndicator
                .foregroundColor(colors.customizable.primary)
                .padding(.leading, Self.voiceIndicatorLeadingPadding)
            
            if case .recording = audioRecorder.state {
                AnimatedDotsView(text: localization.chatMessageInputAudioRecorderRecording)
                    .padding(.leading, Self.animatedDotsHorizontalPadding)
                    .padding(.vertical, Self.animatedDotsVerticalPadding)
            } else if case .playing = audioRecorder.state {
                AnimatedDotsView(text: localization.chatMessageInputAudioRecorderPlaying)
                    .padding(.leading, Self.animatedDotsHorizontalPadding)
                    .padding(.vertical, Self.animatedDotsVerticalPadding)
            } else if case .recorded = audioRecorder.state {
                Text(localization.chatMessageInputAudioRecorderRecorded)
                    .truncationMode(.tail)
                    .foregroundColor(colors.customizable.onBackground.opacity(0.5))
                    .padding(.leading, Self.animatedDotsHorizontalPadding)
                    .padding(.vertical, Self.animatedDotsVerticalPadding)
            }
            
            Spacer()
            
            if audioRecorder.state == .recorded {
                Text(audioRecorder.formattedLength)
                    .foregroundColor(colors.customizable.onBackground)
                    .padding(.trailing, Self.paddingTrailingTimeLapsedText)
            } else {
                Text(audioRecorder.formattedCurrentTime)
                    .foregroundColor(colors.customizable.onBackground)
                    .padding(.trailing, Self.paddingTrailingTimeLapsedText)
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
            Asset.Message.send
        }
        .font(.largeTitle)
        .disabled(isSendButtonDisabled)
        .foregroundStyle(
            colors.customizable.onPrimary,
            isSendButtonDisabled ? colors.background.disabled : colors.customizable.primary
        )
        .animation(.default, value: isSendButtonDisabled)
    }
    
    var deleteVoiceMessageButton: some View {
        Button(action: audioRecorder.delete) {
            Asset.Attachment.deleteVoice
        }
        .font(.title2)
        .foregroundStyle(colors.foreground.error)
        .frame(width: StyleGuide.buttonDimension, height: StyleGuide.buttonDimension)
    }
    
    var voiceMessageControlButton: some View {
        Button {
            switch audioRecorder.state {
            case .idle:
                break
            case .recording:
                audioRecorder.stopRecording()
            case .recorded:
                audioRecorder.play()
            case .playing:
                audioRecorder.pause()
            case .paused:
                audioRecorder.play()
            }
        } label: {
            switch audioRecorder.state {
            case .recording:
                Asset.Attachment.stop
            case .recorded:
                Asset.Attachment.play
            default:
                Asset.Attachment.pause
            }
        }
        .font(.title)
        .frame(width: StyleGuide.buttonDimension, height: StyleGuide.buttonDimension)
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
    
    func checkCameraPermissionAndShowPicker() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // Permission already granted, show the camera
            attachmentsPickerSheet = (true, .camera)
        case .notDetermined:
            // Permission not determined yet, request it
            // This will show the system permission dialog
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        // User granted permission, show camera
                        self.attachmentsPickerSheet = (true, .camera)
                    } else {
                        // User denied permission in the system dialog
                        self.alertType = .cameraPermissionDenied(localization: self.localization) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
            }
        default:
            // Permission previously denied or unhandled state -> show settings alert
            alertType = .cameraPermissionDenied(localization: localization) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
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

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isEditing = false
    @Previewable @State var alertType: ChatAlertType?
    
    let localization = ChatLocalization()
    
    VStack {
        Spacer()
        
        MessageInputView(
            attachmentRestrictions: MockData.attachmentResrictions,
            isEditing: $isEditing,
            isInputEnabled: .constant(false),
            alertType: $alertType,
            localization: localization
        ) { _, _ in }
    }
    .alert(item: $alertType) { alertType in
        Alert(
            title: Text(alertType.title),
            message: Text(alertType.message),
            dismissButton: .cancel()
        )
    }
    .environmentObject(ChatStyle())
    .environmentObject(localization)
}
