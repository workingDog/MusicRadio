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
    
    let network = Networker()
    
    let country: Country
    
    @State private var stations: [RadioStation] = []
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: ToolTypes.countries.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack {
                if stations.isEmpty {
                    ProgressView()
                } else {
                    StationListView(stations: stations, columns: 3)
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
