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
    @State private var colorsModel = ColorsModel()
    
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
                .environment(colorsModel)
        }
        .modelContainer(sharedModelContainer)
    }
}


/*
 
 I have this SwiftUI code:
 "Button {
     station.isFavourite.toggle()
     if !station.isFavourite {
         showConfirm = true
     } else {
         //  do something
     }
 } label: {
     Image(systemName: station.isFavourite ? "heart.fill" : "heart.slash")
         .resizable()
         .foregroundStyle(colorsModel.favouriteColor)
         .frame(width: 30, height: 30)
         .padding(5)
 }.buttonStyle(.borderless)
     .confirmationDialog("Remove from favourites", isPresented: $showConfirm) {
         Button("Yes") { }
         Button("Cancel", role: .cancel) { }
     } message: { Text("Really remove this station from favourites?") }",
 however the confirmationDialog does not display, why and how to fix this?
 
 */
