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
    @Environment(ColorModel.self) var colorModel
    
    @State private var playerManager = PlayerManager()
    @State private var selector = Selector()

    let network = Networker()

    @Query private var stations: [RadioStation]
    @Query private var countries: [Country]
    

    var body: some View {
        ZStack(alignment: .top) {
            colorModel.gradient.ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: selector.view)
            
            VStack {
                ToolsView()
                
                if selector.view != .countries {
                    FilterToolsView().fixedSize()
                }

                switch selector.view {
                    case .favourites: StationListView(stations: stations.filter({$0.isFavourite}), columns: 2)

                    case .countries: CountriesView()
   
                    case .stations: SearchStationView()
                }
            }
            .onAppear {
                print("---> stations: \(stations.count) \n")
                selector.retrieveSettings()
                colorModel.retrieveSettings()
                colorModel.updatePalette()
            }
        }
        .environment(playerManager)
        .environment(selector)
        .task {
            do {
                // if first time, get all the countries and store them in SwiftData
                if countries.count == 0 {
                    let allCountries = try await network.getAllCountries()
                    print("---> allCountries: \(allCountries.count)")
                    for country in allCountries {
                        modelContext.insert(country)
                    }
                    // add the top voted stations to "Favourites", also stored in SwiftData
                    let topStations = try await network.getTopVotes(selector.topCount)
                    print("---> topStations: \(topStations.count)")
                    for station in topStations {
                        station.isFavourite = true
                        modelContext.insert(station)
                    }
                }
            } catch {
                print(error)
            }
        }
        .onAppear {
            playerManager.volume = 0.3
        }
 
    }
    
}
