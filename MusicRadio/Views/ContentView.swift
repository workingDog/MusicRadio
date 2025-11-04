//
//  ContentView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var playerManager = PlayerManager()
    @State private var selectedTool: ToolTypes = .favorites

    let network = Networker()

    @Query private var stations: [RadioStation]
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: selectedTool.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
             .animation(.easeInOut(duration: 0.4), value: selectedTool)
            
            VStack {
                ToolsView(selectedTool: $selectedTool)
                switch selectedTool {
                    case .favorites: StationListView(stations: stations.filter({$0.isFavourite}), columns: 2)
                    
                    case .stations: StationListView(stations: stations, columns: 3)
                    
                    case .countries: CountriesView()
                }
            }
            .onAppear {
                print("-----> stations: \(stations.count)")
            }
        }
        .environment(playerManager)

//        .task {
//            do {
//                let stacions = try await network.getStationsForCountry("Australia")
//                for station in stacions.prefix(24) {
//                    modelContext.insert(station)
//                }
//                
//                let countries = try await network.getAllCountries()
//                for country in countries {
//                    modelContext.insert(country)
//                }
//            } catch {
//                print(error)
//            }
//        }
    }
    
}
