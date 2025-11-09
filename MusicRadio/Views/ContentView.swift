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
    @State private var selector = Selector()

    let network = Networker()

    @Query private var stations: [RadioStation]
    @Query private var countries: [Country]
    

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: selector.view.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
             .animation(.easeInOut(duration: 0.4), value: selector.view)
            
            VStack {
                ToolsView().padding(.bottom, 5)
                
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
                print("-----> stations: \(stations.count) \n")
                selector.retrieveSettings()
            }
        }
        .environment(playerManager)
        .environment(selector)
        .task {
            do {
                // if first time, get all the countries
                if countries.count == 0 {
                    let allCountries = try await network.getAllCountries()
                    print("---> allCountries: \(allCountries.count)")
                    for country in allCountries {
                        modelContext.insert(country)
                    }
                    // also add the top voted stations to "Favourite"
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
            // try to adjust the initial volume
//            let sysvol = AVAudioSession.sharedInstance().outputVolume
//            let desired = 0.25 //min(1.0, sysvol) / 2.0
//            playerManager.volume = min(1.0 - Float(sqrt(desired)) / sysvol, 1.0)
//            print("---> sysvol: \(sysvol)  app vol: \(playerManager.volume)")
            
            playerManager.volume = 0.3
        }
 
    }
    
}
