//
//  StationView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct StationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PlayerManager.self) var playerManager

    var station: RadioStation

    var body: some View {
        VStack {
            Button {
                station.isFavourite.toggle()
                RadioStation.findOrInsert(station: station, in: modelContext)
            } label: {
                Image(systemName: station.isFavourite ? "star.fill" : "star.slash")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.mint)
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(5)
            }
            
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
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            if playerManager.station == station {
                playerManager.station = nil
                playerManager.pause()
            } else {
                playerManager.pause()
                playerManager.station = station
            }
        }
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
    }
}
