//
//  MiniPlayer.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import SwiftUI
import SwiftUI
import AVFoundation


struct MiniPlayer: View {
    @Environment(PlayerManager.self) var playerManager
    
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if playerManager.station == nil {
                    Image(uiImage: RadioStation.defaultImg)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .cornerRadius(6)
                        .shadow(radius: 3)
                        .foregroundStyle(.red.opacity(0.6))
                } else {
                    Image(uiImage: playerManager.station!.faviconImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .cornerRadius(6)
                        .shadow(radius: 3)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playerManager.station?.name ?? "no station")
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if playerManager.isPlaying {
                EqualizerView().tint(.blue)
            }
            
            Spacer()
            
            // Play / Pause button
            Button {
                playerManager.togglePlayback()
            } label: {
                Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                    .padding(6)
                    .background(.thickMaterial, in: Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .onChange(of: playerManager.station?.id) {
            if playerManager.station != nil {
                playerManager.setStation(playerManager.station!)
            }
            else {
                playerManager.station = nil
                playerManager.pause()
            }
        }
    }
}
