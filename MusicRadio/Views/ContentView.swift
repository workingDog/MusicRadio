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
    @Environment(ColorsModel.self) var colorsModel
    @Environment(\.networker) private var networker
    
    @State private var playerManager = PlayerManager()
    @State private var selector = Selector()

    @Query private var stations: [RadioStation]
    @Query private var countries: [Country]
    
    var body: some View {
        ZStack(alignment: .top) {
            colorsModel.gradient.ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: selector.view)
            
            VStack {
                ToolsView()
                
                if selector.view != .countries {
                    FilterToolsView().fixedSize()
                }
                
                switch selector.view {
                    case .favourites: StationListView(stations: stations.filter({$0.isFavourite}))
                        
                    case .countries: CountriesView()
                        
                    case .stations: SearchStationView()
                }
            }
            .onAppear {
                selector.retrieveSettings()
                colorsModel.retrieveSettings()
            }
        }
        .environment(playerManager)
        .environment(selector)
        .task {
            do {
                // if first time, get all the countries and store them in SwiftData
                if countries.count == 0 {
                    let allCountries = try await networker.getAllCountries()
                    for country in allCountries {
                        modelContext.insert(country)
                    }

                    // add the top voted stations to "Favourites"
                    var topStations: [RadioStation] = []
                    
                    let countryCode = Locale.current.region?.identifier ?? ""
                    if countryCode.isEmpty {
                        // overall top stations
                        topStations = try await networker.getTopVotes(selector.topCount)
                    } else {
                        // only current country top stations
                        topStations = try await networker.getTopVotesFor(countryCode, limit: selector.topCount)
                    }
                    // store them in SwiftData
                    for station in topStations {
                        station.isFavourite = true
                        modelContext.insert(station)
                    }
                }
            } catch {
                AppLogger.logPublic("", error)
            }
        }
    }
   
}
