# Syntax Highlighting Editor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add in-app syntax highlighting for common code and data files while keeping the file format plain text and preserving existing open/import behavior.

**Architecture:** Keep the document model as plain `String` content stored on disk. Replace the current `TextEditor`-based editing surface with a `UITextView` wrapper that renders an attributed string and re-highlights on load and edit. Use filename extensions to select lightweight highlighting rules for `oc`, `swift`, `js`, `html`, `css`, `java`, `ts`, `python`, `md`, `json`, and `yaml`.

**Tech Stack:** SwiftUI, UIKit, TextKit/`UITextView`, XCTest.

### Task 1: Add failing tests for language detection and coordinator import handling

**Files:**
- Create: `EdhitaTests/SyntaxHighlightingTests.swift`
- Modify: `EdhitaTests/DocumentOpenCoordinatorTests.swift`

**Step 1: Write the failing test**

```swift
func testHighlightLanguageMappingIncludesMarkdownJsonAndYaml() {
    XCTAssertEqual(SyntaxHighlightingLanguage(filename: "note.md"), .markdown)
    XCTAssertEqual(SyntaxHighlightingLanguage(filename: "data.json"), .json)
    XCTAssertEqual(SyntaxHighlightingLanguage(filename: "config.yaml"), .yaml)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project Edhita.xcodeproj -scheme Edhita -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:EdhitaTests/SyntaxHighlightingTests`
Expected: FAIL with missing type/member errors.

**Step 3: Write minimal implementation**

Add the language enum and filename mapping only.

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project Edhita.xcodeproj -scheme Edhita -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:EdhitaTests/SyntaxHighlightingTests`
Expected: PASS.

**Step 5: Commit**

```bash
git add EdhitaTests/SyntaxHighlightingTests.swift
git commit -m "test: add syntax highlighting language mapping tests"
```

### Task 2: Implement the syntax-highlighting text editor

**Files:**
- Create: `Edhita/Views/SyntaxHighlightingTextView.swift`
- Create: `Edhita/Models/SyntaxHighlighting.swift`
- Modify: `Edhita/Views/EditorView.swift`

**Step 1: Write the failing test**

```swift
func testHighlighterColorsMarkdownHeadingsAndCodeFences() {
    let attributed = SyntaxHighlighter.highlight("## Title\n```swift\nlet x = 1\n```", language: .markdown)
    XCTAssertNotNil(attributed.attribute(.foregroundColor, at: 0, effectiveRange: nil))
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project Edhita.xcodeproj -scheme Edhita -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:EdhitaTests/SyntaxHighlightingTests`
Expected: FAIL until the highlighter exists.

**Step 3: Write minimal implementation**

Implement `SyntaxHighlighter` with simple token rules for strings, comments, keywords, numbers, tags, and markdown markers.

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project Edhita.xcodeproj -scheme Edhita -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:EdhitaTests/SyntaxHighlightingTests`
Expected: PASS.

**Step 5: Commit**

```bash
git add Edhita/Models/SyntaxHighlighting.swift Edhita/Views/SyntaxHighlightingTextView.swift Edhita/Views/EditorView.swift
git commit -m "feat: add syntax highlighted text editor"
```

### Task 3: Wire file types into the editor and keep plain-text save behavior

**Files:**
- Modify: `Edhita/Views/EditorView.swift`
- Modify: `Edhita/Models/FinderItem.swift`

**Step 1: Write the failing test**

```swift
func testEditorUsesFilenameExtensionForLanguageSelection() {
    XCTAssertEqual(SyntaxHighlightingLanguage(filename: "script.ts"), .typescript)
    XCTAssertEqual(SyntaxHighlightingLanguage(filename: "main.m"), .objectiveC)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project Edhita.xcodeproj -scheme Edhita -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:EdhitaTests/SyntaxHighlightingTests`
Expected: FAIL if mapping is incomplete.

**Step 3: Write minimal implementation**

Extend the filename-to-language mapping and connect the editor to it.

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -project Edhita.xcodeproj -scheme Edhita -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:EdhitaTests/SyntaxHighlightingTests`
Expected: PASS.

**Step 5: Commit**

```bash
git add Edhita/Views/EditorView.swift Edhita/Models/FinderItem.swift
git commit -m "feat: detect syntax highlighting language from filenames"
```

### Task 4: Verify device build

**Files:**
- No new files

**Step 1: Run the build**

Run: `xcodebuild -project Edhita.xcodeproj -scheme Edhita -configuration Debug -sdk iphoneos -destination 'generic/platform=iOS' -allowProvisioningUpdates build`

**Step 2: Confirm result**

Expected: `** BUILD SUCCEEDED **`

**Step 3: Commit**

```bash
git add .
git commit -m "feat: add syntax highlighting editor"
```
