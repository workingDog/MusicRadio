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
    
    @AppStorage("lastCountriesUpdate") private var lastUpdate: Date = .distantPast
    
    @State private var playerManager = PlayerManager()
    @State private var selector = Selector()
    
    @State private var showEqualizer = false
    @State private var showNewStation = false
    
    @Query private var stations: [RadioStation]
    @Query private var countries: [Country]
    
    var body: some View {
        ZStack(alignment: .top) {
            AppBackground().ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: selector.view)
            
            VStack {
                ToolsView()
                
                if selector.view != .countries {
                    HStack {
//                        Spacer()
//                        Button {
//                            showEqualizer = true
//                        } label: {
//                            Image(systemName: "slider.horizontal.3")
//                        }
//                        .padding(8)
//                        .background(.ultraThinMaterial)
//                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .shadow(radius: 2)
                        Spacer()
                        FilterToolsView().fixedSize()
                        Spacer()
//                        Button {
//                            showNewStation = true
//                        } label: {
//                            Image(systemName: "radio")
//                        }
//                        .padding(8)
//                        .background(.ultraThinMaterial)
//                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .shadow(radius: 2)
//                        Spacer()
                    }
                    .padding(.top, 8)
                }
                
                switch selector.view {
                    case .favourites: StationListView(stations: stations.filter({$0.isFavourite}))
                    case .countries: CountriesView()
                    case .stations: SearchStationView()
                }
            }
//            .sheet(isPresented: $showEqualizer) {
//                SoundEqualizerControl()
//                    .environment(playerManager)
//            }
//            .sheet(isPresented: $showNewStation) {
//                NewStationView()
//                    .environment(playerManager)
//                    .environment(colorsModel)
//            }
            .onAppear {
                selector.retrieveSettings()
                colorsModel.retrieveSettings()
                
//                for station in stations {
//                    print("---> \(station.name)\n \(station.url)\n  \(station.favicon)")
//                }
            }
        }
        .environment(playerManager)
        .environment(selector)
        .task {
            do {
                if countries.isEmpty {
                    // First launch: fetch and store all countries
                    let allCountries = try await networker.getAllCountries()
                    for country in allCountries where !country.name.trim().isEmpty {
                        modelContext.insert(country)
                    }
                    try modelContext.save()
                    
                    // Add top-voted stations to Favourites
                    let countryCode = Locale.current.region?.identifier ?? ""
                    let topStations = countryCode.isEmpty
                    ? try await networker.getTopVotes(selector.topCount)
                    : try await networker.getTopVotesFor(countryCode, limit: selector.topCount)
                    for station in topStations {
                        station.isFavourite = true
                        modelContext.insert(station)
                    }
                    try modelContext.save()
                    lastUpdate = .now
                } else if Date.now.timeIntervalSince(lastUpdate) >= 30 * 24 * 60 * 60 { // 30 days
                    // Refresh country station counts after 30 days
                    let allCountries = try await networker.getAllCountries()
                    let existingCountries = Dictionary(uniqueKeysWithValues: countries.map { ($0.name, $0) })
                    for country in allCountries where !country.name.trim().isEmpty {
                        if let existing = existingCountries[country.name] {
                            existing.stationcount = country.stationcount
                        } else {
                            modelContext.insert(country)
                        }
                    }
                    try modelContext.save()
                    lastUpdate = .now
                }
            } catch {
                AppLogger.logPublic(error)
            }
        }
    }
    
}
