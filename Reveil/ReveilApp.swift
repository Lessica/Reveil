//
//  ReveilApp.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import SwiftUI

@main
struct ReveilApp: App {
    init() { _ = PinStorage.shared }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
