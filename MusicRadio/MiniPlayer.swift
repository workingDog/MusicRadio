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
    @Environment(AudioPlayerModel.self) var audioPlayer
    @Binding var station: RadioStation?

    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if station == nil {
                    Image(uiImage: RadioStation.defaultImg)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .cornerRadius(6)
                        .shadow(radius: 3)
                        .foregroundStyle(.red.opacity(0.6))
                } else {
                    Image(uiImage: station!.faviconImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .cornerRadius(6)
                        .shadow(radius: 3)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(audioPlayer.station?.name ?? "no station")
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Play / Pause button
            Button {
                audioPlayer.togglePlayback()
            } label: {
                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
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
        .onAppear {
            if station != nil {
                audioPlayer.setupPlayerFor(station!)
            }
        }
        .onChange(of: station) {
            if station != nil {
                audioPlayer.isPlaying = false 
                audioPlayer.setupPlayerFor(station!)
            } else {
                audioPlayer.station = nil
                audioPlayer.isPlaying = false
            }
        }
    }
}
