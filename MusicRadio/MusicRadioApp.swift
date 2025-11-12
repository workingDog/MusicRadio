//
//  MusicRadioApp.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//

import SwiftUI
import SwiftData


// info at:
// https://de1.api.radio-browser.info/#General
// https://de1.api.radio-browser.info/json/

// for API see
// https://docs.radio-browser.info/?utm_source=chatgpt.com#introduction

@main
struct MusicRadioApp: App {

    @State var colorModel = ColorModel()
    
    var sharedModelContainer: ModelContainer = {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
        let storeURL: URL = appSupportDir?.appending(path: "database.sqlite") ?? URL.documentsDirectory.appending(path: "database.sqlite")
        print("---> database at: \(storeURL.absoluteString)\n")
        let schema = Schema([RadioStation.self, Country.self])
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
                .environment(colorModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
