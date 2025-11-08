//
//  CountryView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct CountryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Selector.self) var selector
    
    let network = Networker()
    
    let country: Country
    
    @State private var stations: [RadioStation] = []
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: ViewTypes.countries.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack {
                if stations.isEmpty {
                    ProgressView()
                } else {
                    FilterToolsView().fixedSize()
                    StationListView(stations: stations, columns: 2)
                }
            }
        }
        .task {
            do {
                stations = try await network.getStationsForCountry(country.name)
            } catch {
                print(error)
            }
        }
        .navigationBarTitle(country.name)
    }
    
}
