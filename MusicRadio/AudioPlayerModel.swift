//
//  AudioPlayerModel.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import Foundation
import SwiftUI
import AVKit
import AVFoundation


@MainActor
@Observable
class AudioPlayerModel {
    
    var station: RadioStation?
    var player: AVPlayer?
    var isPlaying = false
    var progress: Double = 0

    
    func setupPlayerFor(_ radioStation: RadioStation) {
        self.station = radioStation

        if let station = station {
       //     let theUrl = station.url.replacingOccurrences(of: "http://", with: "https://")
            // guard let url = URL(string: theUrl) else { return }

            guard let url = URL(string: station.url) else { return }
            print("---> url: \(url.absoluteString)")
            player = AVPlayer(url: url)
        }
    }
    
    func togglePlayback() {
        guard let player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func play(url: URL) {
        if player == nil {
            player = AVPlayer(url: url)
        }
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
 
}
