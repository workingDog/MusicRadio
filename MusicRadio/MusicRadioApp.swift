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
// https://docs.radio-browser.info/#introduction

@main
struct MusicRadioApp: App {
    @State private var colorsModel = ColorsModel()
    
    let networker = Networker()
    
    var sharedModelContainer: ModelContainer = {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
        let storeURL: URL = appSupportDir?.appending(path: "musicRadio.sqlite") ?? URL.documentsDirectory.appending(path: "musicRadio.sqlite")
        
        print("---> database at: \(storeURL.absoluteString)\n")
        
        let schema = Schema([RadioStation.self, Country.self])
        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            AppLogger.logPublic("Could not create ModelContainer: ", error)
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(colorsModel)
                .environment(\.networker, networker)
                .onAppear {
                    #if targetEnvironment(macCatalyst)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.titlebar?.titleVisibility = .hidden
                    }
                    #endif
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
