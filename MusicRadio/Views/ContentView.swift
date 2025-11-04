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
    @Query private var countries: [Country]
    
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
        .task {
            do {
                if countries.count == 0 {
                    let allCountries = try await network.getAllCountries()
                    print("---> allCountries: \(allCountries.count)")
                    for country in allCountries {
                        modelContext.insert(country)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
}



/*
.task {
    do {
//                let stacions = try await network.getStationsForCountry("Australia")
//                for station in stacions.prefix(24) {
//                    modelContext.insert(station)
//                }
        
        let countries = try await network.getAllCountries()
        print("\n---> countries.count: \(countries.count)" )
        
        let test1 = Set(countries.map(\.name))
        print("---> test1.count: \(test1.count)" )
        
        
        for country in countries {
           // modelContext.insert(country)
//            print("---> country: \(country.name)  \(country.iso_3166_1)")
        }
    } catch {
        print(error)
    }
}
*/
