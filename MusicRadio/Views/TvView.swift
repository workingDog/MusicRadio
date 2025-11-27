//
//  TvView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/20.
//
import SwiftUI
import AVKit


struct TvView: View {
    @Environment(ColorsModel.self) var colorsModel
    @Environment(PlayerManager.self) var playerManager
    
    @Binding var showArt: Bool
    
    var body: some View {
        ZStack {
            if let player = playerManager.radio?.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }
            VStack {
                HStack {
                    Button("Done") {
                        showArt = false
                    }
                    .buttonStyle(.bordered)
                    .padding(10)
                    Spacer()
                }
                Spacer()
            }
        }
        .background(colorsModel.backColor)
        .onAppear {
            playerManager.isPlaying = true
        }
    }
    
}
