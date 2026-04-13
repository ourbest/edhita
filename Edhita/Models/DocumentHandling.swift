//
//  DocumentHandling.swift
//  Edhita
//
//  Created by Codex on 2026/04/12.
//

import Foundation
import UIKit

enum DocumentURLAccess {
    static func perform<T>(with url: URL, _ block: () throws -> T) rethrows -> T {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        return try block()
    }
}

enum DocumentNameResolver {
    static func uniqueURL(for url: URL, fileManager: FileManager = .default) -> URL {
        let directory = url.deletingLastPathComponent()
        let baseName = baseName(for: url)
        let fileExtension = url.pathExtension.isEmpty ? "" : ".\(url.pathExtension)"

        var candidate = url
        var suffix = 1
        while fileManager.fileExists(atPath: candidate.path) {
            candidate = directory.appendingPathComponent("\(baseName)（\(suffix)）\(fileExtension)")
            suffix += 1
        }

        return candidate
    }

    private static func baseName(for url: URL) -> String {
        guard !url.pathExtension.isEmpty else { return url.lastPathComponent }
        return url.deletingPathExtension().lastPathComponent
    }
}

struct DocumentPresentation: Identifiable {
    let id = UUID()
    let item: FinderItem
}

@MainActor
final class DocumentOpenCoordinator: ObservableObject {
    static let shared = DocumentOpenCoordinator()

    private let rootURL: URL
    private let fileManager: FileManager

    @Published var presentation: DocumentPresentation?
    @Published var rootRefreshToken = UUID()

    init(
        rootURL: URL = FinderList.rootURL,
        fileManager: FileManager = .default
    ) {
        self.rootURL = rootURL
        self.fileManager = fileManager
    }

    func handleIncoming(url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) {
        guard url.isFileURL else { return }

        let targetURL: URL
        if shouldOpenInPlace(url: url, options: options) {
            targetURL = url
        } else if let importedURL = importIntoDocuments(url: url) {
            targetURL = importedURL
        } else {
            return
        }

        presentation = DocumentPresentation(item: FinderItem(url: targetURL))
    }

    private func shouldOpenInPlace(
        url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        _ = options

        let rootPath = rootURL.standardizedFileURL.path
        let documentPath = url.standardizedFileURL.path
        if documentPath == rootPath || documentPath.hasPrefix(rootPath + "/") {
            return true
        }

        return false
    }

    private func importIntoDocuments(url: URL) -> URL? {
        let destination = DocumentNameResolver.uniqueURL(
            for: rootURL.appendingPathComponent(url.lastPathComponent),
            fileManager: fileManager
        )

        do {
            try DocumentURLAccess.perform(with: url) {
                try fileManager.copyItem(at: url, to: destination)
            }
            rootRefreshToken = UUID()
            return destination
        } catch {
            return nil
        }
    }
}
