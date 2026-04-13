//
//  EdhitaApp.swift
//  Edhita
//
//  Created by Tatsuya Tobioka on 2022/07/24.
//

import SwiftUI

@main
struct CodeEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let documentCoordinator = DocumentOpenCoordinator.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    NavigationView {
                        FinderListView(list: FinderList(url: FinderList.rootURL))
                    }
                    .navigationViewStyle(.stack)
                    .environmentObject(documentCoordinator)
                    .onOpenURL { url in
                        documentCoordinator.handleIncoming(url: url)
                    }
                } else {
                    NavigationView {
                        FinderListView(list: FinderList(url: FinderList.rootURL))
                        PlaceholderView()
                    }
                    .environmentObject(documentCoordinator)
                    .onOpenURL { url in
                        documentCoordinator.handleIncoming(url: url)
                    }
                }
            }
        }
    }
}
