//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
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

struct MessageInputView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject private var audioRecorder = AudioRecorder()
    
    @Binding private var isEditing: Bool
    
    @State private var message = ""
    @State private var attachments = [AttachmentItem]()
    @State private var attachmentsPickerSheet: (visible: Bool, type: UIImagePickerController.SourceType) = (false, .camera)
    @State private var contentSizeThatFits: CGSize = .zero
    @State private var showAttachmentsSheet = false
    @State private var showDocumentPickerSheet = false
    
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
    
    init(isEditing: Binding<Bool>, onSend: @escaping (ChatMessageType, [AttachmentItem]) -> Void) {
        self._isEditing = isEditing
        self._contentSizeThatFits = State(initialValue: .zero)
        self.onSend = onSend
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: 0) {
            if !attachments.isEmpty {
                AttachmentListView(attachments: $attachments)
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                if audioRecorder.state == .idle {
                    attachmentsButton
                    
                    Button {
                        withAnimation {
                            audioRecorder.record()
                        }
                    } label: {
                        Asset.Attachment.recordVoice
                            .imageScale(.large)
                    }
                    .foregroundColor(style.customerCellColor)
                    .frame(width: 32, height: 32)
                }
                
                inputBar
                
                if audioRecorder.state != .idle {
                    voiceMessageButtons
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 16)
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
        .frame(width: 32, height: 32)
        .actionSheet(isPresented: $showAttachmentsSheet) {
            attachmentsSourceActionSheet
        }
        .sheet(isPresented: $attachmentsPickerSheet.visible) {
            MediaPickerView(sourceType: attachmentsPickerSheet.type) { attachment in
                self.attachments.append(attachment)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showDocumentPickerSheet) {
            DocumentPickerView { attachments in
                self.attachments.append(contentsOf: attachments)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var attachmentsSourceActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Attachments Source"),
            buttons: [
                .default(Text("Camera")) {
                    attachmentsPickerSheet = (true, .camera)
                },
                .default(Text("Photo Library")) {
                    attachmentsPickerSheet = (true, .photoLibrary)
                },
                .default(Text("File Manager")) {
                    showDocumentPickerSheet = true
                },
                .cancel()
            ]
        )
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
            RoundedRectangle(cornerRadius: 20)
                .stroke(style.backgroundColor.opacity(0.25)).colorInvert()
        )
    }
    
    var audioRecorderInputBar: some View {
        Group {
            Asset.waveform
                .foregroundColor(style.customerCellColor)
                .padding(.leading, 8)
            
            if case .recording = audioRecorder.state {
                AnimatedDotsView(text: "Recording")
                    .padding(.leading, 4)
            } else if case .playing = audioRecorder.state {
                AnimatedDotsView(text: "Playing")
                    .padding(.leading, 4)
            }
            
            Spacer()
            
            if audioRecorder.state == .recorded {
                Text(audioRecorder.formattedLength)
                    .foregroundColor(style.backgroundColor).colorInvert()
            } else {
                Text(audioRecorder.formattedCurrentTime)
                    .foregroundColor(style.backgroundColor).colorInvert()
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
                .frame(width: 32, height: 32)
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
    
    @ViewBuilder
    var sendButtonBackground: some View {
        if isSendButtonDisabled {
            Circle()
                .fill(style.backgroundColor.opacity(0.5)).colorInvert()
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
                    .frame(width: 32, height: 32)
                    .overlay(
                        recordingControlButtonOverlay
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                    )
            }
            .padding(3)
        
            Button {
                audioRecorder.delete()
            } label: {
                Circle()
                    .fill(Color(.red))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Asset.Attachment.deleteVoice
                            .foregroundColor(.white)
                    )
            }
            .padding(3)
        }
    }
    
    @ViewBuilder
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

// MARK: - Preview

struct MessageInputView_Previews: PreviewProvider {
    
    @State private static var isEditing = false
    
    static var previews: some View {
        Group {
            VStack {
                Spacer()
                
                MessageInputView(isEditing: $isEditing) { _, _ in }
            }
            .previewDisplayName("Light Mode")
            
            VStack {
                Spacer()
                
                MessageInputView(isEditing: $isEditing) { _, _ in }
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .environmentObject(ChatStyle())
    }
}
