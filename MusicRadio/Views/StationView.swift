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
                    Image(systemName: station.isFavourite ? "heart.fill" : "heart.slash")
                        .resizable()
              //          .scaledToFit()
                        .foregroundStyle(.mint)
                        .frame(width: 30, height: 30)
             //           .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                }.buttonStyle(.borderless)
                
//                Spacer()
//                Button {
//                    station.isInteresting.toggle()
//                } label: {
//                    Image(systemName: station.isInteresting ? "hand.thumbsup.fill" : "hand.thumbsup.slash")
//                        .resizable()
//                        .foregroundStyle(.mint)
//                        .frame(width: 30, height: 30)
//                        .padding(5)
//                }
                
                Spacer()
                
                Button {
                    showWeb = true
                } label: {
                    Image(systemName: "network")
                        .resizable()
                        .foregroundStyle(.black)
                      //  .foregroundStyle(.primary)
                        .frame(width: 30, height: 30)
                        .padding(5)
                }.buttonStyle(.borderless)
            }
            
            Image(uiImage: station.faviconImage())
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
            
            Text(station.name)
                .lineLimit(1)
                .padding(5)

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


/*
 if #available(iOS 26.0, *) {
     WebView(url: URL(string: station.homepage))
 } else {
     VStack {
         Text(station.name).font(.largeTitle)
         Button("Done") {
             showWeb = false
         }.buttonStyle(.borderedProminent)
     }
 }
 */
