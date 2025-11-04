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
    
    init(stations: [RadioStation], columns: Int) {
        self.stations = stations
        self.columns = Array(repeating: GridItem(.flexible()), count: columns)
    }
    
    var body: some View {
        if stations.isEmpty {
            Text("no station 🎵")
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(stations) { station in
                        StationView(station: station)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(playerManager.station == station ? Color.blue.opacity(0.7) : .clear,
                                        lineWidth: 8)
                        )
                    }
                }
                .padding(.horizontal, 10)
            }
            
            MiniPlayer().padding(8)
        
        }
    }
}

