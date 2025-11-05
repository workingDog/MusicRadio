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
        self.columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: columns)
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
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(playerManager.station == station ? Color.pink : .clear, lineWidth: 4)
                                )
                            .padding(.horizontal, 4)
                        }
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 8)
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, prompt: "Search station")
                .padding(.horizontal, 8)
 
                MiniPlayer()
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                
            }
        }
    }
    
}



/*
 
              
//                List(filteredStations) { station in
//                    StationView(station: station)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(playerManager.station == station ? Color.white : .clear, lineWidth: 4)
//                        )
//                        .listRowSeparator(.hidden)
//                        .listRowBackground(Color.gray.opacity(0.2))
//                        .listRowInsets(EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3))
//                        .contentShape(Rectangle())
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                }
//                .scrollContentBackground(.hidden)
//                .background(Color.clear)
//                .listRowSpacing(10)
//                .searchable(text: $searchText, prompt: "Search station")
              
 */
