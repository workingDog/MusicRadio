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
    @Environment(ColorsModel.self) var colorsModel
    
    @State private var artist: Artist?
    @State private var infoView: InfoTypes = .overview
    @State private var isBusy = true
    
    let song: String
    
    let network = Networker()
    
    var body: some View {
        VStack {
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            
            Spacer()
            
            if isBusy {
                ProgressView()
                Spacer()
            } else {
                overView()
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
            
        }
        .background(colorsModel.backColor)
        .task {
            do {
                isBusy = true
                artist = try await network.fetchArtist(for: song)
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
}

enum InfoTypes: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case artist = "Artist"
    case track = "Track"
    case collection = "Collection"
    
    var id: String { rawValue }
}

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
