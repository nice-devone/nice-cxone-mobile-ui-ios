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
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let textFieldLineLimit: Int = 6
            static let textFieldAudioStateLineLimit: Int = 1
            static let inputBarCornerRadius: CGFloat = StyleGuide.Sizing.buttonRegularDimension / 2
        }
        
        enum Spacing {
            static let inputBarElementsHorizontal: CGFloat = 8
            static let inputBarHorizontal: CGFloat = 0
        }
        
        enum Padding {
            static let inputBarTextFieldLeading: CGFloat = 4
            static let voiceIndicatorLeading: CGFloat = 8
            static let animatedDotsHorizontal: CGFloat = 4
            static let animatedDotsVertical: CGFloat = 10
            static let inputBarHorizontal: CGFloat = 12
            static let inputBarVertical: CGFloat = 4
            static let timeLapsedTextTrailing: CGFloat = 8
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    @ObservedObject private var audioRecorder: AudioRecorder
    
    @Binding private var isEditing: Bool
    @Binding private var isInputEnabled: Bool
    @Binding private var alertType: ChatAlertType?
    
    @State private var message = ""
    @State private var attachmentsLoadingProgress: Progress?
    @State private var attachments = [AttachmentItem]()
    @State private var contentSizeThatFits: CGSize = .zero
    @State private var showAttachmentsSheet = false
    @State private var showDocumentPickerSheet = false
    @State private var showMediaPickerSheet = false
    @State private var showMediaCaptureSheet = false
    
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
                        NSAttributedString.Key.foregroundColor: UIColor(colors.content.primary)
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
                MessageInputAttachmentListView(attachments: $attachments, loadingProgress: $attachmentsLoadingProgress, alertType: $alertType)
            }
            
            HStack(alignment: .bottom, spacing: Constants.Spacing.inputBarElementsHorizontal) {
                if audioRecorder.state == .idle, attachmentRestrictions.areAttachmentsEnabled {
                    attachmentsButton
                } else if audioRecorder.state != .idle {
                    deleteVoiceMessageButton
                    
                    voiceMessageControlButton
                }
                
                inputBar
                    .padding(.leading, Constants.Padding.inputBarTextFieldLeading)
            }
            .padding(.horizontal, Constants.Padding.inputBarHorizontal)
            .padding(.vertical, Constants.Padding.inputBarVertical)
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
        .foregroundColor(isInputEnabled ? colors.brand.primary : colors.content.tertiary)
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
        .confirmationDialog(localization.chatMessageInputAttachmentsOptionTitle, isPresented: $showAttachmentsSheet) {
            Button(localization.chatMessageInputAttachmentsOptionFiles) {
                showDocumentPickerSheet = true
            }
            
            if isAnyMimeTypeAllowed([UTType.imagePreffix, UTType.videoPreffix]) {
                Button(localization.chatMessageInputAttachmentsOptionPhotos) {
                    showMediaPickerSheet = true
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
        .sheet(isPresented: $showMediaPickerSheet) {
            MediaPickerView(
                attachmentsLoadingProgress: $attachmentsLoadingProgress,
                attachments: $attachments,
                attachmentRestrictions: attachmentRestrictions,
                localization: localization
            ) { alert in
                alertType = alert
            }
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showMediaCaptureSheet) {
            MediaCaptureView(
                attachmentRestrictions: attachmentRestrictions,
                localization: localization,
                onSelected: { attachment in
                    Task { @MainActor in
                        await processSelectedAttachments([attachment])
                    }
                },
                onAlert: { alertType in
                    self.alertType = alertType
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showDocumentPickerSheet) {
            DocumentPickerView(attachmentRestrictions: attachmentRestrictions) { attachments in
                Task { @MainActor in
                    await processSelectedAttachments(attachments)
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
        .foregroundStyle(colors.brand.onPrimary, colors.brand.primary)
    }
    
    var inputBar: some View {
        HStack(alignment: audioRecorder.state == .idle ? .bottom : .center, spacing: Constants.Spacing.inputBarHorizontal) {
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
        .lineLimit(audioRecorder.state == .idle ? Constants.Sizing.textFieldLineLimit : Constants.Sizing.textFieldAudioStateLineLimit)
        .animation(.easeInOut, value: isVoiceRecordVisible)
        .background(
            RoundedRectangle(cornerRadius: Constants.Sizing.inputBarCornerRadius)
                .stroke(colors.border.default)
        )
    }
    
    var audioRecorderInputBar: some View {
        Group {
            Asset.Attachment.voiceIndicator
                .foregroundColor(colors.brand.primary)
                .padding(.leading, Constants.Padding.voiceIndicatorLeading)
            
            if case .recording = audioRecorder.state {
                AnimatedDotsView(text: localization.chatMessageInputAudioRecorderRecording)
                    .padding(.leading, Constants.Padding.animatedDotsHorizontal)
                    .padding(.vertical, Constants.Padding.animatedDotsVertical)
            } else if case .playing = audioRecorder.state {
                AnimatedDotsView(text: localization.chatMessageInputAudioRecorderPlaying)
                    .padding(.leading, Constants.Padding.animatedDotsHorizontal)
                    .padding(.vertical, Constants.Padding.animatedDotsVertical)
            } else if [.recorded, .paused].contains(audioRecorder.state) {
                Text(localization.chatMessageInputAudioRecorderRecorded)
                    .truncationMode(.tail)
                    .foregroundColor(colors.content.primary)
                    .padding(.leading, Constants.Padding.animatedDotsHorizontal)
                    .padding(.vertical, Constants.Padding.animatedDotsVertical)
            }
            
            Spacer()
            
            Text(audioRecorder.state == .recorded ? audioRecorder.formattedLength : audioRecorder.formattedCurrentTime)
                .font(.footnote)
                .foregroundColor(colors.content.tertiary)
                .padding(.trailing, Constants.Padding.timeLapsedTextTrailing)
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
        .foregroundStyle(isSendButtonDisabled ? colors.content.tertiary : colors.brand.primary)
        .animation(.default, value: isSendButtonDisabled)
    }
    
    var deleteVoiceMessageButton: some View {
        Button(action: audioRecorder.delete) {
            Asset.Attachment.deleteVoice
        }
        .font(.title2)
        .foregroundStyle(colors.status.error)
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
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
            case .recorded, .paused:
                Asset.Attachment.play
            default:
                Asset.Attachment.pause
            }
        }
        .font(.title)
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
    }
}

// MARK: - Helpers

private extension MessageInputView {

    @MainActor
    func processSelectedAttachments(_ attachments: [AttachmentItem]) async {
        if attachments.contains(where: { !$0.isSizeValid(allowedFileSize: attachmentRestrictions.allowedFileSize) }) {
            alertType = .invalidAttachmentSize(localization: localization)
        } else {
            for attachment in attachments where self.attachments.contains(attachment) == false {
                self.attachments.append(attachment)
            }
        }
    }

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
            showMediaCaptureSheet = true
        case .notDetermined:
            // Permission not determined yet, request it
            // This will show the system permission dialog
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        // User granted permission, show camera
                        showMediaCaptureSheet = true
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

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isEditing = false
    @Previewable @State var alertType: ChatAlertType?
    
    let localization = ChatLocalization()
    
    VStack {
        Spacer()
        
        MessageInputView(
            attachmentRestrictions: MockData.attachmentRestrictions,
            isEditing: $isEditing,
            isInputEnabled: .constant(true),
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
