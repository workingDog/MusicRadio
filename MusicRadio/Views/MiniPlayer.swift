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
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 12) {
                Group {
                    if playerManager.station == nil {
                        Image(uiImage: RadioStation.defaultImg)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .cornerRadius(6)
                            .shadow(radius: 3)
                    } else {
                        Image(uiImage: playerManager.station!.faviconImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .cornerRadius(6)
                            .shadow(radius: 3)
                    }
                }.padding(4)
                VStack {
                    Text(playerManager.station?.name ?? "no station")
                        .font(.headline)
                        .lineLimit(1)
                    Text(playerManager.currentSong)
                        .font(.headline)
                        .lineLimit(1)
                }
            }
            
            HStack(spacing: 8) {
                Spacer()
                
                if playerManager.isPlaying {
                    EqualizerView()//.tint(.mint)
                        .frame(width: 80, height: 40, alignment: .bottomLeading)
                }
                
                Spacer()
                
                // to update volume in real time
                Slider(value: Binding(
                    get: { Double(playerManager.volume) },
                    set: { playerManager.updateVolume($0)}
                ), in: 0...1)
                
                Spacer()
                
                // Play / Pause button
                Button {
                    playerManager.togglePlayback()
                } label: {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(10)
                        .foregroundStyle(.primary)
                        .background(.thickMaterial, in: Circle())
                }
            }.padding(6)
            
        } // VStack

        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
