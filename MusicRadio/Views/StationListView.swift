//
//  StationListView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct StationListView: View {
    @Environment(Selector.self) var selector
    @Environment(PlayerManager.self) var playerManager
    
    var stations: [RadioStation]
    let columns: [GridItem]
    
    @State private var searchText = ""
    
    // max value of votes in the current list of stations
    var maxRating: Int {
        stations.map(\.votes).max() ?? 0
    }
    
    private var filteredStations: [RadioStation] {
        
        let xstations = switch selector.filter {
            case .topRated: Array(stations.sorted{ $0.votes > $1.votes }.prefix(selector.topCount))
            case .all: stations.sorted{ $0.votes > $1.votes }
        }

        let tagStations = stations.filter { station in
            let dominantTag = StationTag.inferDominantGenre(from: station.tags)
            return dominantTag == selector.tag
        }

        let zstations = selector.tag == .all ? xstations : tagStations

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return zstations }
        return zstations.filter { station in
            let cleanName = station.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleanName.lowercased().starts(with: searchText.lowercased())
        }
    }
    
    init(stations: [RadioStation], columns: Int) {
        self.stations = stations
        self.columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: columns)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(filteredStations) { station in
                        StationView(station: station, maxRating: maxRating)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(playerManager.station == station ? Color.blue : .clear, lineWidth: 4)
                            )
                            .padding(.horizontal, 4)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 6)
            }
            .scrollContentBackground(.hidden)
            .searchable(text: $searchText, prompt: "Search station")
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 6)
            
            MiniPlayer()
                .padding(.horizontal)
                .padding(.vertical, 4)
            
        }
    }
    
}
