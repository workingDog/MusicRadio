//
//  LyricsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2026/10/19.
//
import SwiftUI
import UIKit


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

