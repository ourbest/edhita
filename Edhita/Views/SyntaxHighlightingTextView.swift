//
//  SyntaxHighlightingTextView.swift
//  Edhita
//
//  Created by Codex on 2026/04/12.
//

import SwiftUI
import UIKit

struct SyntaxHighlightingTextView: UIViewRepresentable {
    @Binding var text: String
    let language: SyntaxHighlightingLanguage
    let font: UIFont
    let textColor: UIColor
    let backgroundColor: UIColor
    let isEditable: Bool
    var onTextView: ((UITextView) -> Void)? = nil

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = backgroundColor
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        onTextView?(textView)
        apply(text: text, to: textView)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.backgroundColor = backgroundColor
        uiView.isEditable = isEditable

        if uiView.text != text {
            apply(text: text, to: uiView)
        } else if context.coordinator.lastLanguage != language
            || context.coordinator.lastFont != font
            || context.coordinator.lastTextColor != textColor
            || context.coordinator.lastBackgroundColorComponents != rgbaComponents(for: backgroundColor)
        {
            apply(text: text, to: uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func apply(text: String, to textView: UITextView) {
        let selectedRange = textView.selectedRange
        textView.attributedText = SyntaxHighlighter.highlight(
            text,
            language: language,
            font: font,
            textColor: textColor,
            backgroundColor: backgroundColor
        )
        textView.selectedRange = clamped(range: selectedRange, in: textView.text)
    }

    private func clamped(range: NSRange, in text: String) -> NSRange {
        let upperBound = max(0, text.utf16.count)
        let location = min(range.location, upperBound)
        let maxLength = upperBound - location
        let length = min(range.length, maxLength)
        return NSRange(location: location, length: length)
    }

    private func rgbaComponents(for color: UIColor) -> [CGFloat]? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return [red, green, blue, alpha]
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        private let parent: SyntaxHighlightingTextView
        fileprivate var lastLanguage: SyntaxHighlightingLanguage
        fileprivate var lastFont: UIFont
        fileprivate var lastTextColor: UIColor
        fileprivate var lastBackgroundColorComponents: [CGFloat]?

        init(_ parent: SyntaxHighlightingTextView) {
            self.parent = parent
            self.lastLanguage = parent.language
            self.lastFont = parent.font
            self.lastTextColor = parent.textColor
            self.lastBackgroundColorComponents = parent.rgbaComponents(for: parent.backgroundColor)
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            refresh(textView)
        }

        private func refresh(_ textView: UITextView) {
            lastLanguage = parent.language
            lastFont = parent.font
            lastTextColor = parent.textColor
            lastBackgroundColorComponents = parent.rgbaComponents(for: parent.backgroundColor)
            let selectedRange = textView.selectedRange
            textView.attributedText = SyntaxHighlighter.highlight(
                parent.text,
                language: parent.language,
                font: parent.font,
                textColor: parent.textColor,
                backgroundColor: parent.backgroundColor
            )
            textView.selectedRange = selectedRange
        }
    }
}
