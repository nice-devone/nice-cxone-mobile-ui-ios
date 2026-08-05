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

import AVFoundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct MessageInputView: View, Themed {
    
    // MARK: - Types

    private enum PickerSheet: Identifiable {
        case document, media, camera
        var id: Self { self }
    }
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Sizing {
            static let textFieldLineLimit: Int = 6
            static let textFieldAudioStateLineLimit: Int = 1
            static let inputBarCornerRadius: CGFloat = StyleGuide.Sizing.buttonRegularDimension / 2
            static let sendingProgressScaleEffect: CGFloat = 1.5
        }
        
        enum Spacing {
            static let inputBarElementsHorizontal: CGFloat = 8
            static let inputBarHorizontal: CGFloat = 0
        }
        
        enum Padding {
            static let inputBarTextFieldLeading: CGFloat = 4
            static let inputBarTextFieldBottom: CGFloat = 2
            static let voiceIndicatorLeading: CGFloat = 8
            static let animatedDotsHorizontal: CGFloat = 4
            static let animatedDotsVertical: CGFloat = 10
            static let inputBarHorizontal: CGFloat = 12
            static let inputBarVertical: CGFloat = 4
            static let timeLapsedTextTrailing: CGFloat = 8
        }

        enum Accessibility {
            static let announcementDelay: TimeInterval = 0.1
            static let focusReturnDelay: TimeInterval = 0.6
            static let focusLockReleaseDelay: TimeInterval = 0.3
        }
    }
    
    // MARK: - Properties

    @EnvironmentObject var style: ChatStyle

    @Environment(\.colorScheme) var scheme

    @ObservedObject private var audioRecorder: AudioRecorder
    
    @Binding private var isEditing: Bool
    @Binding private var isInputEnabled: Bool
    @Binding private var alertType: ChatAlertType?
    @Binding private var isSendingMessage: Bool

    @FocusState private var isTextFieldFocused: Bool

    @AccessibilityFocusState private var isTextFieldA11yFocused: Bool

    @State private var message = ""
    @State private var attachmentsLoadingProgress: Progress?
    @State private var attachments = [AttachmentItem]()
    @State private var contentSizeThatFits: CGSize = .zero
    @State private var showAttachmentsSheet = false
    @State private var activePickerSheet: PickerSheet?
    @State private var shouldMaintainA11yFocus = false
    @State private var focusTask: Task<Void, Never>?

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

    private let onSend: (ChatMessageType, [AttachmentItem]) -> Void
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
        isSendingMessage: Binding<Bool>,
        alertType: Binding<ChatAlertType?>,
        onSend: @escaping (ChatMessageType, [AttachmentItem]) -> Void
    ) {
        self.attachmentRestrictions = attachmentRestrictions
        self._isEditing = isEditing
        self._isInputEnabled = isInputEnabled
        self._alertType = alertType
        self._isSendingMessage = isSendingMessage
        self.onSend = onSend
        self.audioRecorder = AudioRecorder(alertType: alertType)
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
        .background(colors.background.default)
        .animation(.spring(duration: 0.5), value: audioRecorder.state)
        .animation(.default, value: isSendButtonDisabled)
        .animation(.default, value: isSendingMessage)
        .sheet(item: $activePickerSheet) { sheet in
            switch sheet {
            case .media:
                MediaPickerView(
                    attachmentsLoadingProgress: $attachmentsLoadingProgress,
                    attachments: $attachments,
                    attachmentRestrictions: attachmentRestrictions
                ) { alert in
                    alertType = alert
                }
                .edgesIgnoringSafeArea(.all)
            case .camera:
                MediaCaptureView(
                    attachmentRestrictions: attachmentRestrictions,
                    onSelected: { attachment in
                        Task { @MainActor in
                            await processSelectedAttachments([attachment])
                        }
                    },
                    onAlert: { self.alertType = $0 }
                )
                .edgesIgnoringSafeArea(.all)
            case .document:
                DocumentPickerView(attachmentRestrictions: attachmentRestrictions) { attachments in
                    Task { @MainActor in
                        await processSelectedAttachments(attachments)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
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
        .foregroundStyle(isInputEnabled ? colors.brand.primary : colors.content.tertiary)
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
        .accessibilityIdentifier(A11y.MessageInput.ButtonAttachmentSource.identifier)
        .accessibilityLabel(A11y.MessageInput.ButtonAttachmentSource.label)
        .accessibilityHint(A11y.MessageInput.ButtonAttachmentSource.hint)
        .confirmationDialog(L10n.Chat.MessageInput.AttachmentsOption.title, isPresented: $showAttachmentsSheet) {
            Button(L10n.Chat.MessageInput.AttachmentsOption.files) {
                activePickerSheet = .document
            }
            .accessibilityIdentifier(A11y.MessageInput.ButtonAttachmentSource.Files.identifier)
            .accessibilityLabel(A11y.MessageInput.ButtonAttachmentSource.Files.label)
            .accessibilityHint(A11y.MessageInput.ButtonAttachmentSource.Files.hint)

            if isAnyMimeTypeAllowed([UTType.imagePreffix, UTType.videoPreffix]) {
                Button(L10n.Chat.MessageInput.AttachmentsOption.photos) {
                    activePickerSheet = .media
                }
                .accessibilityIdentifier(A11y.MessageInput.ButtonAttachmentSource.Photos.identifier)
                .accessibilityLabel(A11y.MessageInput.ButtonAttachmentSource.Photos.label)
                .accessibilityHint(A11y.MessageInput.ButtonAttachmentSource.Photos.hint)
            }
            // `.camera` does not allow to have only `video` MIME type, it requires also image
            if isAnyMimeTypeAllowed([UTType.imagePreffix]) {
                Button(L10n.Chat.MessageInput.AttachmentsOption.camera) {
                    checkCameraPermissionAndShowPicker()
                }
                .accessibilityIdentifier(A11y.MessageInput.ButtonAttachmentSource.Camera.identifier)
                .accessibilityLabel(A11y.MessageInput.ButtonAttachmentSource.Camera.label)
                .accessibilityHint(A11y.MessageInput.ButtonAttachmentSource.Camera.hint)
            }

            Button(L10n.Common.cancel, role: .cancel) { }
        }
    }
    
    var inputBar: some View {
        HStack(alignment: audioRecorder.state == .idle ? .bottom : .center, spacing: Constants.Spacing.inputBarHorizontal) {
            if audioRecorder.state != .idle {
                audioRecorderInputBar
            } else {
                MultilineTextField(text: $message, isEditing: $isEditing, isFocused: $isTextFieldFocused)
                    .padding(.bottom, Constants.Padding.inputBarTextFieldBottom)
                    .disabled(!isInputEnabled)
                    .accessibilityFocused($isTextFieldA11yFocused)
            }
            
            if isSendingMessage {
                sendingProgressView
            } else if isVoiceRecordVisible, audioRecorder.state == .idle {
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
                .foregroundStyle(colors.brand.primary)
                .padding(.leading, Constants.Padding.voiceIndicatorLeading)
                .accessibilityHidden(true)

            audioStateContent
                .padding(.leading, Constants.Padding.animatedDotsHorizontal)
                .padding(.vertical, Constants.Padding.animatedDotsVertical)

            Spacer()

            Text(audioRecorder.state == .recorded ? audioRecorder.formattedLength : audioRecorder.formattedCurrentTime)
                .font(.footnote)
                .foregroundStyle(colors.content.tertiary)
                .padding(.trailing, Constants.Padding.timeLapsedTextTrailing)
                .accessibilityIdentifier(A11y.MessageInput.VoiceMessage.Length.identifier)
                .accessibilityLabel(
                    String.formattedAudioLengthForA11y(
                        audioRecorder.state == .recorded
                            ? audioRecorder.length
                            : audioRecorder.time
                    )
                )
                .accessibilityHint(A11y.MessageInput.VoiceMessage.Length.hint)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    var audioStateContent: some View {
        switch audioRecorder.state {
        case .recording:
            AnimatedDotsView(text: L10n.Chat.MessageInput.AudioRecorder.recording)
                .accessibilityIdentifier(A11y.MessageInput.VoiceMessage.Recording.identifier)
                .accessibilityLabel(A11y.MessageInput.VoiceMessage.Recording.label)
                .accessibilityHint(A11y.MessageInput.VoiceMessage.Recording.hint)
        case .playing:
            AnimatedDotsView(text: L10n.Chat.MessageInput.AudioRecorder.playing)
                .accessibilityIdentifier(A11y.MessageInput.VoiceMessage.Playing.identifier)
                .accessibilityLabel(A11y.MessageInput.VoiceMessage.Playing.label)
                .accessibilityHint(A11y.MessageInput.VoiceMessage.Playing.hint)
        case .recorded, .paused:
            Text(L10n.Chat.MessageInput.AudioRecorder.recorded)
                .truncationMode(.tail)
                .foregroundStyle(colors.content.primary)
                .accessibilityIdentifier(A11y.MessageInput.VoiceMessage.Recorded.identifier)
                .accessibilityLabel(A11y.MessageInput.VoiceMessage.Recorded.label)
                .accessibilityHint(A11y.MessageInput.VoiceMessage.Recorded.hint)
        case .idle:
            EmptyView()
        }
    }

    var sendingProgressView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: colors.brand.primary))
            .scaleEffect(Constants.Sizing.sendingProgressScaleEffect)
            .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
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
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
        .foregroundStyle(colors.brand.onPrimary, colors.brand.primary)
    }
    
    var sendButton: some View {
        Button {
            let isVoiceMessage = audioRecorder.state != .idle

            if isVoiceMessage, let attachment = audioRecorder.attachmentItem {
                onSend(.text(""), [attachment])
                audioRecorder.state = .idle
            } else {
                onSend(.text(message), attachments)
                message.removeAll()
                attachments.removeAll()
            }

            handlePostSendFocusManagement(isVoiceMessage: isVoiceMessage)
        } label: {
            Asset.Message.send
        }
        .font(.largeTitle)
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
        .disabled(isSendButtonDisabled || isSendingMessage)
        .foregroundStyle(isSendButtonDisabled || isSendingMessage ? colors.content.tertiary : colors.brand.primary)
        .accessibilityIdentifier(A11y.MessageInput.ButtonSend.identifier)
        .accessibilityLabel(A11y.MessageInput.ButtonSend.label)
        .accessibilityHint(
            isSendButtonDisabled
                ? A11y.MessageInput.ButtonSend.hintDisabled
                : A11y.MessageInput.ButtonSend.hintEnabled
        )
    }

    var deleteVoiceMessageButton: some View {
        Button(action: audioRecorder.delete) {
            Asset.Attachment.deleteVoice
        }
        .font(.title2)
        .foregroundStyle(colors.status.error)
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
        .accessibilityIdentifier(A11y.MessageInput.VoiceMessage.Delete.identifier)
        .accessibilityLabel(A11y.MessageInput.VoiceMessage.Delete.label)
        .accessibilityHint(A11y.MessageInput.VoiceMessage.Delete.hint)
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
            case .playing, .idle:
                Asset.Attachment.pause
            }
        }
        .font(.title)
        .frame(width: StyleGuide.Sizing.buttonRegularDimension, height: StyleGuide.Sizing.buttonRegularDimension)
        .if(audioRecorder.state != .idle) { view in
            switch audioRecorder.state {
            case .recording:
                view
                    .accessibilityIdentifier(A11y.MessageInput.VoiceMessage.Stop.identifier)
                    .accessibilityLabel(A11y.MessageInput.VoiceMessage.Stop.label)
                    .accessibilityHint(A11y.MessageInput.VoiceMessage.Stop.hint)
            case .recorded, .paused:
                view
                    .accessibilityIdentifier(A11y.MessageInput.VoiceMessage.Play.identifier)
                    .accessibilityLabel(A11y.MessageInput.VoiceMessage.Play.label)
                    .accessibilityHint(A11y.MessageInput.VoiceMessage.Play.hint)
            default:
                view
                    .accessibilityIdentifier(A11y.MessageInput.VoiceMessage.Pause.identifier)
                    .accessibilityLabel(A11y.MessageInput.VoiceMessage.Pause.label)
                    .accessibilityHint(A11y.MessageInput.VoiceMessage.Pause.hint)
            }
        }
    }
}

// MARK: - Helpers

private extension MessageInputView {

    func handlePostSendFocusManagement(isVoiceMessage: Bool) {
        // Only restore focus for text messages, not voice messages
        guard !isVoiceMessage else {
            return
        }

        // Cancel any in-flight focus task to prevent stale callbacks
        focusTask?.cancel()
        // Prevent focus from shifting to the mic button after sending
        shouldMaintainA11yFocus = true
        // Create cancellable task for focus management
        focusTask = Task { @MainActor in
            // Announce immediately so it's not interrupted by focus change
            await Task.sleep(seconds: Constants.Accessibility.announcementDelay)

            guard !Task.isCancelled else {
                return
            }

            A11y.announce(A11y.Announcement.Message.sent)
            // Delay focus return to allow announcement to complete
            await Task.sleep(seconds: Constants.Accessibility.focusReturnDelay)

            guard !Task.isCancelled else {
                return
            }

            isTextFieldFocused = true
            isTextFieldA11yFocused = true

            // Release the focus lock after a short delay to allow normal focus behavior
            await Task.sleep(seconds: Constants.Accessibility.focusLockReleaseDelay)

            guard !Task.isCancelled else {
                return
            }

            shouldMaintainA11yFocus = false
        }
    }

    @MainActor
    func processSelectedAttachments(_ attachments: [AttachmentItem]) async {
        if attachments.contains(where: { !$0.isSizeValid(allowedFileSize: attachmentRestrictions.allowedFileSize) }) {
            alertType = .invalidAttachmentSize(allowedFileSize: attachmentRestrictions.allowedFileSize)
        } else {
            for attachment in attachments where self.attachments.contains(attachment) == false {
                self.attachments.append(attachment)
            }
        }
    }

    func isAnyMimeTypeAllowed(_ mimeTypes: [String]) -> Bool {
        mimeTypes.contains { mimeType in
            attachmentRestrictions.allowedTypes.contains { $0.contains(mimeType) }
        }
    }
    
    func checkCameraPermissionAndShowPicker() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            activePickerSheet = .camera
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted {
                        self.activePickerSheet = .camera
                    } else {
                        // User denied permission in the system dialog
                        self.alertType = .cameraPermissionDenied {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
            }
        default:
            // Permission previously denied or restricted — direct user to Settings
            alertType = .cameraPermissionDenied {
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
    @Previewable @State var isInputEnabled = true
    @Previewable @State var isSendingMessage = true
    @Previewable @State var alertType: ChatAlertType?
    
    VStack {
        Spacer()
        
        MessageInputView(
            attachmentRestrictions: MockData.attachmentRestrictions,
            isEditing: $isEditing,
            isInputEnabled: $isInputEnabled,
            isSendingMessage: $isSendingMessage,
            alertType: $alertType
        ) { _, _ in }
    }
    .alertable(
        isPresented: Binding(get: { alertType != nil }, set: { if !$0 { alertType = nil } }),
        presenting: alertType
    )
    .environmentObject(ChatStyle())
}
