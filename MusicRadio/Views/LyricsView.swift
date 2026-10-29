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
            if artist != nil {
                do {
                    isBusy = true
                    lyricsRecord = try await networker.findLyrics(artist!)
                    
               //     lyricsRecord = try await networker.getTestLyrics(36497565)
                       
                    if let rec = lyricsRecord, let lyricsf = rec.lyricsfile {
                        lyricsfile = networker.decodeLyricsfile(lyricsfile: lyricsf)
                    }
                    isBusy = false
                } catch {
                    AppLogger.logPublic(error)
                }
            }
        }
    }
    
    @ViewBuilder
    var lyricsContent: some View {
        if lyricsRecord?.hasWordSync == true,
           let lyricsfile {
            SyncedLyricsView(lyrics: lyricsfile) {
                Int(playerManager.currentTime)  // <--- in seconds, want ms
            }
        } else if let lyrics = lyricsRecord?.plainLyrics {
            Text(lyrics)
                .font(.title2)
                .padding(15)
        }
    }

}

struct LyricsSyncView: View {
    let lyrics: LyricsFile
    let currentTimeMs: Int
    
    private var currentLineIndex: Int? {
        lyrics.lines.lastIndex {
            currentTimeMs >= $0.startMs
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(lyrics.lines.enumerated()), id: \.offset) { index, line in
                        LyricLineView(line: line, currentTimeMs: currentTimeMs)
                    }
                }
                .padding()
            }
            .onChange(of: currentLineIndex) { _, index in
                guard let index else { return }
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(index, anchor: .center)
                }
            }
        }
    }
}

struct LyricLineView: View {
    @Environment(ColorsModel.self) var colorsModel
    
    let line: LyricLine
    let currentTimeMs: Int

    var body: some View {
        Group {
            if let words = line.words, !words.isEmpty {
                wordText(words)
            } else {
                Text(line.text).foregroundStyle(.primary)
            }
        }
        .font(.title3)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func wordText(_ words: [LyricWord]) -> some View {
        words.enumerated().reduce(Text("")) { result, element in
            let (index, word) = element
            let endMs = word.endMs ?? words.dropFirst(index + 1).first?.startMs
            let isCurrent = currentTimeMs >= word.startMs &&
                (endMs.map { currentTimeMs < $0 } ?? true)
            
            return result + Text(word.text + " ")
                .foregroundColor(isCurrent ? .purple : .primary)
                .bold(isCurrent)
        }
    }

}

struct SyncedLyricsView: View {
    let lyrics: LyricsFile
    let playbackTime: () -> Int

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.05)) { _ in
            let currentTimeMs = playbackTime()
  //          VStack {
  //              Text("Playback: \(currentTimeMs) ms")
                LyricsSyncView(lyrics: lyrics, currentTimeMs: currentTimeMs)
  //          }
        }
    }
}
