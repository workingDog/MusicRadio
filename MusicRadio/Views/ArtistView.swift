//
//  ArtistView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/15.
//
import SwiftUI
import UIKit
import WebKit


struct ArtistView: View {
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    @Environment(\.networker) private var networker
    
    @Binding var showArt: Bool
    
    @State private var artist: Artist?
    @State private var isBusy = true

    var body: some View {
        VStack {
            HStack {
                Button("Done") {
                    showArt = false
                }
                .buttonStyle(.bordered)
                Spacer()
            }
            .padding(12)
            
            Spacer()
            
            ScrollView {
                if isBusy {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    Spacer()
                } else {
                    overView()
                    LyricsView(artist: artist)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
            }
            
        }
        .background(AppBackground())
        .task {
            do {
                isBusy = true
                artist = try await networker.fetchArtist(
                    for: playerManager.currentSong,
                    countryCode: playerManager.station?.countrycode ?? "us")
                isBusy = false
            } catch {
                AppLogger.logPublic(error)
            }
        }
    }
    
    @ViewBuilder
    func overView() -> some View {
        VStack(spacing: 10) {
            if let img = artist?.imageData  {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            Text(artist?.artistName ?? "")
            Text(artist?.releaseDate?.formatted(.dateTime.year().month()) ?? "")
            Text(artist?.trackName ?? "")
            Spacer()
        }
        .padding(5)
    }
    
}
