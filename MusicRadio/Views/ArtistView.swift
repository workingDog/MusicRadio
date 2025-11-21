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
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    
    @State private var artist: Artist?
    @State private var isBusy = true

    let network = Networker()
    
    var body: some View {
        VStack {
            HStack {
                Button("Done") {
                    dismiss()
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
                artist = try await network.fetchArtist(
                    for: playerManager.currentSong,
                    countryCode: playerManager.station?.countrycode ?? "us")
                isBusy = false
            } catch {
                print(error)
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
    let network = Networker()
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
                    lyrics = try await network.findLyrics(artist!)
                    isBusy = false
                } catch {
                    print(error)
                }
            }
        }
    }
}



/*
 @State private var infoView: InfoTypes = .overview
 
 enum InfoTypes: String, CaseIterable, Identifiable {
     case overview = "Overview"
     case artist = "Artist"
     case track = "Track"
     case collection = "Collection"
     
     var id: String { rawValue }
 }


 
 
 // does not seem to be useful
 
//            Picker("", selection: $infoView) {
//                ForEach(InfoTypes.allCases) { info in
//                    Text(info.rawValue).tag(info)
//                }
//            }
//            .pickerStyle(.segmented)
//            .fixedSize()
//            .padding(.horizontal)
//            .padding(.bottom, 20)

//            switch infoView {
//                case .overview: overView()
//                case .track: trackView()
//                case .artist: artistView()
//                case .collection: collectionView()
//            }
 
 
 //    @ViewBuilder
 //    func artistView() -> some View {
 //        if let artist, let url = URL(string: artist.artistViewURL) {
 //            ArtistWebView(url: url)
 //        }
 //    }
 //
 //    @ViewBuilder
 //    func trackView() -> some View {
 //        if let artist, let url = URL(string: artist.trackViewURL) {
 //            ArtistWebView(url: url)
 //        }
 //    }
 //
 //    @ViewBuilder
 //    func collectionView() -> some View {
 //        if let artist, let url = URL(string: artist.collectionViewURL) {
 //            ArtistWebView(url: url)
 //        }
 //    }
 
 
//struct ArtistWebView: View {
//    let url: URL
//    @State private var page = WebPage()
//    
//    var body: some View {
//        if page.isLoading {
//            ProgressView()
//        }
//        WebView(page)
//            .onAppear {
//                page.load(url)
//            }
//    }
//}


*/
