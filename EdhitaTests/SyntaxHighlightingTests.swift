//
//  SyntaxHighlightingTests.swift
//  EdhitaTests
//
//  Created by Codex on 2026/04/12.
//

import XCTest
import UIKit

@testable import Edhita

final class SyntaxHighlightingTests: XCTestCase {
    func testLanguageMappingIncludesRequestedFileTypes() {
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.m"), .objectiveC)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.swift"), .swift)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.js"), .javascript)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.html"), .html)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.css"), .css)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.java"), .java)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.ts"), .typescript)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.py"), .python)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.md"), .markdown)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.json"), .json)
        XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.yaml"), .yaml)
    }

    func testHighlighterReturnsAttributedStringWithForegroundColor() {
        let result = SyntaxHighlighter.highlight(
            "let name = \"Edhita\"",
            language: .swift
        )

        let keywordColor = result.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        let stringColor = result.attribute(.foregroundColor, at: 12, effectiveRange: nil) as? UIColor

        XCTAssertNotNil(keywordColor)
        XCTAssertNotNil(stringColor)
        XCTAssertNotEqual(rgbComponents(for: keywordColor), rgbComponents(for: stringColor))
    }

    private func rgbComponents(for color: UIColor?) -> [CGFloat]? {
        guard let color else { return nil }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return [red, green, blue, alpha]
    }
}
