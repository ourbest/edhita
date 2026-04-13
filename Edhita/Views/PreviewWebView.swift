//
//  PreviewWebView.swift
//  Edhita
//
//  Created by Tatsuya Tobioka on 2022/07/27.
//

import Ink
import SwiftUI
import WebKit

struct PreviewWebView: UIViewRepresentable {
    let url: URL
    let reloader: Bool

    func makeUIView(context: Context) -> WKWebView {
        WKWebView(frame: .zero)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if isMarkdown {
            if let markdown = try? String(contentsOf: url) {
                let parser = MarkdownParser()
                let html = parser.html(from: markdown)
                uiView.loadHTMLString(html, baseURL: url.deletingLastPathComponent())
            }
        } else if isHTML {
            let req = URLRequest(url: url)
            uiView.load(req)
        } else {
            if let source = try? String(contentsOf: url) {
                uiView.loadHTMLString(
                    sourceHTML(from: source),
                    baseURL: url.deletingLastPathComponent()
                )
            }
        }
    }

    private var isMarkdown: Bool {
        url.lastPathComponent.hasSuffix(".md") || url.lastPathComponent.hasSuffix(".markdown")
    }

    private var isHTML: Bool {
        url.lastPathComponent.hasSuffix(".html") || url.lastPathComponent.hasSuffix(".htm")
    }

    private var sourceLanguage: String {
        SyntaxHighlightingLanguage(filename: url.lastPathComponent)
            .highlighterLanguageName ?? "plaintext"
    }

    private func sourceHTML(from source: String) -> String {
        let encodedSource = Data(source.utf8).base64EncodedString()
        let theme = colorScheme == .dark ? "github-dark.min.css" : "github.min.css"
        let backgroundColor = colorScheme == .dark ? "#0d1117" : "#ffffff"
        let textColor = colorScheme == .dark ? "#c9d1d9" : "#24292f"

        return """
        <!doctype html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
            <meta charset="utf-8">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/highlight.js@11.11.1/styles/\(theme)">
            <style>
                :root {
                    color-scheme: \(colorScheme == .dark ? "dark" : "light");
                }

                html, body {
                    margin: 0;
                    padding: 0;
                    min-height: 100%;
                    background: \(backgroundColor);
                    color: \(textColor);
                }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Helvetica, Arial, sans-serif;
                }

                pre {
                    margin: 0;
                    padding: 16px;
                    overflow-x: auto;
                    white-space: pre;
                }

                code {
                    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
                    font-size: 15px;
                    line-height: 1.5;
                }
            </style>
        </head>
        <body>
            <pre><code class="language-\(sourceLanguage)"></code></pre>
            <script src="https://cdn.jsdelivr.net/npm/highlight.js@11.11.1/highlight.min.js"></script>
            <script>
                const encodedSource = "\(encodedSource)";
                const decodedSource = atob(encodedSource);
                const code = document.querySelector("code");
                code.textContent = decodedSource;
                if (window.hljs) {
                    window.hljs.highlightElement(code);
                }
            </script>
        </body>
        </html>
        """
    }

    private var colorScheme: ColorScheme {
        UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWebView(
            url: URL(string: "https://example.com/")!,
            reloader: false
        )
    }
}
