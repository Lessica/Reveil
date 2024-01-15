//
//  ReveilApp.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import SwiftUI

#if canImport(UIKit)
    @_exported import UIKit
#endif

#if canImport(AppKit)
    @_exported import AppKit
#endif

@main
struct ReveilApp: App {
    init() { _ = PinStorage.shared }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if canImport(AppKit)
        .commands {
            SidebarCommands()
        }
        .windowToolbarStyle(.unifiedCompact)
        #endif
    }
}
