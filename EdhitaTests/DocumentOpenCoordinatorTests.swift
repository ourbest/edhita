//
//  DocumentOpenCoordinatorTests.swift
//  EdhitaTests
//
//  Created by Codex on 2026/04/12.
//

import XCTest

@testable import Edhita

@MainActor
final class DocumentOpenCoordinatorTests: XCTestCase {
    func testHandleIncomingOpensFileInsideRootWithoutCopying() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let fileURL = root.appendingPathComponent("note.txt")
        try "root".write(to: fileURL, atomically: true, encoding: .utf8)

        let coordinator = DocumentOpenCoordinator(rootURL: root)

        coordinator.handleIncoming(url: fileURL)

        XCTAssertEqual(coordinator.presentation?.item.url, fileURL)
    }

    func testHandleIncomingCopiesExternalFileIntoRootAndPresentsIt() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let external = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: external, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: root)
            try? FileManager.default.removeItem(at: external)
        }

        let fileURL = external.appendingPathComponent("note.txt")
        try "external".write(to: fileURL, atomically: true, encoding: .utf8)

        let coordinator = DocumentOpenCoordinator(rootURL: root)
        let initialToken = coordinator.rootRefreshToken

        coordinator.handleIncoming(url: fileURL)

        let expectedURL = root.appendingPathComponent("note.txt")
        XCTAssertEqual(coordinator.presentation?.item.url, expectedURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedURL.path))
        XCTAssertNotEqual(coordinator.rootRefreshToken, initialToken)
    }
}
