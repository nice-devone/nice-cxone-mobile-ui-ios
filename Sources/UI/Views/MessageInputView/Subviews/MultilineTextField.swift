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

struct MultilineTextField: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    @EnvironmentObject private var localization: ChatLocalization
    
    @Binding private var attributedText: NSAttributedString
    @Binding private var isEditing: Bool
    
    @State private var contentSizeThatFits: CGSize = .zero
    @State private var timer: Timer?
    @State private var textInputWaitTime = 0
    
    private let onSend: (() -> Void)?
    
    // MARK: - Init
    
    init (
        attributedText: Binding<NSAttributedString>,
        isEditing: Binding<Bool>,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onSend: (() -> Void)? = nil
    ) {
        self._attributedText = attributedText
        self._isEditing = isEditing
        self._contentSizeThatFits = State(initialValue: .zero)
        self.onSend = onSend
    }
    
    // MARK: - Builder
    
    var body: some View {
        AttributedText(
            attributedText: $attributedText,
            isEditing: $isEditing,
            onSend: onSend
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
        .onPreferenceChange(ContentSizeThatFitsKey.self) {
            self.contentSizeThatFits = $0
        }
        .frame(idealHeight: self.contentSizeThatFits.height)
        .background(placeholderView, alignment: .topLeading)
        .padding(.leading, 4)
    }
    
    @ViewBuilder private var placeholderView: some View {
        if attributedText.length == 0 {
            Text(localization.chatMessageInputPlaceholder)
                .foregroundColor(style.formTextColor.opacity(0.5))
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
        }
    }
}

// MARK: - ContentSizeThatFitsKey

struct ContentSizeThatFitsKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - AttributedText

private struct AttributedText: View {
    
    // MARK: - Properties
    
    @Binding var attributedText: NSAttributedString
    @Binding var isEditing: Bool
    
    @State private var sizeThatFits: CGSize = .zero
    
    private let onSend: (() -> Void)?
    
    // MARK: - Init
    
    init(
        attributedText: Binding<NSAttributedString>,
        isEditing: Binding<Bool>,
        onSend: (() -> Void)? = nil
    ) {
        self._attributedText = attributedText
        self._isEditing = isEditing
        self.onSend = onSend
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            UITextViewWrapper(
                attributedText: self.$attributedText,
                isEditing: self.$isEditing,
                sizeThatFits: self.$sizeThatFits,
                maxSize: geometry.size,
                onSend: self.onSend
            )
            .preference(
                key: ContentSizeThatFitsKey.self,
                value: self.sizeThatFits
            )
        }
    }
}

// MARK: - UITextViewWrapper

private struct UITextViewWrapper: UIViewRepresentable {
    
    // MARK: - Properties
    
    @EnvironmentObject private var style: ChatStyle
    
    @Binding var attributedText: NSAttributedString
    @Binding var isEditing: Bool
    @Binding var sizeThatFits: CGSize
    
    private let maxSize: CGSize
    
    private let onSend: (() -> Void)?
    
    // MARK: - Init
    
    init(
        attributedText: Binding<NSAttributedString>,
        isEditing: Binding<Bool>,
        sizeThatFits: Binding<CGSize>,
        maxSize: CGSize,
        onSend: (() -> Void)? = nil
    ) {
        self._attributedText = attributedText
        self._isEditing = isEditing
        self._sizeThatFits = sizeThatFits
        self.maxSize = maxSize
        self.onSend = onSend
    }
    
    // MARK: - Methods
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        
        view.delegate = context.coordinator
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.textColor = UIColor(style.backgroundColor).inverse()
        view.backgroundColor = .clear
        
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return view
    }
    
    @MainActor
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        uiView.textColor = UIColor(style.backgroundColor).inverse()
        
        UITextViewWrapper.recalculateHeight(view: uiView, maxContentSize: self.maxSize, result: $sizeThatFits)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            attributedText: $attributedText,
            isEditing: $isEditing,
            sizeThatFits: $sizeThatFits,
            maxContentSize: { self.maxSize },
            onSend: onSend
        )
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
        @Binding var sizeThatFits: CGSize
        
        @State private var textInputWaitTime: Int = 0
        @State private var timer: Timer?
        
        private let maxContentSize: () -> CGSize
        
        private var onSend: (() -> Void)?
        
        // MARK: - Init
        
        init(
            attributedText: Binding<NSAttributedString>,
            isEditing: Binding<Bool>,
            sizeThatFits: Binding<CGSize>,
            maxContentSize: @escaping () -> CGSize,
            onSend: (() -> Void)?
        ) {
            self._attributedText = attributedText
            self._isEditing = isEditing
            self._sizeThatFits = sizeThatFits
            self.maxContentSize = maxContentSize
            self.onSend = onSend
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
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard let onSend = self.onSend, text == "\n" else {
                return true
            }
            
            textView.resignFirstResponder()
            onSend()
            
            return false
        }
    }
}
