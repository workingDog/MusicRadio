//
//  BaseStationView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct BaseStationView: View {
    @Environment(AudioPlayerModel.self) var audioPlayer
    @Environment(SelectionModel.self) var selector
    
    var stations: [RadioStation]
    let columns: [GridItem]
    
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
                                .stroke(selector.selectedStation == station ? Color.blue.opacity(0.7) : .clear,
                                        lineWidth: 8)
                        )
                    }
                }
                .padding(12)
            }
            
            MiniPlayer().padding(10)
        
        }
    }
}

