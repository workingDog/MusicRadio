//
//  FavoriteView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct FavoriteView: View {
    @Environment(AudioPlayerModel.self) var audioPlayer
    let stations: [RadioStation]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var selectedStation: RadioStation?
    
    var body: some View {
        if stations.isEmpty {
            Text("no favorite 🎵")
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(stations) { station in
                        Button {
                            // click on same station to deselect
                            if selectedStation == station {
                                selectedStation = nil
                            } else {
                                selectedStation = station
                            }
                        } label: {
                            VStack {
                                Image(uiImage: station.faviconImage())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                
                                Text(station.name)
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 100)
                                    .padding()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedStation == station ? Color.blue.opacity(0.7) : .clear,
                                        lineWidth: 8)
                        )
                    }
                }
                .padding(12)
            }
            
            MiniPlayer(station: $selectedStation).padding(10)
            
        }
    }
}
