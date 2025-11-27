//
//  StationPlayer.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/20.
//
import SwiftUI
import AVFoundation
import MediaPlayer


struct StationPlayer: View {
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    
    @State private var showArt: Bool = false
    @State private var logoIcon: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 12) {
                Group {
                    HStack {
                        if playerManager.station == nil {
                            Image(uiImage: playerManager.defaultImg).resizable()
                        } else {
                            if let img = logoIcon {
                                Image(uiImage: img).resizable()
                            } else {
                                Image(uiImage: playerManager.defaultImg).resizable()
                            }
                        }
                    }
                    .onTapGesture {
                        showArt = true
                    }
                }
                .scaledToFit()
                .frame(width: 45, height: 45)
                .cornerRadius(6)
                .shadow(radius: 3)
                .padding(4)
                
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
                
                SystemVolumeSlider()
                    .frame(height: 40)
                    .padding(.top, 5)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                Button {
                    playerManager.togglePlayback()
                    if let station = playerManager.station, station.isTV, playerManager.isPlaying {
                        showArt = true
                    }
                } label: {
                    ZStack {
                        if let station = playerManager.station, station.isTV {
                            Image(systemName: "tv").offset(x: 0, y: -30)
                        }
                        Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(10)
                    .foregroundStyle(.primary)
                    .background(.thickMaterial, in: Circle())
                }
            }.padding(6)
            
        } // VStack
        .background(colorsModel.backColor.opacity(0.4))
   //     .glassEffect(.regular.tint(colorsModel.backColor.opacity(0.4)).interactive(), in: RoundedRectangle(cornerRadius: 12)) // for iOS26+
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
            Task {
                if let station = playerManager.station {
                    logoIcon = await station.faviconImage()
                } else {
                    logoIcon = playerManager.defaultImg
                }
            }
        }
        .sheet(isPresented: $showArt) {
            Viewer(showArt: $showArt)
                .environment(colorsModel)
                .environment(playerManager)
        }
    }
}

struct Viewer: View {
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    
    @Binding var showArt: Bool
    
    var body: some View {
        VStack {
            if let station = playerManager.station, station.isTV {
                TvView(showArt: $showArt)
            } else {
                ArtistView(showArt: $showArt)
            }
        }
    }
}

// control the system volume
struct SystemVolumeSlider: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MPVolumeView {
        let view = MPVolumeView()
        return view
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}
