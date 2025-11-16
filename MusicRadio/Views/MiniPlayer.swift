//
//  MiniPlayer.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import SwiftUI
import AVFoundation


struct MiniPlayer: View {
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    
    @State private var showArt: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 12) {
                Group {
                    HStack {
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
                    }
                    .onTapGesture {
                        if !playerManager.currentSong.isEmpty {
                            showArt = true
                        }
                    }
                }.padding(4)
                VStack {
                    Text(playerManager.station?.name ?? "no station")
                    Text(playerManager.currentSong)
                }
                .font(.headline)
                .lineLimit(1)
            }
            
            HStack(spacing: 8) {
                Spacer()
                
                if playerManager.isPlaying {
                    EqualizerView()
                        .frame(width: 80, height: 40, alignment: .bottomLeading)
                }
                
                Spacer()
                
                // to update volume in real time
                Slider(value: Binding(
                    get: { Double(playerManager.volume) },
                    set: { playerManager.updateVolume($0)}
                ), in: 0...1)
                
                Spacer()
                
                // play / pause button
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
        //     .background(.ultraThinMaterial)
        .background(colorsModel.backColor.opacity(0.4))
        .glassEffect(.regular.tint(colorsModel.backColor.opacity(0.4)).interactive(), in: RoundedRectangle(cornerRadius: 12)) // for iOS26+
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
        .sheet(isPresented: $showArt) {
            ArtistView(song: playerManager.currentSong)
                .environment(colorsModel)
        }
    }
}
