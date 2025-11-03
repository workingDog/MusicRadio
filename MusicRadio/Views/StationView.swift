//
//  StationView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData


struct StationView: View {
    @Environment(AudioPlayerModel.self) var audioPlayer

    var station: RadioStation

    var body: some View {
        VStack {
            Button {
                station.isFavourite.toggle()
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
            if audioPlayer.station == station {
                audioPlayer.station = nil
                audioPlayer.pause()
            } else {
                audioPlayer.pause()
                audioPlayer.station = station
            }
        }
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
    }
}
