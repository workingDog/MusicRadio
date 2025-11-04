//
//  StationListView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct StationListView: View {
    @Environment(PlayerManager.self) var playerManager
    
    var stations: [RadioStation]
    let columns: [GridItem]
    
    @State private var searchText = ""
    
    private var filteredStations: [RadioStation] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return stations }
        return stations.filter {
            $0.name.lowercased().starts(with: searchText.lowercased())
        }
    }
    
    init(stations: [RadioStation], columns: Int) {
        self.stations = stations
        self.columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: columns)
    }
    
    var body: some View {
        VStack {
            if stations.isEmpty {
                Text("no stations 🎵")
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(filteredStations) { station in
                            StationView(station: station)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(playerManager.station == station ? Color.blue.opacity(0.7) : .clear,
                                                lineWidth: 8)
                                )
                        }
                    }
                    .padding(.horizontal, 4)
                    .searchable(text: $searchText, prompt: "Search station")
                }
                
                MiniPlayer().padding(10)
                
            }
        }
        
    }
    
}
