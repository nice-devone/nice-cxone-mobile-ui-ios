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

import SwiftUI

struct LegacyMultilineTextField: View, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @Environment(\.colorScheme) var scheme
    
    @Binding private var attributedText: NSAttributedString
    @Binding private var isEditing: Bool
    @Binding private var isInputEnabled: Bool
    
    @State private var contentSizeThatFits: CGSize = .zero
    @State private var timer: Timer?
    @State private var textInputWaitTime = 0
    
    private static let placeholderPaddingVertical: CGFloat = 8
    private static let placeholderPaddingHorizontal: CGFloat = 10
    private static let typingIndicatorPaddingLeading: CGFloat = 6
    
    // MARK: - Init
    
    init (
        attributedText: Binding<NSAttributedString>,
        isEditing: Binding<Bool>,
        isInputEnabled: Binding<Bool>
    ) {
        self._attributedText = attributedText
        self._isEditing = isEditing
        self._isInputEnabled = isInputEnabled
        self._contentSizeThatFits = State(initialValue: .zero)
    }
    
    // MARK: - Builder
    
    var body: some View {
        AttributedText(
            attributedText: $attributedText,
            isEditing: $isEditing,
            isInputEnabled: $isInputEnabled
        )
        .onChange(of: attributedText) { _ in
            if timer != nil {
                if textInputWaitTime > 0 {
                    textInputWaitTime = 0
                }
            } else {
                isEditing = true
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    textInputWaitTime += 1
                    
                    if textInputWaitTime >= 3 {
                        timer.invalidate()
                        
                        isEditing = false
                        textInputWaitTime = 0
                        self.timer = nil
                    }
                }
            }
        }
        .onPreferenceChange(PreferenceKeys.ContentSizeThatFitsKey.self) { size in
            self.contentSizeThatFits = size
        }
        .frame(height: attributedText.length == 0 ? StyleGuide.buttonDimension : contentSizeThatFits.height)
        .padding(.leading, Self.typingIndicatorPaddingLeading)
        .background(placeholderView, alignment: .topLeading)
    }
    
    @ViewBuilder private var placeholderView: some View {
        if attributedText.length == 0 {
            Text(localization.chatMessageInputPlaceholder)
                .font(.body)
                .foregroundColor(colors.customizable.onBackground.opacity(0.5))
                .padding(.vertical, Self.placeholderPaddingVertical)
                .padding(.horizontal, Self.placeholderPaddingHorizontal)
        }
    }
}

// MARK: - AttributedText

private struct AttributedText: View {
    
    // MARK: - Properties
    
    @Binding var attributedText: NSAttributedString
    @Binding var isEditing: Bool
    @Binding private var isInputEnabled: Bool
    
    @State private var sizeThatFits: CGSize = .zero
    
    // MARK: - Init
    
    init(
        attributedText: Binding<NSAttributedString>,
        isEditing: Binding<Bool>,
        isInputEnabled: Binding<Bool>
    ) {
        self._attributedText = attributedText
        self._isEditing = isEditing
        self._isInputEnabled = isInputEnabled
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            UITextViewWrapper(
                attributedText: self.$attributedText,
                isEditing: self.$isEditing,
                isInputEnabled: $isInputEnabled,
                sizeThatFits: self.$sizeThatFits,
                maxSize: geometry.size
            )
            .preference(
                key: PreferenceKeys.ContentSizeThatFitsKey.self,
                value: self.sizeThatFits
            )
        }
    }
}

// MARK: - UITextViewWrapper

private struct UITextViewWrapper: UIViewRepresentable, Themed {
    
    // MARK: - Properties
    
    @EnvironmentObject var style: ChatStyle
    
    @Environment(\.colorScheme) var scheme
    
    @Binding var attributedText: NSAttributedString
    @Binding var isEditing: Bool
    @Binding var isInputEnabled: Bool
    @Binding var sizeThatFits: CGSize
    
    private let maxSize: CGSize
    
    // MARK: - Init
    
    init(
        attributedText: Binding<NSAttributedString>,
        isEditing: Binding<Bool>,
        isInputEnabled: Binding<Bool>,
        sizeThatFits: Binding<CGSize>,
        maxSize: CGSize
    ) {
        self._attributedText = attributedText
        self._isEditing = isEditing
        self._isInputEnabled = isInputEnabled
        self._sizeThatFits = sizeThatFits
        self.maxSize = maxSize
    }
    
    // MARK: - Methods
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        
        view.delegate = context.coordinator
        view.isEditable = isInputEnabled
        view.isSelectable = isInputEnabled
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.textColor = UIColor(colors.customizable.onBackground)
        view.backgroundColor = .clear
        
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return view
    }
    
    @MainActor
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        uiView.textColor = UIColor(colors.customizable.onBackground)
        uiView.isEditable = isInputEnabled
        uiView.isSelectable = isInputEnabled
        
        UITextViewWrapper.recalculateHeight(view: uiView, maxContentSize: self.maxSize, result: $sizeThatFits)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            attributedText: $attributedText,
            isEditing: $isEditing,
            isInputEnabled: $isInputEnabled,
            sizeThatFits: $sizeThatFits
        ) {
            self.maxSize
        }
    }
    
    private static func recalculateHeight(view: UIView, maxContentSize: CGSize, result: Binding<CGSize>) {
        let sizeThatFits = view.sizeThatFits(maxContentSize)
        
        if result.wrappedValue != sizeThatFits {
            Task {
                result.wrappedValue = sizeThatFits
            }
        }
    }
    
    // MARK: - Coordinator
    
    final class Coordinator: NSObject, UITextViewDelegate {
        
        // MARK: - Properties
        
        @Binding var attributedText: NSAttributedString
        @Binding var isEditing: Bool
        @Binding var isInputEnabled: Bool
        @Binding var sizeThatFits: CGSize
        
        private let maxContentSize: () -> CGSize
        
        // MARK: - Init
        
        init(
            attributedText: Binding<NSAttributedString>,
            isEditing: Binding<Bool>,
            isInputEnabled: Binding<Bool>,
            sizeThatFits: Binding<CGSize>,
            maxContentSize: @escaping () -> CGSize
        ) {
            self._attributedText = attributedText
            self._isEditing = isEditing
            self._isInputEnabled = isInputEnabled
            self._sizeThatFits = sizeThatFits
            self.maxContentSize = maxContentSize
        }
        
        func textViewDidChange(_ uiView: UITextView) {
            attributedText = uiView.attributedText
            
            UITextViewWrapper.recalculateHeight(
                view: uiView,
                maxContentSize: maxContentSize(),
                result: $sizeThatFits
            )
        }
        
        func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            true
        }
        
        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            isInputEnabled
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var contentSizeThatFits: CGSize = .zero
    @Previewable @State var message = ""
    @Previewable @State var isEditing = false
    
    var attributedMessage: Binding<NSAttributedString> {
        Binding<NSAttributedString>(
            get: {
                NSAttributedString(
                    string: message,
                    attributes: [
                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                        NSAttributedString.Key.foregroundColor: UIColor.black
                    ]
                )
            },
            set: { newMessage in
                Task {
                    message = newMessage.string
                }
            }
        )
    }
    
    VStack {
        LegacyMultilineTextField(attributedText: attributedMessage, isEditing: $isEditing, isInputEnabled: .constant(true))
            .onPreferenceChange(PreferenceKeys.ContentSizeThatFitsKey.self) { size in
                contentSizeThatFits = size
            }
            .frame(height: min(contentSizeThatFits.height, 0.25 * UIScreen.main.bounds.height))
    }
    .background(
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray)
    )
    .padding(20)
    .environmentObject(ChatStyle())
    .environmentObject(ChatLocalization())
}
