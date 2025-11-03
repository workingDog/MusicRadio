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
    @Environment(SelectionModel.self) var selector
    
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if selector.selectedStation == nil {
                    Image(uiImage: RadioStation.defaultImg)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .cornerRadius(6)
                        .shadow(radius: 3)
                        .foregroundStyle(.red.opacity(0.6))
                } else {
                    Image(uiImage: selector.selectedStation!.faviconImage())
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
            if selector.selectedStation != nil {
                audioPlayer.setupPlayerFor(selector.selectedStation!)
            }
        }
        .onChange(of: selector.selectedStation?.id) {
            if selector.selectedStation != nil {
                audioPlayer.isPlaying = false
                audioPlayer.setupPlayerFor(selector.selectedStation!)
            } else {
                audioPlayer.station = nil
                audioPlayer.isPlaying = false
            }
        }
    }
}
