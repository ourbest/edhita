//
//  SyntaxHighlighting.swift
//  Edhita
//
//  Created by Codex on 2026/04/12.
//

import Foundation
import Highlighter
import UIKit

enum SyntaxHighlightingLanguage: Equatable {
    case plainText
    case objectiveC
    case swift
    case javascript
    case html
    case css
    case java
    case typescript
    case python
    case markdown
    case json
    case yaml

    init(filename: String) {
        let extensionName = URL(fileURLWithPath: filename).pathExtension.lowercased()

        switch extensionName {
        case "m", "mm", "h", "hh", "c", "cc", "cpp", "hpp", "pch":
            self = .objectiveC
        case "swift":
            self = .swift
        case "js", "jsx":
            self = .javascript
        case "html", "htm":
            self = .html
        case "css":
            self = .css
        case "java":
            self = .java
        case "ts", "tsx":
            self = .typescript
        case "py":
            self = .python
        case "md", "markdown":
            self = .markdown
        case "json":
            self = .json
        case "yaml", "yml":
            self = .yaml
        default:
            self = .plainText
        }
    }

    var isSyntaxHighlighted: Bool {
        self != .plainText
    }

    var highlighterLanguageName: String? {
        switch self {
        case .plainText:
            return nil
        case .objectiveC:
            return "objectivec"
        case .swift:
            return "swift"
        case .javascript:
            return "javascript"
        case .html:
            return "html"
        case .css:
            return "css"
        case .java:
            return "java"
        case .typescript:
            return "typescript"
        case .python:
            return "python"
        case .markdown:
            return "markdown"
        case .json:
            return "json"
        case .yaml:
            return "yaml"
        }
    }
}

enum SyntaxHighlighter {
    static func highlight(
        _ text: String,
        language: SyntaxHighlightingLanguage,
        font: UIFont = .monospacedSystemFont(ofSize: 15, weight: .regular),
        textColor: UIColor = .label,
        backgroundColor: UIColor? = nil
    ) -> NSAttributedString {
        guard language.isSyntaxHighlighted else {
            return NSAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: textColor,
                ]
            )
        }

        if let highlighted = HighlighterBridge.shared.highlight(
            text,
            language: language,
            font: font,
            backgroundColor: backgroundColor
        ) {
            return highlighted
        }

        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: textColor,
            ]
        )

        switch language {
        case .markdown:
            applyMarkdownHighlighting(to: attributed)
        case .json:
            applyJSONHighlighting(to: attributed)
        case .yaml:
            applyYAMLHighlighting(to: attributed)
        case .html:
            applyHTMLHighlighting(to: attributed)
        case .css:
            applyCSSHighlighting(to: attributed)
        default:
            applyCodeHighlighting(to: attributed, language: language)
        }

        return attributed
    }

    private final class HighlighterBridge {
        static let shared = HighlighterBridge()

        private lazy var lightHighlighter: Highlighter? = makeHighlighter(theme: "github")
        private lazy var darkHighlighter: Highlighter? = makeHighlighter(theme: "github-dark")

        private init() {}

        func highlight(
            _ text: String,
            language: SyntaxHighlightingLanguage,
            font: UIFont,
            backgroundColor: UIColor?
        ) -> NSAttributedString? {
            guard let languageName = language.highlighterLanguageName else {
                return nil
            }

            let highlighter = shouldUseDarkTheme(backgroundColor: backgroundColor)
                ? darkHighlighter
                : lightHighlighter

            guard let highlighter,
                let highlighted = highlighter.highlight(text, as: languageName)
            else {
                return nil
            }

            let mutable = NSMutableAttributedString(attributedString: highlighted)
            mutable.addAttribute(.font, value: font, range: NSRange(location: 0, length: mutable.length))
            if mutable.length > 0 {
                mutable.removeAttribute(.backgroundColor, range: NSRange(location: 0, length: mutable.length))
            }
            return mutable
        }

        private func makeHighlighter(theme: String) -> Highlighter? {
            guard let highlighter = Highlighter() else {
                return nil
            }

            highlighter.setTheme(theme)
            return highlighter
        }

        private func shouldUseDarkTheme(backgroundColor: UIColor?) -> Bool {
            guard let backgroundColor else {
                return false
            }

            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            guard backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
                return false
            }

            let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            return luminance < 0.5
        }
    }

    private static func applyCodeHighlighting(
        to attributed: NSMutableAttributedString,
        language: SyntaxHighlightingLanguage
    ) {
        let text = attributed.string
        let style = SyntaxHighlightingStyle.shared

        applyRegex(
            pattern: "\\b\\d+(?:\\.\\d+)?\\b",
            in: text,
            to: attributed,
            color: style.number
        )

        applyRegex(
            pattern: keywordPattern(for: language),
            in: text,
            to: attributed,
            color: style.keyword
        )

        applyRegex(
            pattern: commentPattern(for: language),
            in: text,
            options: [.anchorsMatchLines, .dotMatchesLineSeparators],
            to: attributed,
            color: style.comment
        )

        applyRegex(
            pattern: stringPattern(for: language),
            in: text,
            options: [.anchorsMatchLines, .dotMatchesLineSeparators],
            to: attributed,
            color: style.string
        )
    }

    private static func applyMarkdownHighlighting(to attributed: NSMutableAttributedString) {
        let text = attributed.string
        let style = SyntaxHighlightingStyle.shared

        applyRegex(
            pattern: "^#{1,6}\\s.*$",
            in: text,
            options: [.anchorsMatchLines],
            to: attributed,
            color: style.keyword
        )
        applyRegex(
            pattern: "```[\\s\\S]*?```",
            in: text,
            options: [.dotMatchesLineSeparators],
            to: attributed,
            color: style.comment
        )
        applyRegex(
            pattern: "`[^`]+`",
            in: text,
            options: [.dotMatchesLineSeparators],
            to: attributed,
            color: style.string
        )
    }

    private static func applyJSONHighlighting(to attributed: NSMutableAttributedString) {
        let text = attributed.string
        let style = SyntaxHighlightingStyle.shared

        applyRegex(
            pattern: "\\b(true|false|null)\\b",
            in: text,
            to: attributed,
            color: style.keyword
        )
        applyRegex(
            pattern: "\\b\\d+(?:\\.\\d+)?\\b",
            in: text,
            to: attributed,
            color: style.number
        )
        applyRegex(
            pattern: "\"(?:\\\\.|[^\"\\\\])*\"",
            in: text,
            options: [.dotMatchesLineSeparators],
            to: attributed,
            color: style.string
        )
    }

    private static func applyYAMLHighlighting(to attributed: NSMutableAttributedString) {
        let text = attributed.string
        let style = SyntaxHighlightingStyle.shared

        applyRegex(
            pattern: "^\\s*#.*$",
            in: text,
            options: [.anchorsMatchLines],
            to: attributed,
            color: style.comment
        )
        applyRegex(
            pattern: "\\b(true|false|null|yes|no|on|off)\\b",
            in: text,
            to: attributed,
            color: style.keyword
        )
        applyRegex(
            pattern: "\\b\\d+(?:\\.\\d+)?\\b",
            in: text,
            to: attributed,
            color: style.number
        )
        applyRegex(
            pattern: "(?m)^\\s*[^:\\n]+(?=\\s*:)",
            in: text,
            options: [.anchorsMatchLines],
            to: attributed,
            color: style.keyword
        )
    }

    private static func applyHTMLHighlighting(to attributed: NSMutableAttributedString) {
        let text = attributed.string
        let style = SyntaxHighlightingStyle.shared

        applyRegex(
            pattern: "<!--[\\s\\S]*?-->",
            in: text,
            options: [.dotMatchesLineSeparators],
            to: attributed,
            color: style.comment
        )
        applyRegex(
            pattern: "</?[A-Za-z][A-Za-z0-9:-]*",
            in: text,
            to: attributed,
            color: style.keyword
        )
        applyRegex(
            pattern: "\\b[A-Za-z:-]+(?=\\=)",
            in: text,
            to: attributed,
            color: style.string
        )
        applyRegex(
            pattern: "\"(?:\\\\.|[^\"\\\\])*\"",
            in: text,
            options: [.dotMatchesLineSeparators],
            to: attributed,
            color: style.string
        )
    }

    private static func applyCSSHighlighting(to attributed: NSMutableAttributedString) {
        let text = attributed.string
        let style = SyntaxHighlightingStyle.shared

        applyRegex(
            pattern: "/\\*[\\s\\S]*?\\*/",
            in: text,
            options: [.dotMatchesLineSeparators],
            to: attributed,
            color: style.comment
        )
        applyRegex(
            pattern: "@[A-Za-z-]+",
            in: text,
            to: attributed,
            color: style.keyword
        )
        applyRegex(
            pattern: "#[A-Za-z0-9_-]+",
            in: text,
            to: attributed,
            color: style.string
        )
        applyRegex(
            pattern: "\\b[A-Za-z-]+(?=\\s*:)",
            in: text,
            to: attributed,
            color: style.keyword
        )
        applyRegex(
            pattern: "\"(?:\\\\.|[^\"\\\\])*\"",
            in: text,
            options: [.dotMatchesLineSeparators],
            to: attributed,
            color: style.string
        )
    }

    private static func applyRegex(
        pattern: String,
        in text: String,
        options: NSRegularExpression.Options = [],
        to attributed: NSMutableAttributedString,
        color: UIColor
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match else { return }
            attributed.addAttribute(.foregroundColor, value: color, range: match.range)
        }
    }

    private static func keywordPattern(for language: SyntaxHighlightingLanguage) -> String {
        let keywords: [String]
        switch language {
        case .objectiveC:
            keywords = [
                "if", "else", "switch", "case", "default", "for", "while", "do",
                "return", "break", "continue", "import", "class", "struct", "enum",
                "protocol", "extension", "public", "private", "fileprivate", "internal",
                "static", "let", "var", "func", "guard", "nil", "YES", "NO", "id",
                "instancetype", "BOOL", "NSInteger", "NSUInteger", "self", "super"
            ]
        case .swift:
            keywords = [
                "if", "else", "switch", "case", "default", "for", "while", "repeat",
                "return", "break", "continue", "import", "class", "struct", "enum",
                "protocol", "extension", "public", "private", "fileprivate", "internal",
                "static", "let", "var", "func", "guard", "nil", "true", "false",
                "throw", "throws", "try", "catch", "as", "is", "in", "where", "self"
            ]
        case .javascript, .typescript:
            keywords = [
                "if", "else", "switch", "case", "default", "for", "while", "do",
                "return", "break", "continue", "import", "export", "class", "extends",
                "function", "const", "let", "var", "new", "this", "true", "false",
                "null", "undefined", "async", "await", "try", "catch", "throw"
            ]
        case .java:
            keywords = [
                "if", "else", "switch", "case", "default", "for", "while", "do",
                "return", "break", "continue", "import", "class", "interface", "extends",
                "implements", "public", "private", "protected", "static", "final",
                "void", "new", "true", "false", "null", "try", "catch", "throw"
            ]
        case .python:
            keywords = [
                "if", "elif", "else", "for", "while", "def", "class", "return",
                "import", "from", "as", "pass", "break", "continue", "True", "False",
                "None", "try", "except", "with", "lambda", "yield", "global", "nonlocal"
            ]
        default:
            keywords = []
        }

        guard !keywords.isEmpty else { return "\\b\\B" }
        return "\\b(" + keywords.map(NSRegularExpression.escapedPattern(for:)).joined(separator: "|") + ")\\b"
    }

    private static func commentPattern(for language: SyntaxHighlightingLanguage) -> String {
        switch language {
        case .python, .yaml:
            return "^\\s*#.*$"
        case .html:
            return "<!--[\\s\\S]*?-->"
        default:
            return "//.*$|/\\*[\\s\\S]*?\\*/"
        }
    }

    private static func stringPattern(for language: SyntaxHighlightingLanguage) -> String {
        switch language {
        case .python:
            return "\"(?:\\\\.|[^\"\\\\])*\"|'(?:\\\\.|[^'\\\\])*'"
        default:
            return "\"(?:\\\\.|[^\"\\\\])*\"|'(?:\\\\.|[^'\\\\])*'"
        }
    }
}

private struct SyntaxHighlightingStyle {
    static let shared = SyntaxHighlightingStyle()

    let keyword = UIColor.systemBlue
    let string = UIColor.systemRed
    let comment = UIColor.systemGreen
    let number = UIColor.systemOrange
}
