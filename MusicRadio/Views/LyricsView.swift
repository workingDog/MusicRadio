//
//  LyricsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2026/10/19.
//
import SwiftUI
import UIKit
import LRCLIBKit


struct LyricsView: View {
    @Environment(\.networker) private var networker
    @Environment(PlayerManager.self) var playerManager

    let artist: Artist?
    
    @State private var isBusy: Bool = false
    @State private var lyricsRecord: LyricsRecord?
    @State private var lyricsfile: LyricsFile?
    
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
                lyricsContent
            }
        }
        .task {
            if let artist {
                do {
                    isBusy = true
                    lyricsRecord = try await networker.findLyrics(artist)
                    isBusy = false
                } catch {
                    AppLogger.logPublic(error)
                    isBusy = false
                }
            }
        }
        
    }
    
    @ViewBuilder
    var lyricsContent: some View {
        if let lyrics = lyricsRecord?.plainLyrics {
            Text(lyrics)
                .font(.title2)
                .padding(15)
        }
        
    }
    
}
