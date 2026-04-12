//
//  DocumentNamingTests.swift
//  EdhitaTests
//
//  Created by Codex on 2026/04/12.
//

import Foundation
import XCTest

@testable import Edhita

final class DocumentNamingTests: XCTestCase {
    func testUniqueURLAddsFullWidthNumberSuffixBeforeExtension() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let original = directory.appendingPathComponent("main.swift")
        try "print(\"hello\")".write(to: original, atomically: true, encoding: .utf8)

        let existingDuplicate = directory.appendingPathComponent("main（1）.swift")
        try "print(\"world\")".write(to: existingDuplicate, atomically: true, encoding: .utf8)

        let uniqueURL = DocumentNameResolver.uniqueURL(for: original, fileManager: .default)

        XCTAssertEqual(uniqueURL.lastPathComponent, "main（2）.swift")
    }
}
