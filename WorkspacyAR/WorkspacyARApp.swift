//
//  WorkspacyARApp.swift
//  WorkspacyAR

import SwiftUI
import SwiftData

@main
struct WorkspacyARApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedDeskLayout.self)
    }
}
