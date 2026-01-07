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
        .background(colorsModel.backColor)
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
        VStack(spacing: 20) {
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
    }
    
}

struct LyricsView: View {
    @Environment(\.networker) private var networker
    let artist: Artist?
    
    @State private var isBusy: Bool = false
    @State private var lyrics: String = "no lyrics"
    
    var body: some View {
        VStack {
            if isBusy {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                Spacer()
            } else {
                Text(lyrics)
                    .font(.title2)
                    .padding(15)
            }
        }
        .task {
            if artist != nil {
                do {
                    isBusy = true
                    lyrics = try await networker.findLyrics(artist!)
                    isBusy = false
                } catch {
                    AppLogger.logPublic(error)
                }
            }
        }
    }
}
