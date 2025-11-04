//
//  StationView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import SwiftData
import WebKit


struct StationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PlayerManager.self) var playerManager

    var station: RadioStation
    @State private var showWeb: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    station.isFavourite.toggle()
                    print("\n---> station.isFavourite: \(station.isFavourite)\n")
                    if !station.isFavourite {
                        print("---> findAndRemove")
                        Utils.findAndRemove(station: station, in: modelContext)
                    } else {
                        print("---> findOrInsert")
                        Utils.findOrInsert(station: station, in: modelContext)
                    }
                } label: {
                    Image(systemName: station.isFavourite ? "star.fill" : "star.slash")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.mint)
                        .frame(width: 30, height: 30)
             //           .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                }
                Spacer()
                Button {
                    showWeb = true
                } label: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.primary)
                        .frame(width: 30, height: 30)
                        .padding(5)
                }
            }
            .padding(.bottom, 5)
            
            Image(uiImage: station.faviconImage())
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 55)
            
            Text(station.name)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .padding(5)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            if playerManager.station == station {
                playerManager.pause()
                playerManager.currentSong = ""
                playerManager.station = nil
            } else {
                playerManager.pause()
                playerManager.currentSong = ""
                playerManager.station = station
            }
        }
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12))
        .fullScreenCover(isPresented: $showWeb) {
            WebView(url: URL(string: station.homepage))
        }
    }
}
