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
    let maxRating: Int
    
    @State private var showWeb: Bool = false
    @State private var stars = 0
    
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
                        .foregroundStyle(.mint)
                        .frame(width: 30, height: 30)
                        .padding(5)
                }.buttonStyle(.borderless)
                
                Spacer()
                
                if playerManager.station == station, playerManager.isPlaying {
                    EqualizerView().tint(.pink).offset(y: -5)
                }
                
                Spacer()
                
                Button {
                    showWeb = true
                } label: {
                    Image(systemName: "network")
                        .resizable()
                        .foregroundStyle(.primary)
                        .frame(width: 30, height: 30)
                        .padding(5)
                }.buttonStyle(.borderless)
            }
            
            RatingLineView(station, maxRating)
            
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
            WebViewScreen(station: station)
        }
    }
}

struct WebViewScreen: View {
    @Environment(\.dismiss) private var dismiss
    let station: RadioStation

    var body: some View {
        VStack {
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(6)

            Divider()

            if let url = URL(string: station.homepage),
                UIApplication.shared.canOpenURL(url) {
                 WebView(url: url)
             } else {
                 Text("No homepage available").font(Font.largeTitle.bold())
                 Spacer()
             }
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
