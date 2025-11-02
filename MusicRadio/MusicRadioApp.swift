//
//  MusicRadioApp.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//

import SwiftUI
import SwiftData

@main
struct MusicRadioApp: App {

    var sharedModelContainer: ModelContainer = {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
        let storeURL: URL = appSupportDir?.appending(path: "database.sqlite") ?? URL.documentsDirectory.appending(path: "database.sqlite")
        print("---> database: \(storeURL.absoluteString)")
        let schema = Schema([Item.self])
        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
