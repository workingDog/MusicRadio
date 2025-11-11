//
//  CountryView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct CountryView: View {
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
            ).ignoresSafeArea()
            
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
    //    .navigationBarTitle(country.name)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(country.iso_3166_1.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text(country.name)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }

    }
    
}
