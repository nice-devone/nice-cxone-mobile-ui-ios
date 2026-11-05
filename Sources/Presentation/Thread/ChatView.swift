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

import SwiftUI

struct ChatView: View, Themed {
    
    // MARK: - Constants
    
    private enum Constants {
        
        static let bottomID = "bottom"

        enum Spacing {
            static let bodyVertical: CGFloat = 0
            static let messageGroupsMinLength: CGFloat = 16
            static let archivedChatMessage: CGFloat = 14
            static let archivedChatElementsHorizontal: CGFloat = 12
        }
        
        enum Padding {
            static let positionInQueueVertical: CGFloat = 32
            static let positionInQueueHorizontal: CGFloat = 16
            static let typingIndicatorLeading: CGFloat = 16
            /// Clearance below the archived-chat message on home-button devices, which have no bottom
            /// safe-area inset to keep it off the screen edge.
            ///
            /// Takes the measured bottom inset rather than reading `UIDevice.hasHomeButton`, whose
            /// key-window `safeAreaInsets` query can re-enter the SwiftUI graph mid-update on iOS 26
            /// (see `BottomSheetView.Constants.Padding.contentBottomMinimum`). `nil` — not measured
            /// yet — resolves to no padding, the value on the Face ID devices most users have.
            static func archivedChatMessageBottom(bottomSafeAreaInset: CGFloat?) -> CGFloat {
                guard let bottomSafeAreaInset, bottomSafeAreaInset.isNegligibleSafeAreaInset else {
                    return .zero
                }

                return 14
            }
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @SwiftUI.Environment(\.colorScheme) var scheme
    
    @Binding private var hasMoreMessagesToLoad: Bool
    @Binding private var typingAgent: ChatUser?
    @Binding private var isUserTyping: Bool
    @Binding private var isInputEnabled: Bool
    @Binding private var isThreadClosed: Bool
    @Binding private var alertType: ChatAlertType?
    @Binding private var messageGroups: [MessageGroup]
    @Binding private var isSendingMessage: Bool
    @Binding private var attachments: [AttachmentItem]

    /// Whether a keyboard raised by the message input is taking enough height away from the conversation
    /// for the attachment strip — inset at the bottom of it — to shrink.
    @State private var keyboardCoverage = KeyboardCoverageState()

    /// Whether the message input is the first responder. Mirrored out of `MessageInputView` because a
    /// keyboard notification alone doesn't say whose keyboard it is.
    @State private var isInputFocused = false

    /// Bottom safe-area inset below the archived-chat message, measured by `bottomSafeAreaInsetReader`.
    @State private var bottomSafeAreaInset: CGFloat?

    private let attachmentRestrictions: AttachmentRestrictions
    private let isLiveChat: Bool
    private let onNewMessage: (ChatMessageType, [AttachmentItem]) -> Void
    private let loadMoreMessages: () async -> Void
    private let onRichMessageElementSelected: (RichMessageSubElementType) -> Void
    private let queuePosition: Int?
    
    static let packageIdentifier = "CXoneChatUI"
    
    // MARK: - Init
    
    init(
        messageGroups: Binding<[MessageGroup]>,
        attachments: Binding<[AttachmentItem]>,
        hasMoreMessagesToLoad: Binding<Bool>,
        typingAgent: Binding<ChatUser?>,
        isUserTyping: Binding<Bool>,
        isInputEnabled: Binding<Bool>,
        isThreadClosed: Binding<Bool>,
        isSendingMessage: Binding<Bool>,
        isLiveChat: Bool,
        alertType: Binding<ChatAlertType?>,
        attachmentRestrictions: AttachmentRestrictions,
        queuePosition: Int? = nil,
        onNewMessage: @escaping (ChatMessageType, [AttachmentItem]) -> Void,
        loadMoreMessages: @escaping () async -> Void,
        onRichMessageElementSelected: @escaping (RichMessageSubElementType) -> Void
    ) {
        self._messageGroups = messageGroups
        self._attachments = attachments
        self._hasMoreMessagesToLoad = hasMoreMessagesToLoad
        self._typingAgent = typingAgent
        self._isUserTyping = isUserTyping
        self._isInputEnabled = isInputEnabled
        self._isThreadClosed = isThreadClosed
        self._alertType = alertType
        self._isSendingMessage = isSendingMessage
        self.attachmentRestrictions = attachmentRestrictions
        self.isLiveChat = isLiveChat
        self.queuePosition = queuePosition
        self.onNewMessage = onNewMessage
        self.loadMoreMessages = loadMoreMessages
        self.onRichMessageElementSelected = onRichMessageElementSelected
    }
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: Constants.Spacing.bodyVertical) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: .zero, pinnedViews: .sectionHeaders) {
                        Section {
                            ForEach(messageGroups) { group in
                                MessageGroupView(
                                    group: group,
                                    isLast: messageGroups.last?.id == group.id,
                                    alertType: $alertType,
                                    onRichMessageElementSelected: onRichMessageElementSelected
                                )
                                .id(group.id)
                            }
                        
                            if let typingAgent {
                                typingIndicator(agent: typingAgent)
                                    .padding(.leading, Constants.Padding.typingIndicatorLeading)
                            }
                        } header: {
                            if let queuePosition {
                                LivechatPositionInQueueView(position: queuePosition)
                                    .padding(.vertical, Constants.Padding.positionInQueueVertical)
                                    .padding(.horizontal, Constants.Padding.positionInQueueHorizontal)
                            }
                        }
                    }
                    .onChange(of: messageGroups) { _ in
                        // On iOS 16, `.onChange` runs before the appended message has laid
                        // out, so a synchronous `scrollTo` targets the previous bottom.
                        // Schedule on a fresh MainActor turn so layout completes first. DE-175228.
                        Task { @MainActor in
                            withAnimation {
                                proxy.scrollTo(Constants.bottomID, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: typingAgent?.id) { newValue in
                        guard newValue != nil else {
                            return
                        }

                        if let name = typingAgent?.userName {
                            A11y.announce(A11y.Announcement.Conversation.TypingIndicator.started(name))
                        } else {
                            A11y.announce(A11y.Announcement.Conversation.TypingIndicator.Started.unknown)
                        }

                        // Driven from the agent rather than the indicator's own `onAppear`, which the
                        // enclosing `LazyVStack` only runs once the indicator is near the viewport —
                        // reading history would otherwise leave the conversation where it was. The
                        // deferred scroll is the same iOS 16 timing quirk as above. DE-175228.
                        Task { @MainActor in
                            withAnimation {
                                proxy.scrollTo(Constants.bottomID, anchor: .bottom)
                            }
                        }
                    }
                    .task { @MainActor in
                        // `onChange` above never fires for the value the view starts with, so an agent
                        // already typing when a conversation opens is handled here. `bottomID` would
                        // serve both cases, but the no-indicator path keeps its existing anchor on the
                        // last group so the initial offset — and every reference recorded against it —
                        // stays put.
                        if typingAgent == nil {
                            proxy.scrollTo(messageGroups.last?.id, anchor: .bottom)
                        } else {
                            proxy.scrollTo(Constants.bottomID, anchor: .bottom)
                        }
                    }

                    Spacer(minLength: Constants.Spacing.messageGroupsMinLength)
                        .id(Constants.bottomID)
                }
                .if(hasMoreMessagesToLoad) { view in
                    view.refreshable {
                        await loadMoreMessages()
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()
                // The staged attachments belong to the conversation's space, not the input bar's: their
                // height comes out of the scroll area, so the bar's height — and therefore whether it
                // clears the keyboard — never depends on how many attachments are staged or how large
                // the Dynamic Type setting is.
                .safeAreaInset(edge: .bottom, spacing: Constants.Spacing.bodyVertical) {
                    if !attachments.isEmpty, !isThreadClosed {
                        MessageInputAttachmentListView(
                            attachments: $attachments,
                            alertType: $alertType,
                            isKeyboardVisible: keyboardCoverage.isCoveringConversation
                        )
                        // Opaque — the conversation scrolls underneath the inset. No tap-to-dismiss
                        // here: as a simultaneous gesture it would fire for the remove buttons too, so
                        // deleting an attachment would also resign the input the user is typing in.
                        .background(colors.background.default)
                    }
                }
            }

            if isThreadClosed {
                archivedChatMessage
                    .padding(.bottom, Constants.Padding.archivedChatMessageBottom(bottomSafeAreaInset: bottomSafeAreaInset))
                    .background(bottomSafeAreaInsetReader)
            } else {
                MessageInputView(
                    attachmentRestrictions: attachmentRestrictions,
                    attachments: $attachments,
                    isEditing: $isUserTyping,
                    isInputFocused: $isInputFocused,
                    isInputEnabled: $isInputEnabled,
                    isSendingMessage: $isSendingMessage,
                    alertType: $alertType,
                    onSend: onNewMessage
                )
            }
        }
        .background(colors.background.default)
        // Hosted here, above the conversation's `LazyVStack`, so an attachment preview survives its cell
        // being unloaded — which the stack does routinely, and which a rotation provokes by reflowing
        // every bubble to the new width. See `AttachmentPreviewHost`.
        .attachmentPreviewHost(alertType: $alertType)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect

            keyboardCoverage.keyboardWillShow(height: frame?.height)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardCoverage.keyboardWillHide()
        }
        .onChange(of: isInputFocused) { isFocused in
            keyboardCoverage.inputFocusChanged(to: isFocused)
        }
    }
}

// MARK: - Subviews

private extension ChatView {

    func typingIndicator(agent: ChatUser?) -> some View {
        HStack {
            TypingIndicator(agent: agent)

            Spacer()
        }
    }

    /// Reports the bottom safe-area inset into `bottomSafeAreaInset`.
    ///
    /// The reader must respect the safe area: its proxy then reports the inset it borders. Adding
    /// `ignoresSafeArea` would make it report zero for that edge instead. Assigned from
    /// `onAppear`/`onChange` rather than during the reader's own body, which would be a state mutation
    /// inside a layout pass.
    var bottomSafeAreaInsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    bottomSafeAreaInset = proxy.safeAreaInsets.bottom
                }
                .onChange(of: proxy.safeAreaInsets.bottom) { newInset in
                    bottomSafeAreaInset = newInset
                }
        }
        .accessibilityHidden(true)
    }
    
    var archivedChatMessage: some View {
        VStack(spacing: Constants.Spacing.archivedChatMessage) {
            ColoredDivider(colors.border.default)
                .ignoresSafeArea(.container, edges: .horizontal)
                .accessibilityHidden(true)

            HStack(spacing: Constants.Spacing.archivedChatElementsHorizontal) {
                Asset.Message.archiveFill
                    .accessibilityHidden(true)

                Text(
                    isLiveChat
                        ? L10n.Chat.MessageInput.closed
                        : L10n.Chat.MessageInput.archived
                )
            }
            .foregroundStyle(colors.content.tertiary)
        }
        .background(colors.background.default, ignoresSafeAreaEdges: .horizontal)
    }
}

// MARK: - Previews

#Preview {
    let messageGroups = [
        MockData.textMessage(user: MockData.agent),
        MockData.imageMessage(user: MockData.customer),
        MockData.emojiMessage(user: MockData.agent)
    ].groupMessages(interval: MessageGroup.defaultGroupingInterval)
    let alertType: ChatAlertType? = nil

    NavigationStack {
        ChatView(
            messageGroups: .constant(messageGroups),
            attachments: .constant([MockData.imageItem(imageIndex: 1)]),
            hasMoreMessagesToLoad: .constant(true),
            typingAgent: .constant(MockData.agent),
            isUserTyping: .constant(false),
            isInputEnabled: .constant(true),
            isThreadClosed: .constant(false),
            isSendingMessage: .constant(false),
            isLiveChat: false,
            alertType: .constant(alertType),
            attachmentRestrictions: MockData.attachmentRestrictions,
            queuePosition: 3,
            onNewMessage: { _, _ in },
            loadMoreMessages: { },
            onRichMessageElementSelected: { _ in }
        )
    }
    .environmentObject(ChatStyle())
}
