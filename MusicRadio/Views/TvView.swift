//
//  TvView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/20.
//
import SwiftUI
import AVKit


struct TvView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ColorsModel.self) var colorsModel
    @Environment(PlayerManager.self) var playerManager

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

            if let player = playerManager.radio?.player {
                VideoPlayer(player: player)
            }
            
            Spacer()
        }
        .background(colorsModel.backColor)
        .onAppear {
            playerManager.isPlaying = true
        }
    }
    
}
